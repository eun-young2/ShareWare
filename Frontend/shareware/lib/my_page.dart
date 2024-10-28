import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'login_page.dart';
import 'providers/auth_provider.dart';

class MyPage extends StatefulWidget {
  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  bool showProfile = false;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(showProfile ? '프로필' : '마이페이지'),
        leading: showProfile
            ? IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    showProfile = false;
                  });
                },
              )
            : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: showProfile ? _buildProfileSection() : _buildMainSection(authProvider),
      ),
    );
  }

  Widget _buildMainSection(AuthProvider authProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '내 정보',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Divider(),
        ListTile(
          title: Text('프로필 및 계정'),
          trailing: Icon(Icons.arrow_forward_ios),
          onTap: () {
            setState(() {
              showProfile = true;
            });
          },
        ),
        Divider(),
        SizedBox(height: 10),
        Text(
          '설정',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Divider(),
        ListTile(
          title: Text('알림설정'),
          trailing: Icon(Icons.arrow_forward_ios),
          onTap: () {},
        ),
        Divider(),
        ListTile(
          title: Text('위치서비스'),
          trailing: Icon(Icons.arrow_forward_ios),
          onTap: () {},
        ),
        Divider(),
        Spacer(),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              if (authProvider.isLoggedIn) {
                authProvider.logout(context);
              } else {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              }
            },
            child: Text(
              authProvider.isLoggedIn ? '로그아웃' : '로그인',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 15.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              backgroundColor: authProvider.isLoggedIn
                  ? Color(0xFF4A4A4A)
                  : Color(0xFFAFD485),
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '프로필 및 계정',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Divider(),
        _buildProfileItem('이메일', 'example@example.com'),
        _buildProfileItem('이름', '홍길동'),
        _buildProfileItem(
          '휴대폰 번호',
          '010-1234-5678',
          trailing: TextButton(
            onPressed: () {
              // 휴대폰 번호 변경 로직 추가
            },
            child: Text('변경', style: TextStyle(color: Colors.blue)),
          ),
        ),
        Divider(),
        ListTile(
          title: Text(
            '회원탈퇴',
            style: TextStyle(color: Colors.grey),
          ),
          onTap: () {
            // 회원탈퇴 로직 추가
          },
        ),
      ],
    );
  }

  Widget _buildProfileItem(String title, String subtitle, {Widget? trailing}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        SizedBox(height: 4),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            subtitle,
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),
          trailing: trailing,
        ),
        Divider(),
      ],
    );
  }
}
