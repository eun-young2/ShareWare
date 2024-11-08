import 'package:flutter/material.dart';
import 'cctv_page_1.dart'; // CCTV 페이지 추가
import 'reservation_page.dart'; // 예약 관리 페이지 추가
import 'storage_management_page.dart'; // 창고 관리 페이지 추가
import 'alarm_page.dart'; // 알람 페이지 추가 (이 페이지를 생성해야 합니다)
import 'config.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';

class AdminMainPage extends StatefulWidget {
  @override
  _AdminMainPageState createState() => _AdminMainPageState();
}

class _AdminMainPageState extends State<AdminMainPage> {
  int _selectedIndex = 0;

  // 페이지 목록
  final List<Widget> _pages = [
    DashboardPage(), // 대시보드 페이지
    CCTVPage(),
    ReservationPage(), // 예약 관리 페이지
    StorageManagementPage(), // 창고 관리 페이지 추가
    AlarmPage(), // 알람 페이지 추가
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // 뒤로가기 동작 차단
      child: Scaffold(
        appBar: AppBar(
          title: Center(
            child: Text('ShareWare'),
          ),
          automaticallyImplyLeading: false,
        ),
        body: IndexedStack(
          index: _selectedIndex, // 선택된 인덱스에 해당하는 페이지만 표시
          children: _pages, // 페이지 리스트
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.dashboard), label: '대시보드'), // 대시보드 아이콘
            BottomNavigationBarItem(
                icon: Icon(Icons.camera), label: 'CCTV'), // CCTV 아이콘
            BottomNavigationBarItem(
                icon: Icon(Icons.settings), label: '예약 관리'), // 예약 관리 아이콘
            BottomNavigationBarItem(
                icon: Icon(Icons.warehouse), label: '창고 관리'), // 창고 관리 아이콘
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
        ),
      ),
    );
  }
}

// 대시보드 페이지
class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int monthlyVisitors = 0;
  int dailyVisitors = 0;
  String monthlyChange = "+0%";
  String dailyChange = "+0%";

  @override
  void initState() {
    super.initState();
    fetchVisitorStats(); // 페이지 초기화 시 방문객 통계 데이터를 가져옴
  }

  // 방문객 통계를 가져오는 함수
  Future<void> fetchVisitorStats() async {
    // AuthProvider로부터 토큰 가져오기
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;

    final url = '${Config.local}/reserv/visitor-stats';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        print('Monthly Change: ${data['monthly_change']}');
        print('Daily Change: ${data['daily_change']}');

        setState(() {
          monthlyVisitors = data['monthly_visitors']; // 월간 방문객 수 업데이트
          dailyVisitors = data['daily_visitors']; // 금일 방문객 수 업데이트
          monthlyChange = data['monthly_change'] ?? "No Data"; // 월간 변동률 업데이트
          dailyChange = data['daily_change'] ?? "No Data"; // 금일 변동률 업데이트
        });
      } else {
        print(
            'Failed to load visitor stats. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception occurred: $e'); // 예외 발생 시 출력
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단 로고
            Center(
              child: Image.asset(
                'assets/ShareWare_logo.png', // 로고 이미지 경로
                width: 250, // 로고의 너비 설정
                height: 250, // 로고의 높이 설정
              ),
            ),
            SizedBox(height: 16), // 로고와 방문객 통계 카드 사이 간격

            // 월간 방문객과 금일 방문객 카드를 화면 상단에 배치
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: _buildStatisticCard(
                    '월간 방문객',
                    monthlyVisitors.toString(), // API에서 가져온 월간 방문객 수 표시
                    monthlyChange, // API에서 가져온 월간 방문객 변동률 표시
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildStatisticCard(
                    '금일 방문객',
                    dailyVisitors.toString(), // API에서 가져온 금일 방문객 수 표시
                    dailyChange, // API에서 가져온 금일 방문객 변동률 표시
                  ),
                ),
              ],
            ),
            SizedBox(height: 30), // 통계 카드와 버튼들 사이 간격

            // 버튼들을 가로로 배치
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: _buildNavigationButton(
                    context,
                    'CCTV 관리',
                    Icons.camera_alt,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CCTVPage()),
                      );
                    },
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildNavigationButton(
                    context,
                    '예약 관리',
                    Icons.schedule,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ReservationPage()),
                      );
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 16), // 첫 번째 버튼 행과 두 번째 버튼 행 사이 간격

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: _buildNavigationButton(
                    context,
                    '창고 관리',
                    Icons.warehouse,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => StorageManagementPage()),
                      );
                    },
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildNavigationButton(
                    context,
                    '알람 확인',
                    Icons.notifications_active,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AlarmPage()),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticCard(String title, String value, String change) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: Colors.grey)),
          SizedBox(height: 8),
          Text(value,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 4),
          Text(change,
              style: TextStyle(
                  color: change.contains('-') ? Colors.red : Colors.green)),
        ],
      ),
    );
  }

  // 버튼을 생성하는 함수 (아이콘 추가)
  Widget _buildNavigationButton(BuildContext context, String label,
      IconData icon, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16), // 모서리를 둥글게
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3), // 그림자 위치
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Color(0xFFAFD485)), // 아이콘 추가
            SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
