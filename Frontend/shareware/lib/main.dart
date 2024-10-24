import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'providers/auth_provider.dart'; // 자동로그인관리 provider
import 'my_page.dart';
import 'my_warehouse_page.dart'; // 마이창고탭
import 'qr_page.dart'; // qr탭
import 'providers/qr_provider.dart'; // qr전역관리 provider
import 'rtsp_stream.dart';
import 'storage_select.dart'; // 창고찾기지도탭
import 'login_page.dart'; // 로그인 페이지
import 'signup_page.dart'; // 회원가입 페이지
import 'bottom_nav_bar.dart';

import 'package:flutter_application_33/rtsp_stream.dart';

import 'rtsp.dart'; // rtsp 스트리밍 페이지 가져오기

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "assets/.env");
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
        primaryColor: Color(0xFFAFD485),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: Color(0xFF4A4A4A), // accentColor -> secondary로 대체
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(fontSize: 14, color: Color(0xFF4A4A4A)),
          bodyMedium: TextStyle(fontSize: 14, color: Color(0xFF4A4A4A)), // bodyText2를 bodyMedium으로 수정
        ),
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
      KakaoMapTest(), // 창고 찾기 페이지로 이동
      QRPage(),
      MyWarehousePage(),
      // MyApp(), // 기존 MyPage() (my_page.dart) -> rtsp_stream.dart 파일로 연결되게 바꿔놨음
    ];
  }

  // 이 함수는 BottomNavigationBar에서 선택된 탭의 인덱스를 기반으로 페이지를 전환하는 역할
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // 선택된 인덱스 업데이트
    });
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
            'assets/ShareWare_logo.png',
            fit: BoxFit.contain,
          ),
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex, // 선택된 페이지 인덱스
        children: _pages, // IndexedStack으로 페이지 전환 처리
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex, // 현재 선택된 탭의 인덱스 전달
        onTap: _onItemTapped, // 탭이 클릭되었을 때 호출
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
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
            // 창고 찾기 버튼
            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFAFD485),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 20.0),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => KakaoMapTest()),
                    );
                  },
                  child: Text(
                    '창고 찾기',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF4A4A4A),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.0),
            // 이용 안내 및 기타 버튼
            SizedBox(
              height: 90.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFAFD485),
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
                        backgroundColor: Color(0xFFAFD485),
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
                        backgroundColor: Color(0xFFAFD485),
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
                SizedBox(height: 20.0),
                // 버튼 추가: RTSP 스트리밍 페이지로 이동
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              RTSPVideoScreen()), // RTSP 페이지로 이동
                    );
                  },
                  child: Text('RTSP 스트리밍 페이지로 이동'),
                ),
                SizedBox(height: 20.0),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
