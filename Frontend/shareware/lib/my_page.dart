import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';

class MyPage extends StatefulWidget {
  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  // 로그인 상태 확인
  void _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (mounted) {
      // 위젯이 여전히 활성화 상태인지 확인
      setState(() {
        _isLoggedIn = token != null; // 토큰이 있으면 로그인 상태
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('마이페이지'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 내 정보 섹션
            Text(
              '내 정보',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Divider(),
            ListTile(
              title: Text('프로필 및 계정'),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                // 프로필 및 계정 페이지로 이동하는 기능 추가 가능
              },
            ),
            Divider(),
            SizedBox(height: 10),
            // 설정 섹션
            Text(
              '설정',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Divider(),
            ListTile(
              title: Text('알림설정'),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                // 알림 권한 허용/삭제 로직
              },
            ),
            Divider(),
            ListTile(
              title: Text('위치서비스'),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                // 위치 접근 권한 허용/삭제 로직
              },
            ),
            Divider(),
            Spacer(), // 남은 공간을 차지하여 로그아웃 버튼을 하단에 고정
            SizedBox(
              width: double.infinity, // 버튼 가로 크기를 화면 가득 채움
              child: ElevatedButton(
                onPressed: () async {
                  if (_isLoggedIn) {
                    // 로그아웃 처리 로직
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    await prefs.remove('token'); // 저장된 토큰 삭제
                    print('로그아웃 토큰 삭제');
                    if (mounted) {
                      setState(() {
                        _isLoggedIn = false;
                      });
                    }
                  } else {
                    if (mounted) {
                      // 로그인 페이지로 이동
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    }
                  }
                },
                child: Text(
                  _isLoggedIn ? '로그아웃' : '로그인', // 로그인 여부에 따라 버튼 변경
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 15.0), // 세로 여백
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  backgroundColor: _isLoggedIn
                      ? Color(0xFF4A4A4A)
                      : Color(0xFFAFD485), // 배경 색상
                  foregroundColor:
                      _isLoggedIn ? Colors.black : Colors.white, // 글씨 색상
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
