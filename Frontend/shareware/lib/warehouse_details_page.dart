import 'package:flutter/material.dart';
import 'warehouse.dart'; // Warehouse 모델 클래스를 import

// 창고 상세 정보 페이지
class WarehouseDetailsPage extends StatefulWidget {
  final Warehouse warehouse;

  WarehouseDetailsPage({required this.warehouse});

  @override
  _WarehouseDetailsPageState createState() => _WarehouseDetailsPageState();
}

class _WarehouseDetailsPageState extends State<WarehouseDetailsPage> {
  String _currentInfo = "hours"; // 기본 정보는 영업시간으로 설정

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''), // 상단바에 지점 이름을 표시하지 않음
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 사진 추가
            Image.asset(
              'assets/warehouse1.jpg', // 이미지 경로
              width: double.infinity, // 가로로 꽉 차게 설정
              height: 200, // 이미지 높이 설정
              fit: BoxFit.cover, // 이미지 비율 유지
            ),
            SizedBox(height: 10), // 사진과 지점 이름 간격
            Text(
              widget.warehouse.name,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold), // 가장 큰 폰트 설정
            ),
            SizedBox(height: 10), // 지점 이름과 주소 간격
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.warehouse.address,
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]), // 폰트 크기 조정 및 색상 변경
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.copy, size: 18), // 주소 복사 이모지 크기 조정
                  onPressed: () {
                    // 주소 복사 동작 추가
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('주소가 복사되었습니다: ${widget.warehouse.address}')),
                    );
                  },
                  padding: EdgeInsets.zero, // 이모지와 텍스트 간의 간격 조정
                ),
              ],
            ),
            SizedBox(height: 20), // 주소와 정보 간격
            Text(
              '지점 정보',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10), // 지점 정보 제목과 내용 간격
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _infoButton('🕒', 'hours', '이용안내'), // 영업시간 버튼
                _infoButton('🚗', 'parking', '주차'), // 주차 버튼
              ],
            ),
            SizedBox(height: 10), // 버튼과 내용 간격
            // 구분선 추가
            Divider(thickness: 1), // 버튼 아래의 구분선
            SizedBox(height: 10), // 구분선과 내용 간격
            // 현재 정보를 표시
            Text(
              _currentInfo == 'hours' 
                  ? '24시간 운영' 
                  : widget.warehouse.getParkingAvailability(),
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10), // 내용과 버튼 사이 간격
            Spacer(), // 위젯 간격 조정
            Container(
              width: double.infinity, // 가로로 꽉 차게 설정
              margin: EdgeInsets.only(left: 0, right: 0), // 좌우 여백 0
              child: ElevatedButton(
                onPressed: () {
                  // 버튼 클릭 시 동작
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${widget.warehouse.name} 창고를 이용합니다.')),
                  );
                },
                child: Text('창고 이용하기'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black, // 배경색을 검은색으로
                  foregroundColor: Colors.white, // 글씨 색상을 하얀색으로
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero, // 모서리 둥글지 않게
                  ),
                  textStyle: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 정보 버튼 생성 메서드
  Widget _infoButton(String emoji, String infoType, String label) {
    bool isSelected = _currentInfo == infoType; // 현재 정보 타입 확인

    return Column(
      children: [
        TextButton(
          onPressed: () {
            setState(() {
              _currentInfo = infoType; // 버튼 클릭 시 정보 변경
            });
          },
          child: Column(
            children: [
              Text(
                emoji,
                style: TextStyle(fontSize: 28), // 이모지 크기 조정
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 18,
                  color: isSelected ? Colors.black : Colors.grey, // 선택된 버튼 색상
                ),
              ),
            ],
          ),
        ),
        // 선택된 버튼 아래 두꺼운 HR선
        if (isSelected)
          Divider(thickness: 2, color: Colors.black), // 선택된 버튼 아래 두꺼운 선
      ],
    );
  }
}
