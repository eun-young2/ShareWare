import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';
import 'config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/auth_provider.dart';
import 'main.dart';
import 'signup_page.dart';
import 'admin_main_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isAdminLogin = false;  // 기본값: 사용자 로그인
  bool isUserLoginSelected = true;  // 기본값: 사용자 로그인 버튼 선택
  bool isAdminLoginSelected = false; // 기본값: 관리자 로그인 버튼 비선택

  Color customGreen = Color(0xFFAFD485); // 네이버의 초록색
  Color customGray = Color(0xFFB3B3B3); // 네이버 스타일의 회색

  Future<void> login() async {
    final String apiUrl = '${Config.local}/user/login';

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

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print("API Response: $data");

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.login(data['token']);

      if (data['userId'] != null) {
        await authProvider.setUserId(data['userId']);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('사용자 ID가 응답에 없습니다.')),
        );
        return;
      }

      // 로그인 후 페이지 전환
      if (!isAdminLogin && data['role'] == 'admin') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('사용자로 로그인할 수 없습니다.')),
        );
      } else if (isAdminLogin && data['role'] != 'admin') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('관리자로 로그인할 수 없습니다.')),
        );
      } else {
        print('로그인 성공');
        if (isAdminLogin && data['role'] == 'admin') {
          // 관리자로 로그인 시 AdminMainPage로 이동
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AdminMainPage()),
          );
        } else {
          // 일반 사용자로 로그인 시 MainPage로 이동
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MainPage()),
          );
        }
      }
    }
  }

  Future<void> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token != null) {
      final response = await http.get(
        Uri.parse('${Config.local}/user/protected'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        print('로그인 상태입니다: ${response.body}');
        // 로그인 상태이지만 메인 페이지로 이동하지 않음
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
    checkLoginStatus(); // 로그인 상태 확인
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white, // 네이버 느낌의 흰색 배경
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black), // 검은색 화살표
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          '로그인',
          style: TextStyle(
            color: Colors.black, // 검은색 로그인 텍스트
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0, // 그림자 없애기
      ),
      body: SingleChildScrollView( // 바텀 오버플로우를 방지하는 ScrollView 추가
        padding: const EdgeInsets.all(16.0),
        child: Center( // 모든 위젯을 중앙에 배치
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 네이버 스타일의 로고 추가
              Image.asset(
                'assets/ShareWare_logo.png', // 로고 이미지
                width: 120,
                height: 120,
              ),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isAdminLogin = false;
                        isUserLoginSelected = true;
                        isAdminLoginSelected = false;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isUserLoginSelected ? customGreen : Colors.white, // 버튼 색상 변경
                      minimumSize: Size(180, 50), // 가로 길이와 세로 길이 조정
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: customGreen, width: 1.5), // 초록색 테두리
                        borderRadius: BorderRadius.circular(8.0), // 둥근 모서리
                      ),
                    ),
                    child: Text(
                      '사용자 로그인',
                      style: TextStyle(color: isUserLoginSelected ? Colors.white : Colors.black), // 텍스트 색상 변경
                    ),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isAdminLogin = true;
                        isAdminLoginSelected = true;
                        isUserLoginSelected = false;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isAdminLoginSelected ? customGreen : Colors.white, // 버튼 색상 변경
                      minimumSize: Size(180, 50), // 가로 길이와 세로 길이 조정
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: customGreen, width: 1.5), // 초록색 테두리
                        borderRadius: BorderRadius.circular(8.0), // 둥근 모서리
                      ),
                    ),
                    child: Text(
                      '관리자 로그인',
                      style: TextStyle(color: isAdminLoginSelected ? Colors.white : Colors.black), // 텍스트 색상 변경
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              // 아이디 입력 필드
              TextField(
                controller: usernameController,
                style: TextStyle(color: Colors.black), // 아이디 텍스트 색상 검은색
                decoration: InputDecoration(
                  labelText: isAdminLogin ? '관리자 아이디' : '아이디',
                  labelStyle: TextStyle(color: Colors.black), // 네이버 스타일의 초록색
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: customGreen, width: 1.5), // 항상 초록색 테두리
                  ),
                ),
              ),
              SizedBox(height: 20),
              // 비밀번호 입력 필드
              TextField(
                controller: passwordController,
                style: TextStyle(color: Colors.black), // 비밀번호 텍스트 색상 검은색
                decoration: InputDecoration(
                  labelText: '비밀번호',
                  labelStyle: TextStyle(color: Colors.black), // 네이버 스타일의 초록색
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: customGreen, width: 1.5), // 항상 초록색 테두리
                  ),
                ),
                obscureText: true,
              ),
              SizedBox(height: 20),
              // 로그인 버튼 (사용자, 관리자 동일하게 통일)
              ElevatedButton(
                onPressed: () {
                  login();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white, // 흰색 버튼 배경
                  foregroundColor: customGreen, // 버튼 텍스트 색상 (초록색)
                  padding: EdgeInsets.symmetric(vertical: 14.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    side: BorderSide(color: customGreen, width: 1.5), // 초록색 테두리
                  ),
                  minimumSize: Size(double.infinity, 50), // 버튼을 화면 너비에 맞게 길게 만들기
                ),
                child: Text(
                  '로그인',
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
              ),
              SizedBox(height: 20),
              // 회원가입 버튼
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignupPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white, // 흰색 버튼 배경
                  foregroundColor: customGreen, // 버튼 텍스트 색상 (초록색)
                  padding: EdgeInsets.symmetric(vertical: 14.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    side: BorderSide(color: customGreen, width: 1.5), // 초록색 테두리
                  ),
                  minimumSize: Size(double.infinity, 50), // 버튼을 화면 너비에 맞게 길게 만들기
                ),
                child: Text(
                  '회원가입',
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
