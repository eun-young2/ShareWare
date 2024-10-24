import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';

class QRProvider with ChangeNotifier {
  Uint8List? qrImageData;
  bool isQRGenerated = false;
  // bool isQRPending = false; // QR 발급 대기 상태 추가
  DateTime? issueTime;
  Timer? _timer;
  Duration remainingTime = Duration(hours: 2);

  String? selectedBranchName;
  String? selectedBranchAddress;
  String? selectedBranchContact;

  Future<void> generateQRCode() async {
    try {
      final response =
          await http.get(Uri.parse('http://10.0.2.2:5000/generate_qr'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        qrImageData = base64Decode(data['qr_code']);
        isQRGenerated = true;
        // isQRPending = false; // QR이 발급되면 대기 상태 해제
        issueTime = DateTime.now();
        startTimer();
        notifyListeners();
      } else {
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

  // // QR 발급 대기 상태를 설정하는 함수
  // void setQRPending(bool pending) {
  //   isQRPending = pending;
  //   notifyListeners();
  // }

  // QR 코드 및 상태 초기화 메서드
  void resetQRCode() {
    qrImageData = null;
    isQRGenerated = false;
    // isQRPending = false; // 초기화 시 대기 상태도 초기화
    remainingTime = Duration(hours: 2);
    selectedBranchName = null;
    selectedBranchAddress = null;
    selectedBranchContact = null;
    _timer?.cancel(); // 타이머 취소
    notifyListeners(); // 상태 업데이트
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
