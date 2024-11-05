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

  bool isAdminLogin = false;

  Color customGreen = Color(0xFFAFD485);
  Color customGray = Color(0xFF4A4A4A);

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

    // 여기서 현재 페이지의 타입에 따라 이동할 페이지를 결정합니다.
    if (isAdminLogin && data['role'] != 'admin') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('관리자로 로그인할 수 없습니다.')),
      );
    } else {
      print('로그인 성공');
      // 기본적으로 메인 페이지로 이동
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainPage()),
      );
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('로그인 실패')),
    );
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
        // (상태 업데이트가 필요한 경우에만 수행)
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('로그인'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isAdminLogin = false; 
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
                      isAdminLogin = true; 
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isAdminLogin ? customGreen : customGray,
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
                login(); 
              },
              child: Text('로그인'),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignupPage()),
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
