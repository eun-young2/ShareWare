import 'package:flutter/material.dart';

class StorageManagementPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('창고 관리'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '창고 수량',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            _buildStorageCard('큐브', '10개', '정상'),
            SizedBox(height: 16),
            _buildStorageCard('엑스트라', '5개', '부족'),
            SizedBox(height: 16),
            _buildStorageCard('미니', '20개', '정상'),
            SizedBox(height: 16),
            _buildStorageCard('스텐다드', '13개', '정상'),
            Spacer(),
            ElevatedButton(
              onPressed: () {
                // 추가 버튼 클릭 시의 행동
              },
              child: Text('창고 추가'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStorageCard(String title, String quantity, String status) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text('수량: $quantity', style: TextStyle(color: Colors.grey)),
              ],
            ),
            Text(
              status,
              style: TextStyle(
                color: status == '정상' ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
