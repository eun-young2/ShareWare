import 'package:flutter/material.dart';
import 'package:flutter_application_33/my_page.dart';
import 'package:flutter_application_33/my_warehouse_page.dart';
import 'package:flutter_application_33/qr_page.dart';
import 'package:flutter_application_33/storage_select.dart'; // 이 경로가 올바른지 확인하세요.

void main() {
  runApp(SharewareApp());
}

class SharewareApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shareware',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final List<String> warehouseImages = [
    'assets/warehouse1.jpg',
   
  ];

  int _selectedIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      MainPageContent(warehouseImages: warehouseImages),
      StorageSelectPage(), // 창고 찾기 페이지를 두 번째로 추가
      QRPage(),
      MyWarehousePage(),
      MyPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shareware'),
        centerTitle: true,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'HOME',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map), // 지도 모양 이모티콘 추가
            label: '창고찾기',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code),
            label: 'QR입장',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: '마이창고',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '마이페이지',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}

class MainPageContent extends StatelessWidget {
  final List<String> warehouseImages;

  MainPageContent({required this.warehouseImages});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 이미지 슬라이드
            Container(
              height: 200.0,
              child: PageView.builder(
                itemCount: warehouseImages.length,
                pageSnapping: true,
                controller: PageController(viewportFraction: 0.8),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15.0),
                      child: Image.asset(
                        warehouseImages[index],
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 10.0),
            // 검색창
            Container(
              width: MediaQuery.of(context).size.width * 0.9,
              child: TextField(
                decoration: InputDecoration(
                  hintText: '창고 검색',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search),
                ),
                style: TextStyle(fontSize: 14),
              ),
            ),
            SizedBox(height: 20.0),
            // 버튼들
            SizedBox(
              height: 130.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 20.0),
                      ),
                      onPressed: () {
                        // 창고찾기 버튼 클릭 시 StorageSelectPage로 이동
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => StorageSelectPage()),
                        );
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            '단기 이용하며\n수시로 짐을 찾고 싶다면',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 5),
                          Text(
                            '도심형 창고 찾기',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 20.0),
                      ),
                      onPressed: () {
                        // 외각형 창고 찾기 버튼 클릭 시 StorageSelectPage로 이동
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => StorageSelectPage()),
                        );
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            '차량으로 이동하여\n큰 짐을 보관하고 싶다면',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 5),
                          Text(
                            '외각형 창고 찾기',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.0),
            SizedBox(
              height: 90.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 30.0),
                      ),
                      onPressed: () {},
                      child: Text('이용안내'),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 30.0),
                      ),
                      onPressed: () {},
                      child: Text('QR 입장코드 발급'),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 30.0),
                      ),
                      onPressed: () {},
                      child: Text('고객센터'),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '쉐어웨어',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.orange,
                        ),
                      ),
                      TextSpan(
                        text: '만의\n스마트한 ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      TextSpan(
                        text: 'AI 무인관제',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10.0),
                Text('V 이용시간 외 침입을 감지하여 경고 알림발송'),
                SizedBox(height: 5.0),
                Text('V 안전한 물품 보관'),
                SizedBox(height: 5.0),
                Text('V 다양한 창고 옵션'),
                SizedBox(height: 5.0),
                Text('V 빠른 고객 지원'),
              ],
            ),
            SizedBox(height: 20.0),
            Text(
              '고객 리뷰',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            SizedBox(height: 10.0),
            _buildReview('assets/profile1.png', '이순신', 5, '정말 유용하게 잘 사용하고 있습니다.'),
            _buildReview('assets/profile2.png', '김유신', 4, '가격이 저렴하고 접근성이 좋습니다.'),
            _buildReview('assets/profile3.png', '홍길동', 5, '고객 서비스가 매우 친절합니다.'),
          ],
        ),
      ),
    );
  }

  Widget _buildReview(String imagePath, String name, int rating, String comment) {
    return Row(
      children: [
        CircleAvatar(
          radius: 25.0,
          backgroundImage: AssetImage(imagePath),
        ),
        SizedBox(width: 10.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Row(
                children: List.generate(rating, (index) => Icon(Icons.star, color: Colors.orange)),
              ),
              Text(comment),
            ],
          ),
        ),
      ],
    );
  }
}
