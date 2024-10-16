import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async'; // Timer 사용을 위한 import

class QRPage extends StatefulWidget {
  @override
  _QRPageState createState() => _QRPageState();
}

class _QRPageState extends State<QRPage> {
  String? qrData;
  bool isButtonVisible = true; // 버튼의 가시성 상태를 관리하는 변수
  Timer? countdownTimer; // 카운트다운 타이머
  int remainingTime = 3600; // 60분을 초 단위로 설정 (60 * 60)

  Future<void> generateQRCode() async {
    final response = await http.get(Uri.parse('http://10.0.2.2:5000/generate_qr'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        qrData = data['qr_code']; // QR 코드 데이터
        isButtonVisible = false; // QR 코드 발급 후 버튼 숨김
        startCountdown(); // 카운트다운 시작
      });
    } else {
      // 에러 처리
      throw Exception('Failed to load QR code');
    }
  }

  void startCountdown() {
    countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (remainingTime > 0) {
        setState(() {
          remainingTime--; // 1초씩 감소
        });
      } else {
        timer.cancel(); // 타이머 종료
      }
    });
  }

  @override
  void dispose() {
    countdownTimer?.cancel(); // 타이머 해제
    super.dispose();
  }

  String formatTime(int seconds) {
    final hours = (seconds ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((seconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$secs';
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isButtonVisible) // 버튼이 활성화되어 있을 때만 표시
            ElevatedButton(
              onPressed: generateQRCode,
              child: Text('QR 코드 발급'),
            ),
          SizedBox(height: 20),
          qrData != null
              ? Image.memory(base64Decode(qrData!))
              : SizedBox(), // QR 코드가 없을 경우 빈 SizedBox로 대체
          SizedBox(height: 20),
          if (!isButtonVisible) // 버튼이 사라진 후 유효시간 표시
            Column(
              children: [
                Text('유효시간', style: TextStyle(fontSize: 24)),
                Text(formatTime(remainingTime), style: TextStyle(fontSize: 32)),
              ],
            ),
        ],
      ),
    );
  }
}
