import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'manage_items_page.dart';
import 'login_page.dart';
import 'providers/auth_provider.dart'; // AuthProvider 추가

class MyWarehousePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 화면의 너비를 가져옴
    final double screenWidth = MediaQuery.of(context).size.width;
    final authProvider = Provider.of<AuthProvider>(context); // AuthProvider 사용

    // 비로그인 상태일 때 AlertDialog 띄우는 함수
    void _showLoginRequiredDialog(BuildContext context) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text('로그인이 필요한 기능입니다.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // 닫기 버튼
                },
                child: Text('닫기'),
              ),
              TextButton(
                onPressed: () {
                  // 로그인 페이지로 이동
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
                child: Text('로그인하기'),
              ),
            ],
          );
        },
      );
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 마이 창고 및 로그인하기 섹션에 배경 추가, 화면 가로로 꽉 차게 설정
            Container(
              width: screenWidth, // 화면 가로로 꽉 차게

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 마이 창고 텍스트
                  Text(
                    '마이 창고',
                    style: TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold), // 굵은 폰트
                  ),
                  SizedBox(height: 10),
                  Divider(color: Colors.grey), // 마이 창고와 로그인하기 사이의 구분선
                  SizedBox(height: 10),

                  // 회색 배경의 컨테이너
                  Container(
                    color: Colors.grey[300],
                    padding: EdgeInsets.all(10), // 내부 여백
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () {
                          // 로그인 페이지로 이동 (로그아웃 상태일 경우에만 가능)
                          if (!authProvider.isLoggedIn) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LoginPage(),
                              ),
                            );
                          }
                        },
                        child: Text(
                          authProvider.isLoggedIn
                              ? '로그인상태(이용중창고정보넣을예정)'
                              : '로그인이 필요한 기능입니다.',
                          style: TextStyle(
                            fontSize: 22, // 더 큰 폰트 크기
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            // 이용 관리 섹션
            Text(
              '이용 관리',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Divider(),
            ListTile(
              title: Text('내 물품 관리'),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                if (!authProvider.isLoggedIn) {
                  _showLoginRequiredDialog(context); // 비로그인 시 다이얼로그 표시
                } else {
                  // 내 물품 관리 페이지로 이동
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ManageItemsPage(selectedIndex: 3), // '마이창고' 탭의 인덱스 전달
                    ),
                  );
                }
              },
            ),
            Divider(),
            ListTile(
              title: Text('QR 발급 내역'),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                if (!authProvider.isLoggedIn) {
                  _showLoginRequiredDialog(context); // 비로그인 시 다이얼로그 표시
                } else {
                  // QR 발급 내역 페이지로 이동하는 로직 추가 가능
                }
              },
            ),
            Divider(),
            ListTile(
              title: Text('결제 관리'),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                if (!authProvider.isLoggedIn) {
                  _showLoginRequiredDialog(context); // 비로그인 시 다이얼로그 표시
                } else {
                  // 결제 관리 페이지로 이동하는 로직 추가 가능
                }
              },
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
