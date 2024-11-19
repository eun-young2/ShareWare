import 'package:flutter/material.dart';
import 'warehouse.dart'; // Warehouse 모델 클래스를 import
import 'booking_page.dart'; // 결제 페이지를 import
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart'; // AuthProvider를 import합니다.
import 'login_page.dart';

class WarehouseDetailsPage extends StatefulWidget {
  final Warehouse warehouse;

  WarehouseDetailsPage({required this.warehouse});

  @override
  _WarehouseDetailsPageState createState() => _WarehouseDetailsPageState();
}

class _WarehouseDetailsPageState extends State<WarehouseDetailsPage> {
  String _currentInfo = "hours";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '창고 이용',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(5),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 2, horizontal: 6),
                  child: Row(
                    children: [
                      Text('🌡️', style: TextStyle(fontSize: 18)),
                      SizedBox(width: 3),
                      Text('적정 온도', style: TextStyle(color: Colors.black, fontSize: 12)),
                    ],
                  ),
                ),
                SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(5),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 2, horizontal: 6),
                  child: Row(
                    children: [
                      Text('💧', style: TextStyle(fontSize: 18)),
                      SizedBox(width: 3),
                      Text('적정 습도', style: TextStyle(color: Colors.black, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Image.asset(
              'assets/warehouse1.jpg',
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 8),
            Text(
              widget.warehouse.name,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.warehouse.address,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.copy, size: 16),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('주소가 복사되었습니다: ${widget.warehouse.address}')),
                    );
                  },
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              '지점 정보',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _infoButton('🕒', 'hours', '이용안내'),
                SizedBox(width: 4),
                VerticalDivider(width: 12, thickness: 1, color: Colors.black),
                SizedBox(width: 4),
                _infoButton('P', 'parking', '주차'),
                SizedBox(width: 4),
                VerticalDivider(width: 12, thickness: 1, color: Colors.black),
                SizedBox(width: 4),
                _infoButton('🔐', 'security', '보안/출입'),
                SizedBox(width: 4),
                VerticalDivider(width: 12, thickness: 1, color: Colors.black),
                SizedBox(width: 4),
                _infoButton('📶', 'wifi', '와이파이'),
              ],
            ),
            SizedBox(height: 4),
            Divider(thickness: 1, color: Colors.black),
            SizedBox(height: 4),
            Text(
              '• ${_currentInfo == 'hours' ? '24시간 운영' : 
                   _currentInfo == 'parking' ? widget.warehouse.getParkingAvailability() : 
                   _currentInfo == 'security' ? '보안 시스템이 완비되어 있습니다. 출입은 QR로만 가능합니다.' : 
                   _currentInfo == 'wifi' ? '무료 Wi-Fi 제공. 비밀번호는 관리실에서 확인 가능합니다.' : 
                    ''}',
              style: TextStyle(fontSize: 16),
            ),
            Spacer(),
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final authProvider =
                      Provider.of<AuthProvider>(context, listen: false);

                  if (!authProvider.isLoggedIn) {
                    _showLoginDialog();
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            BookingPage(warehouseName: widget.warehouse.name),
                      ),
                    );
                  }
                },
                child: Text('창고 이용하기'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFAFD485),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                  textStyle: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoButton(String emoji, String infoType, String label) {
  bool isSelected = _currentInfo == infoType;

  if (infoType == 'wifi') {
    return Column(
      children: [
        TextButton(
          onPressed: () {
            setState(() {
              _currentInfo = infoType;
            });
          },
          child: Column(
            children: [
              Icon(Icons.wifi, size: 20, color: Colors.black),
              SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: isSelected ? Colors.black : Colors.grey,
                ),
              ),
            ],
          ),
        ),
        if (isSelected) Divider(thickness: 1.5, color: Colors.black),
      ],
    );
  }

  return Column(
    children: [
      TextButton(
        onPressed: () {
          setState(() {
            _currentInfo = infoType;
          });
        },
        child: Column(
          children: [
            Text(
              emoji,
              style: TextStyle(fontSize: 18),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: isSelected ? Colors.black : Colors.grey,
              ),
            ),
          ],
        ),
      ),
      if (isSelected) Divider(thickness: 1.5, color: Colors.black),
    ],
  );
}


  void _showLoginDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('로그인 필요'),
          content: Text('로그인이 필요합니다. 로그인 페이지로 이동하시겠습니까?'),
          actions: [
            TextButton(
              child: Text('로그인'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushNamed(context, '/login').then((_) {
                  // 로그인 후 디테일 페이지로 돌아옴
                  setState(() {}); // 상태를 갱신하여 UI를 업데이트
                });
              },
            ),
            TextButton(
              child: Text('취소'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
