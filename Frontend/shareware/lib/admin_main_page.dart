import 'package:flutter/material.dart';
import 'reservation_page.dart'; // 추가된 부분

void main() {
  runApp(AdminMainPage());
}

class AdminMainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CCTVPage(),
    );
  }
}

class CCTVPage extends StatefulWidget {
  @override
  _CCTVPageState createState() => _CCTVPageState();
}

class _CCTVPageState extends State<CCTVPage> {
  int _selectedIndex = 0;

  // 페이지 목록
  final List<Widget> _pages = [
    CCTVPageContent(),
    NotificationsPage(),
    CustomerInquiryPage(),
    ReservationPage(), // 예약 관리 페이지 추가
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
          child: DropdownButton<String>(
            value: '쉐어웨어 광주동명점',
            items: <String>['쉐어웨어 광주동명점', '다른 지점1', '다른 지점2'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (_) {},
            underline: SizedBox(),
          ),
        ),
      ),
      body: _pages[_selectedIndex], // 선택된 페이지 표시
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: '대시보드'),
          BottomNavigationBarItem(icon: Icon(Icons.access_alarm), label: '알림관리'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: '고객문의'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: '예약관리'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}

// CCTV 페이지의 본문
class CCTVPageContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
          SizedBox(height: 4),
          Text(
            'CCTV와의 통신이 끊겼습니다.',
            style: TextStyle(color: Colors.grey),
          ),
          SizedBox(height: 16),
          Text('CCTV', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
              _buildStatisticCard('월간 방문객', '120', '+5%'),
              _buildStatisticCard('금일 방문객', '25', '-10%'),
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

// 알림 관리 페이지
class NotificationsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '알림 관리 페이지',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}

// 고객 문의 페이지
class CustomerInquiryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '고객 문의 페이지',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}
