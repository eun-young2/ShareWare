import 'package:flutter/material.dart';
import 'warehouse.dart'; // Warehouse 모델 클래스를 import
import 'payment_page.dart'; // 결제 페이지를 import

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
        padding: const EdgeInsets.all(12.0),
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
                      Text('🌡️', style: TextStyle(fontSize: 18)), // 이모지 크기 원래대로 유지
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
              ],
            ),
            SizedBox(height: 4),
            Divider(thickness: 1, color: Colors.black),
            SizedBox(height: 4),
            Text(
              '• ${_currentInfo == 'hours' ? '24시간 운영' : widget.warehouse.getParkingAvailability()}',
              style: TextStyle(fontSize: 16), // 점을 추가하여 리스트 느낌
            ),
            Spacer(),
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PaymentPage(warehouseName: widget.warehouse.name),
                    ),
                  );
                },
                child: Text('창고 이용하기'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
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
        if (isSelected)
          Divider(thickness: 1.5, color: Colors.black),
      ],
    );
  }
}
