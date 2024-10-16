import 'package:flutter/material.dart';
import 'package:flutter_application_33/signup_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // 사용자와 관리자를 구분하기 위한 상태 변수
  bool isAdminLogin = false;

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
                    backgroundColor: isAdminLogin ? Colors.grey : Colors.green, // primary 대신 backgroundColor 사용
                  ),
                  child: Text('사용자 로그인'),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isAdminLogin = true; // 관리자 로그인 선택
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isAdminLogin ? Colors.green : Colors.grey, // primary 대신 backgroundColor 사용
                  ),
                  child: Text('관리자 로그인'),
                ),
              ],
            ),
            
            SizedBox(height: 20),
            
            TextField(
              decoration: InputDecoration(
                labelText: isAdminLogin ? '관리자 아이디' : '아이디', // 선택에 따라 레이블 변경
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextField(
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
              },
              child: Text('로그인'),
            ),
            TextButton(
              onPressed: () {
                // 회원가입 페이지로 이동
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignupPage()), // SignupPage로 이동
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
