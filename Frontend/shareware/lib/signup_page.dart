import 'package:flutter/material.dart';
import 'package:flutter_application_33/login_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'config.dart';

class SignupPage extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  // 회원가입 API 호출 함수
  Future<void> signup(context) async {
    // API URL
    final String apiUrl = '${Config.local}/user/signup';

    // API 호출
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'name': nameController.text,
        'userid': usernameController.text,
        'password': passwordController.text,
        'phone_number': phoneController.text
      }),
    );

    // 응답 처리
    if (response.statusCode == 200) {
      // 회원가입 성공 시
      print('회원가입 성공');
      // 추가 로직 (예: 로그인 페이지로 이동 등)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
      // 로그인 페이지로 이동
    } else {
      // 회원가입 실패 시
      print('회원가입 실패: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(  // 화면 중앙에 배치
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,  // 세로 방향 가운데 정렬
              crossAxisAlignment: CrossAxisAlignment.center,  // 가로 방향 가운데 정렬
              children: [
                Text(
                  '회원가입',
                  style: TextStyle(
                    fontSize: 24, 
                    fontWeight: FontWeight.bold,
                    color: Colors.black.withOpacity(0.7),  // 연한 텍스트 색상
                  ),
                ),
                SizedBox(height: 20),
                // 이름 입력 필드
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: '이름',
                    labelStyle: TextStyle(color: Colors.black.withOpacity(0.6)),  // 연한 레이블 색상
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFAFD485), width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFAFD485), width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFAFD485), width: 2),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                // 아이디 입력 필드
                TextField(
                  controller: usernameController,
                  decoration: InputDecoration(
                    labelText: '아이디',
                    labelStyle: TextStyle(color: Colors.black.withOpacity(0.6)),  // 연한 레이블 색상
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFAFD485), width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFAFD485), width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFAFD485), width: 2),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                // 비밀번호 입력 필드
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: '비밀번호',
                    labelStyle: TextStyle(color: Colors.black.withOpacity(0.6)),  // 연한 레이블 색상
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFAFD485), width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFAFD485), width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFAFD485), width: 2),
                    ),
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 20),
                // 비밀번호 확인 입력 필드
                TextField(
                  controller: confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: '비밀번호 확인',
                    labelStyle: TextStyle(color: Colors.black.withOpacity(0.6)),  // 연한 레이블 색상
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFAFD485), width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFAFD485), width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFAFD485), width: 2),
                    ),
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 20),
                // 전화번호 입력 필드
                TextField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    labelText: '전화번호',
                    labelStyle: TextStyle(color: Colors.black.withOpacity(0.6)),  // 연한 레이블 색상
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFAFD485), width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFAFD485), width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFAFD485), width: 2),
                    ),
                  ),
                  keyboardType: TextInputType.phone, // 전화번호 입력에 적합한 키보드 타입
                ),
                SizedBox(height: 20),
                // 회원가입 버튼
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFAFD485), // 버튼 배경 색상
                  ),
                  onPressed: () {
                    if (passwordController.text !=
                        confirmPasswordController.text) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('비밀번호가 일치하지 않습니다.')),
                      );
                      return;
                    }
                    // 회원가입 로직
                    signup(context);
                  },
                  child: Text(
                    '회원가입',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                SizedBox(height: 20),
                // 로그인 페이지로 돌아가기 텍스트
                TextButton(
                  onPressed: () {
                    // 로그인 페이지로 돌아가기
                    Navigator.pop(context);
                  },
                  child: Text(
                    '로그인으로 돌아가기',
                    style: TextStyle(color: Color(0xFFAFD485)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
