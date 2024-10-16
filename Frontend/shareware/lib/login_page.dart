import 'package:flutter/material.dart';
import 'package:flutter_application_33/main.dart';
import 'package:flutter_application_33/signup_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // 사용자와 관리자를 구분하기 위한 상태 변수
  bool isAdminLogin = false;

  // 색상 정의
  Color customGreen = Color(0xFFAFD485); // AFD485 색상
  Color customGray = Color(0xFF4A4A4A); // 4A4A4A 색상

  Future<void> login() async {
    final String apiUrl = 'http://192.168.70.43:3000/user/login'; // 로그인 API URL

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'userid': usernameController.text,
        'password': passwordController.text,
      }),
    );

    // 응답 처리
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // 로그인 성공 및 role 체크
      if (isAdminLogin && data['role'] != 'admin') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('관리자로 로그인할 수 없습니다.')),
        );
      } else {
        print('로그인 성공');
        // 추가 로직 (예: 대시보드로 이동)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainPage()),
        ); // 대시보드로 이동
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그인 실패')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '로그인',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),

            // 사용자와 관리자 선택 버튼
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isAdminLogin = false; // 사용자 로그인 선택
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isAdminLogin
                        ? customGray
                        : customGreen, // primary 대신 backgroundColor 사용
                  ),
                  child: Text(
                    '사용자 로그인',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isAdminLogin = true; // 관리자 로그인 선택
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isAdminLogin
                        ? customGreen
                        : customGray, // primary 대신 backgroundColor 사용
                  ),
                  child: Text('관리자 로그인', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),

            SizedBox(height: 20),

            TextField(
              controller: usernameController,
              decoration: InputDecoration(
                labelText: isAdminLogin ? '관리자 아이디' : '아이디', // 선택에 따라 레이블 변경
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: '비밀번호',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // 로그인 로직 (사용자/관리자에 따른 처리 추가 예정)
                login();
              },
              child: Text('로그인'),
            ),
            TextButton(
              onPressed: () {
                // 회원가입 페이지로 이동
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SignupPage()), // SignupPage로 이동
                );
              },
              child: Text('회원가입'),
            ),
          ],
        ),
      ),
    );
  }
}
