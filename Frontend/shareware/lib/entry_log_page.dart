// entry_log_page.dart (출입 로그 화면 추가)

import 'package:flutter/material.dart';

class EntryLogPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('출입 로그'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // 예시로 출입 로그 데이터를 ListView에 나열
            Card(
              child: ListTile(
                leading: Icon(Icons.access_time),
                title: Text('2024-11-08 10:30:00'),
                subtitle: Text('입장: 사용자1'),
              ),
            ),
            Card(
              child: ListTile(
                leading: Icon(Icons.access_time),
                title: Text('2024-11-08 11:00:00'),
                subtitle: Text('퇴장: 사용자2'),
              ),
            ),
            // 더 많은 출입 로그 추가 가능
          ],
        ),
      ),
    );
  }
}
