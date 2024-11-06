import 'package:flutter/material.dart';
import 'cctvv_page.dart'; // CCTV 페이지 추가
import 'reservation_page.dart'; // 예약 관리 페이지 추가
import 'storage_management_page.dart'; // 창고 관리 페이지 추가
import 'alarm_page.dart'; // 알람 페이지 추가 (이 페이지를 생성해야 합니다)

void main() {
  runApp(AdminMainPage());
}

class AdminMainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CCTVDashboard(),
    );
  }
}

class CCTVDashboard extends StatefulWidget {
  @override
  _CCTVDashboardState createState() => _CCTVDashboardState();
}

class _CCTVDashboardState extends State<CCTVDashboard> {
  int _selectedIndex = 0;

  // 페이지 목록
  final List<Widget> _pages = [
    DashboardPage(), // 대시보드 페이지
    CCTVPage(), // CCTV 페이지
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
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text('ShareWare'), // 지점 선택 드롭박스를 제거하고 단순히 제목만 표시
        ),
      ),
      body: _pages[_selectedIndex], // 선택된 페이지 표시
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
    );
  }
}

// 대시보드 페이지
class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상단에 로고 추가
          Center(
            child: Image.asset(
              'assets/ShareWare_logo.png', // 로고 이미지 경로
              width: 250, // 로고의 너비 설정
              height: 250, // 로고의 높이 설정
            ),
          ),
          SizedBox(height: 16), // 로고와 방문객 통계 카드 사이 간격
          
          // 월간 방문객과 금일 방문객 카드를 화면 상단으로 배치
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: _buildStatisticCard('월간 방문객', '120', '+5%')),
              SizedBox(width: 16),
              Expanded(child: _buildStatisticCard('금일 방문객', '25', '-10%')),
            ],
          ),
          SizedBox(height: 30),

          // 버튼들을 가로로 2개씩 배치
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // CCTV 버튼
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
              // 예약 관리 버튼
              Expanded(
                child: _buildNavigationButton(
                  context,
                  '예약 관리',
                  Icons.schedule,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ReservationPage()),
                    );
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 창고 관리 버튼
              Expanded(
                child: _buildNavigationButton(
                  context,
                  '창고 관리',
                  Icons.warehouse,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => StorageManagementPage()),
                    );
                  },
                ),
              ),
              SizedBox(width: 16),
              // 알람 페이지 버튼
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
 Widget _buildNavigationButton(
    BuildContext context, String label, IconData icon, VoidCallback onPressed) {
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
