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
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.isLoggedIn) {
      authProvider.getProfile(); // 로그인된 상태라면 프로필 정보를 불러옴
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final profile = authProvider.profile;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
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
        child: showProfile
            ? _buildProfileSection(authProvider)
            : _buildMainSection(authProvider, profile),
      ),
    );
  }

  Widget _buildMainSection(AuthProvider authProvider, Map<String, dynamic> profile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (authProvider.isLoggedIn) _buildGreetingSection(profile),
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
          height: 55,
          child: ElevatedButton(
            onPressed: () {
              if (authProvider.isLoggedIn) {
                authProvider.logout(context);
              } else {
                Navigator.push(
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
                  ? Color(0xFF9A9A9A)
                  : Color(0xFFAFD485),
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
Widget _buildGreetingSection(Map<String, dynamic> profile) {
  return Container(
    padding: EdgeInsets.all(16),
    margin: EdgeInsets.only(bottom: 16),
    color: Color(0xFFF2F2F2), // 연한 회색 배경
    width: double.infinity, // 가로로 꽉 차도록 설정
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '안녕하세요,',
          style: TextStyle(
            fontSize: 20, // 전체적으로 글자 크기 키움
            color: Colors.black54,
          ),
        ),
        SizedBox(height: 4), // 계행을 위한 간격
        Row(
          children: [
            Text(
              '${profile['user_name'] ?? '회원님'}', // 이름 부분
              style: TextStyle(
                fontSize: 26, // 이름 폰트 크기 더 크게
                fontWeight: FontWeight.bold, // 이름을 진하게 설정
                color: Colors.blue, // 이름 색을 어두운 색으로 설정
              ),
            ),
            Text(
              '님!',
              style: TextStyle(
                fontSize: 20, // '님' 부분은 원래 크기 유지
                color: Colors.black54, // '님'은 원래 색상 유지
              ),
            ),
          ],
        ),
      ],
    ),
  );
}


  Widget _buildProfileSection(AuthProvider authProvider) {
    final profile = authProvider.profile;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '프로필 및 계정',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Divider(),
        _buildProfileItem('이메일', profile['user_id'] ?? 'example@example.com'),
        _buildProfileItem('이름', profile['user_name'] ?? '홍길동'),
        _buildProfileItem(
          '휴대폰 번호',
          profile['user_phone'] ?? '010-1234-5678',
          trailing: TextButton(
            onPressed: () {
              _showPhoneChangeModal(context);
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
          onTap: () => _showDeleteAccountDialog(context, authProvider),
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
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
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

void _showPhoneChangeModal(BuildContext context) {
  TextEditingController phoneController = TextEditingController();
  final authProvider = Provider.of<AuthProvider>(context, listen: false);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom, // 키보드 높이에 맞춰 자동 조절
          left: 16.0,
          right: 16.0,
          top: 16.0,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '휴대폰 번호 변경',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(labelText: '새 휴대폰 번호 입력'),
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('취소'),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () async {
                    // 휴대폰 번호 변경 로직 추가
                    String newPhoneNumber = phoneController.text;
                    bool success =
                        await authProvider.updatePhoneNumber(newPhoneNumber);

                    if (success) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('휴대폰 번호가 성공적으로 변경되었습니다.')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('휴대폰 번호 변경에 실패했습니다.')),
                      );
                    }
                  },
                  child: Text('변경'),
                ),
              ],
            ),
            SizedBox(height: 16),
          ],
        ),
      );
    },
  );
}

void _showDeleteAccountDialog(BuildContext context, AuthProvider authProvider) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('회원 탈퇴'),
        content: Text('정말 탈퇴하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('아니요'),
          ),
          TextButton(
            onPressed: () async {
              // 다이얼로그 닫기
              //Navigator.of(context).pop();

              // 탈퇴 요청 처리
              bool success = await authProvider.deleteAccount();

              if (success) {
                // 프레임이 완전히 끝난 후 페이지 이동
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                    (Route<dynamic> route) => false,
                  );

                  // 스낵바 표시
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('회원 탈퇴가 완료되었습니다.')),
                  );
                });
              } else {
                // 탈퇴 실패 시 스낵바 표시
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('회원 탈퇴에 실패했습니다.')),
                );
              }
            },
            child: Text('예', style: TextStyle(color: Colors.red)),
          ),
        ],
      );
    },
  );
}
