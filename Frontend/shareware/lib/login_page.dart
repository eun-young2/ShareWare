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
import 'forgot_password_page.dart'; // 비밀번호 찾기 페이지 import

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isAdminLogin = false;
  bool isUserLoginSelected = true;
  bool isAdminLoginSelected = false;
  bool isPasswordVisible = false; // 비밀번호 보이기/숨기기 상태

  Color customGreen = Color(0xFFAFD485); // 초록색
  Color customGray = Color(0xFFB3B3B3); // 회색

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
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AdminMainPage()),
          );
        } else {
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
    checkLoginStatus();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          '로그인',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: screenHeight * 0.05),
              Image.asset(
                'assets/ShareWare_logo.png',
                width: screenWidth * 0.3,
                height: screenWidth * 0.3,
              ),
              SizedBox(height: screenHeight * 0.03),
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
                      backgroundColor:
                          isUserLoginSelected ? customGreen : Colors.white,
                      minimumSize: Size(screenWidth * 0.4, screenHeight * 0.06),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: customGreen, width: 1.5),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: Text(
                      '사용자 로그인',
                      style: TextStyle(
                        color:
                            isUserLoginSelected ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.05),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isAdminLogin = true;
                        isAdminLoginSelected = true;
                        isUserLoginSelected = false;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isAdminLoginSelected ? customGreen : Colors.white,
                      minimumSize: Size(screenWidth * 0.4, screenHeight * 0.06),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: customGreen, width: 1.5),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: Text(
                      '관리자 로그인',
                      style: TextStyle(
                        color:
                            isAdminLoginSelected ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.03),
              TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  labelText: isAdminLogin ? '관리자 아이디' : '아이디',
                  labelStyle: TextStyle(color: Colors.grey[700]), // 기본 색상 연한 회색
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: customGreen, width: 1.5), // 테두리 색상 변경
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: customGreen, width: 2.0), // 포커스 시 테두리 색상 변경
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              TextField(
                controller: passwordController,
                obscureText: !isPasswordVisible, // 비밀번호 보이기/숨기기
                decoration: InputDecoration(
                  labelText: '비밀번호',
                  labelStyle: TextStyle(color: Colors.grey[700]), // 기본 색상 연한 회색
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: customGreen, width: 1.5), // 테두리 색상 변경
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: customGreen, width: 2.0), // 포커스 시 테두리 색상 변경
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      color: Colors.grey[500],
                    ),
                    onPressed: () {
                      setState(() {
                        isPasswordVisible = !isPasswordVisible;
                      });
                    },
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
              ElevatedButton(
                onPressed: login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: customGreen,
                  padding: EdgeInsets.symmetric(vertical: screenHeight * 0.015),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      side: BorderSide(color: customGreen, width: 1.5)),
                  minimumSize:
                      Size(screenWidth * 0.7, screenHeight * 0.05),
                ),
                child: Text('로그인',
                    style: TextStyle(color: Colors.black, fontSize: 16)),
              ),
              SizedBox(height: screenHeight * 0.02),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ForgotPasswordPage()),
                  );
                },
                child: Text(
                  '비밀번호를 잊으셨나요?',
                  style: TextStyle(color: customGreen),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '계정이 없으신가요?',
                    style: TextStyle(color: Colors.grey),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignupPage()),
                      );
                    },
                    child: Text(
                      '회원가입',
                      style: TextStyle(color: customGreen),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
