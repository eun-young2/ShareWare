import 'package:flutter/material.dart';

class ReservationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('예약 관리'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // 버튼 그룹
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(onPressed: () {}, child: Text('예약전체')),
                SizedBox(width: 8),
                ElevatedButton(onPressed: () {}, child: Text('논사용시작')),
                SizedBox(width: 8),
                ElevatedButton(onPressed: () {}, child: Text('논사용종료')),
              ],
            ),
            SizedBox(height: 10),
            // 데이터 테이블
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: [
                    DataColumn(label: Text('예약ID')),
                    DataColumn(label: Text('예약상태')),
                    DataColumn(label: Text('예약자')),
                    DataColumn(label: Text('사용기간')),
                  ],
                  rows: [
                    DataRow(cells: [
                      DataCell(Text('241009')),
                      DataCell(Container(
                        color: Colors.orangeAccent,
                        padding: EdgeInsets.all(4),
                        child: Text('확정대기', style: TextStyle(color: Colors.white)),
                      )),
                      DataCell(Text('홍길동')),
                      DataCell(Text('2024.10.09 ~2024.10.31')),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('-000001')),
                      DataCell(Container(
                        color: Colors.blueAccent,
                        padding: EdgeInsets.all(4),
                        child: Text('예약확정', style: TextStyle(color: Colors.white)),
                      )),
                      DataCell(Text('홍길동')),
                      DataCell(Text('2024.10.09 ~2024.10.31')),
                    ]),
                    // 추가적인 행들
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            // 하단 정보 텍스트
            Text(
              '예약ID누르면 결제금액, 결제일시, 등등 상세 정보 나오게',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
