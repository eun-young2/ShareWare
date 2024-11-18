import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'config.dart';

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController emailController = TextEditingController();
  bool isSubmitting = false;
  String? message;

  Future<void> sendPasswordResetEmail() async {
    setState(() {
      isSubmitting = true;
      message = null;
    });

    final String apiUrl = '${Config.local}/user/forgot-password';  // 비밀번호 찾기 API URL

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': emailController.text,
      }),
    );

    setState(() {
      isSubmitting = false;
    });

    if (response.statusCode == 200) {
      setState(() {
        message = '비밀번호 재설정 이메일이 발송되었습니다.';
      });
    } else {
      setState(() {
        message = '이메일 전송에 실패했습니다. 다시 시도해주세요.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Color customGreen = Color(0xFFAFD485); // 변경된 초록색
    Color textColor = Colors.black; // 이메일 보내기 텍스트 색상

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '비밀번호 찾기',
          style: TextStyle(color: Colors.black), // 상단 제목 검은색
        ),
        backgroundColor: Colors.white, // 상단 바 배경 하얀색
        iconTheme: IconThemeData(color: Colors.black), // 뒤로가기 버튼 검은색
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '이메일을 입력하여 비밀번호 재설정 링크를 받으세요.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: '이메일',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: isSubmitting ? null : sendPasswordResetEmail,
              style: ElevatedButton.styleFrom(
                backgroundColor: customGreen, // 버튼 색상
                minimumSize: Size(double.infinity, 50),
              ),
              child: isSubmitting
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text(
                      '이메일 보내기',
                      style: TextStyle(color: textColor), // 텍스트 색상 검은색
                    ),
            ),
            SizedBox(height: 20),
            if (message != null)
              Text(
                message!,
                style: TextStyle(
                  fontSize: 16,
                  color: message == '비밀번호 재설정 이메일이 발송되었습니다.'
                      ? customGreen // 초록색 메시지
                      : Colors.red, // 오류 메시지
                ),
              ),
          ],
        ),
      ),
    );
  }
}
