import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';
import 'config.dart';
import 'package:shared_preferences/shared_preferences.dart'; // SharedPreferences 추가
import 'providers/auth_provider.dart'; // AuthProvider 추가
import 'main.dart';
import 'signup_page.dart';
import 'admin_main_page.dart'; // 추가

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
    final String apiUrl = '${Config.local}/user/login'; // 로그인 API URL

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

      // API 응답 로그 출력
      print("API Response: $data"); // 여기서 응답을 출력합니다.

      // 로그인 성공 시
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.login(data['token']); // AuthProvider를 통해 토큰 저장

      // userId가 null인지 체크
      if (data['userId'] != null) {
        await authProvider.setUserId(data['userId']); // 사용자 ID 저장
      } else {
        // userId가 null인 경우 처리
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('사용자 ID가 응답에 없습니다.')),
        );
        return; // 더 이상 진행하지 않음
      }

      // 로그인 성공 및 role 체크
      if (isAdminLogin && data['role'] != 'admin') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('관리자로 로그인할 수 없습니다.')),
        );
      } else {
        print('로그인 성공');
        // 추가 로직 (예: 대시보드로 이동)
        if (isAdminLogin) {
          // 관리자로 로그인 시 관리자 메인 페이지로 이동
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AdminMainPage()),
          );
        } else {
          // 일반 사용자 로그인 시 메인 페이지로 이동
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MainPage()),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그인 실패')),
      );
    }
  }

  // 앱 실행 시 로그인 상태 확인
  Future<void> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token != null) {
      final response = await http.get(
        Uri.parse('${Config.local}/user/protected'), // 보호된 API 경로
        headers: {
          'Authorization': 'Bearer $token', // 토큰을 헤더에 포함
        },
      );

      if (response.statusCode == 200) {
        print('로그인 상태입니다: ${response.body}');
        // 상태가 200일 때만 MainPage로 이동
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainPage()),
        );
      } else {
        print('로그인되지 않음: ${response.body}');
      }
    } else {
      print('저장된 토큰이 없습니다. 로그인이 필요합니다.');
    }
  }

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.checkLoginStatus(); // AuthProvider를 통해 로그인 상태 확인
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // 뒤로 가기 버튼 동작
          },
        ),
        title: Text('로그인'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
                    backgroundColor: isAdminLogin ? customGray : customGreen,
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
                        : customGray,
                  ),
                  child: Text('관리자 로그인', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),

            SizedBox(height: 20),

            TextField(
              controller: usernameController,
              decoration: InputDecoration(
                labelText: isAdminLogin ? '관리자 아이디' : '아이디',
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
                login(); // 로그인 로직
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
