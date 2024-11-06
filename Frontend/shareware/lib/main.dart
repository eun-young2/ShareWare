import 'package:flutter/material.dart';
import 'package:flutter_application_33/cctvv_page.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'providers/qr_provider.dart'; // qr전역관리 provider
import 'providers/auth_provider.dart'; // 로그인상태 전역관리 provider
import 'storage_select.dart'; // 창고찾기지도탭
import 'qr_page.dart'; // qr탭
import 'my_warehouse_page.dart'; // 마이창고탭
import 'my_page.dart'; // 마이페이지탭
import 'login_page.dart'; // 로그인 페이지
import 'signup_page.dart'; // 회원가입 페이지
import 'bottom_nav_bar.dart';
import 'payment_page.dart';
import 'rtsp.dart'; // rtsp 스트리밍 페이지 가져오기

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "assets/.env");
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => QRProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
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
          bodyMedium: TextStyle(
            fontSize: 14,
            color: Color(0xFF4A4A4A),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => MainPage(), // 메인 페이지
        '/login': (context) => LoginPage(), // 로그인 페이지
        '/signup': (context) => SignupPage(), // 회원가입 페이지
        '/payment': (context) =>
            PaymentPage(warehouseName: 'Some Warehouse'), // 결제 페이지
        '/storage_select': (context) => KakaoMapTest(), // 창고 찾기 페이지
        '/qr': (context) => QRPage(), // QR 페이지
        '/my_warehouse': (context) => MyWarehousePage(), // 마이 창고 페이지
        '/my_page': (context) => MyPage(), // 마이 페이지
        '/rtsp_stream': (context) => CCTVPage(), // RTSP 스트리밍 페이지
      },
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
      KakaoMapTest(), // 창고 찾기 지도페이지
      QRPage(),
      MyWarehousePage(),
      MyPage(),
    ];
  }

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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 상단 "Shareware" 제목과 로고
            Text(
              'Shareware',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.0),
            // 로고 이미지 (크기 확대)
            Container(
              height: 250.0, // 로고 크기 확대
              width: 250.0,
              child: Image.asset(
                'assets/ShareWare_logo.png', // 로고 이미지 경로
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: 40.0), // 버튼 위 여백 조정
            // 창고 찾기 버튼
            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFAFD485), // 버튼 색상
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/storage_select');
                  },
                  child: Text(
                    '창고 찾기',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 40.0), // 버튼과 하단 문구 사이 간격 조정
            // 기존 설명 문구 유지 및 가운데 정렬
            Center(
              child: Column(
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
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10.0),
                  Text(
                    '앱에서 다양한 창고를 쉽게 찾아보세요.',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20.0),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
