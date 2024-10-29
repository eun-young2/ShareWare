import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'package:provider/provider.dart';

class QRProvider with ChangeNotifier {
  Uint8List? qrImageData;
  bool isQRGenerated = false;
  DateTime? issueTime;
  Timer? _timer;
  Duration remainingTime = Duration(hours: 2);

  String? selectedBranchName;
  String? selectedBranchAddress;
  String? selectedBranchContact;
  int? reservIdx; // 예약 인덱스를 저장할 변수 추가

  Future<void> generateQRCode(String userId) async {
    try {
      final response = await http.get(Uri.parse(
              'http://10.0.2.2:8000/generate_qr/$userId') // userId를 URL에 포함
          );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // print("QR 코드 응답 데이터: $data"); // 응답 데이터 출력

        // QR 코드가 null인지 체크
        if (data['qr_code'] != null) {
          qrImageData = base64.decode(data['qr_code']);
          isQRGenerated = true;
          issueTime = DateTime.now();
          reservIdx = data['reserv_idx']; // reserv_idx를 저장
          startTimer();
          notifyListeners();
        } else {
          print("QR 코드 데이터가 null입니다.");
        }
        qrImageData = base64Decode(data['qr_code']);
        isQRGenerated = true;
        issueTime = DateTime.now();
        startTimer();
        notifyListeners();
      } else {
        print('응답 코드: ${response.statusCode}');
        print('응답 본문: ${response.body}');
        throw Exception('Failed to load QR code');
      }
    } catch (error) {
      print('QR 코드 생성 중 오류 발생: $error');
    }
  }

  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      final currentTime = DateTime.now();
      final elapsedTime = currentTime.difference(issueTime!);
      remainingTime = Duration(hours: 2) - elapsedTime;
      if (remainingTime.isNegative) {
        remainingTime = Duration.zero;
        timer.cancel();
      }
      notifyListeners();
    });
  }

  void selectBranch(Map<String, String> branch) {
    selectedBranchName = branch['name'];
    selectedBranchAddress = branch['address'];
    selectedBranchContact = branch['contact'];
    notifyListeners();
  }

  // QR 코드 및 상태 초기화 메서드
  Future<void> resetQRCode() async {
    if (issueTime != null && reservIdx != null) {
      try {
        final response = await http.put(
          Uri.parse('http://10.0.2.2:8000/invalidate_qr/$reservIdx'),
        );

        if (response.statusCode == 200) {
          print('QR 코드 무효화 성공');
        } else {
          print('QR 코드 무효화 실패: ${response.statusCode}');
        }
      } catch (error) {
        print('QR 코드 무효화 요청 중 오류 발생: $error');
      }
    }

    qrImageData = null;
    isQRGenerated = false;
    remainingTime = Duration(hours: 2);
    selectedBranchName = null;
    selectedBranchAddress = null;
    selectedBranchContact = null;
    reservIdx = null; // reservIdx 초기화
    _timer?.cancel();
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }
}
