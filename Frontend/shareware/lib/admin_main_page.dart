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
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: '대시보드'), // 대시보드 아이콘
          BottomNavigationBarItem(icon: Icon(Icons.camera), label: 'CCTV'), // CCTV 아이콘
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: '예약 관리'), // 예약 관리 아이콘
          BottomNavigationBarItem(icon: Icon(Icons.warehouse), label: '창고 관리'), // 창고 관리 아이콘
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
          GestureDetector(
            onTap: () {
              // 서버통신 비정상 감지 클릭 시 알람 페이지로 이동
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AlarmPage()), // 알람 페이지로 이동
              );
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.notifications),
                SizedBox(width: 8),
                Text(
                  '서버통신 비정상 감지',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Spacer(),
                Text(
                  'Yesterday',
                  style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          SizedBox(height: 4),
          Text(
            'CCTV와의 통신이 끊겼습니다.',
            style: TextStyle(color: Colors.grey),
          ),
          SizedBox(height: 16),
          Text('CCTV 상태', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Container(
            height: 300,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Text('Security', style: TextStyle(color: Colors.grey)),
                  ],
                ),
                SizedBox(height: 130),
                Center(
                  child: Text('Front Entrance', style: TextStyle(fontSize: 20)),
                ),
                SizedBox(height: 16),
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('CCTV 1'),
                    Text('Online', style: TextStyle(color: Colors.green)),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: _buildStatisticCard('월간 방문객', '120', '+5%')),
              SizedBox(width: 16),
              Expanded(child: _buildStatisticCard('금일 방문객', '25', '-10%')),
            ],
          ),
          Spacer(),
          Divider(),
          ListTile(
            leading: Icon(Icons.perm_identity),
            title: Text('서버 통신'),
            subtitle: Text('Admin user login'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.circle, color: Colors.green, size: 12),
                SizedBox(width: 4),
                Text('정상'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticCard(String title, String value, String change) {
    return Container(
      width: 150,
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
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 4),
          Text(change, style: TextStyle(color: change.contains('-') ? Colors.red : Colors.green)),
        ],
      ),
    );
  }
}
