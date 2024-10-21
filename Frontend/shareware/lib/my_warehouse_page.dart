import 'package:flutter/material.dart';
import 'manage_items_page.dart';

class MyWarehousePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 화면의 너비를 가져옴
    final double screenWidth = MediaQuery.of(context).size.width;

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
                  // 로그인하기 > 텍스트 스타일 (더 큰 폰트)
                  GestureDetector(
                    onTap: () {
                      // 로그인 페이지로 이동하는 기능 추가 가능
                    },
                    child: Text(
                      '로그인하기 >',
                      style: TextStyle(
                        fontSize: 22, // 더 큰 폰트 크기
                        color: Colors.blue,
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
                // 내 물품 관리 페이지로 이동
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ManageItemsPage(selectedIndex: 3), // '마이창고' 탭의 인덱스 전달
                  ),
                );
              },
            ),
            Divider(),
            ListTile(
              title: Text('QR 발급 내역'),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                // QR 발급 내역 페이지로 이동하는 기능 추가 가능
              },
            ),
            Divider(),
            ListTile(
              title: Text('결제 관리'),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                // 결제 관리 페이지로 이동하는 기능 추가 가능
              },
            ),
            SizedBox(height: 30),
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
          ],
        ),
      ),
    );
  }
}
