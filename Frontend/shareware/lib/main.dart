import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// 경로 수정 (flutter_application_33이 실제 프로젝트 네임과 일치해야 합니다.)
import 'package:flutter_application_33/my_page.dart';
import 'package:flutter_application_33/my_warehouse_page.dart';
import 'package:flutter_application_33/qr_page.dart';
import 'package:flutter_application_33/qr_provider.dart';
import 'package:flutter_application_33/rtsp_stream.dart';
import 'package:flutter_application_33/storage_select.dart';
import 'package:flutter_application_33/login_page.dart';
import 'package:flutter_application_33/signup_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "assets/.env"); // .env 파일의 위치가 루트 경로에 있는지 확인
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
    // 추가 이미지 경로
  ];

  int _selectedIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      MainPageContent(warehouseImages: warehouseImages),
      KakaoMapTest(), // 창고 찾기 페이지
      QRPage(),
      MyWarehousePage(),
      // MyApp(), // my_page.dart의 메인 페이지
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
            'assets/ShareWare_logo.png', // 이미지 경로 확인
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
            icon: Icon(Icons.map),
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
          // 로그인 및 회원가입 화면 이동
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
          ],
        ),
      ),
    );
  }
}
