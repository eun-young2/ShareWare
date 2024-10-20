import 'package:flutter/material.dart';
import 'package:flutter_application_33/my_page.dart';
import 'package:flutter_application_33/my_warehouse_page.dart';
import 'package:flutter_application_33/qr_page.dart';
import 'package:flutter_application_33/qr_provider.dart';
import 'package:provider/provider.dart';

import 'package:flutter_application_33/rtsp_stream.dart';
import 'package:flutter_application_33/storage_select.dart'; // 이 경로가 올바른지 확인하세요.
import 'package:flutter_application_33/login_page.dart'; // 로그인 페이지 경로
import 'package:flutter_application_33/signup_page.dart'; // 회원가입 페이지 경로
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "assets/.env"); // 파일 이름이 루트에 있는 경우
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => QRProvider()),
      ],
      child: SharewareApp(),
    ),
  );
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
    // 사진 추가 가능
  ];

  int _selectedIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      MainPageContent(warehouseImages: warehouseImages),
      KakaoMapTest(), // 창고 찾기 페이지를 두 번째로 추가
      QRPage(),
      MyWarehousePage(),
      // MyApp(), // 기존 MyPage() (my_page.dart) -> rtsp_stream.dart 파일로 연결되게 바꿔놨음
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shareware'),
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            'assets/ShareWare_logo.png', // 경로를 정확하게 확인하세요
            fit: BoxFit.contain,
          ),
        ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 로그인 및 회원가입 화면으로 이동하는 다이얼로그
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('로그인 또는 회원가입'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                        );
                      },
                      child: Text('로그인'),
                    ),
                    ElevatedButton(
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
              );
            },
          );
        },
        child: Icon(Icons.login),
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
                          MaterialPageRoute(
                              builder: (context) => KakaoMapTest()),
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
                          MaterialPageRoute(
                              builder: (context) => KakaoMapTest()),
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
                      onPressed: () {}, // 이용안내
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
                      onPressed: () {}, // QR 입장코드 발급
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
                      onPressed: () {}, // 고객센터
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
                        text: '이용이 가능합니다!',
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10.0),
                Text(
                  '앱에서 다양한 창고를 쉽게 찾아보세요.',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
