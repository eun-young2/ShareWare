import 'package:flutter/material.dart';

class StorageSelectPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('창고 선택'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('창고 유형을 선택하세요'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // 도심형 창고 선택 로직
                Navigator.pop(context, '도심형 창고 선택됨');
              },
              child: Text('도심형 창고 찾기'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // 외각형 창고 선택 로직
                Navigator.pop(context, '외각형 창고 선택됨');
              },
              child: Text('외각형 창고 찾기'),
            ),
          ],
        ),
      ),
    );
  }
}
