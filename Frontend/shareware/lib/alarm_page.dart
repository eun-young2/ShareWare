import 'package:flutter/material.dart';

// 알람 상세 페이지
class AlarmPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('알람 리스트')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: 10, // 예시로 10개의 알람을 표시
          itemBuilder: (context, index) {
            return AlarmTile(index: index);
          },
        ),
      ),
    );
  }
}

// 알람 항목 (각 알람을 리스트로 표시)
class AlarmTile extends StatelessWidget {
  final int index;
  const AlarmTile({required this.index});

  @override
  Widget build(BuildContext context) {
    // 예시 데이터: 알람 제목, 발생 시간, 알람 상태
    final alarmTitle = '서버통신 비정상 감지 $index';
    final alarmTime = '2024-11-05 12:30 PM';
    final alarmStatus = index % 2 == 0 ? '읽지 않음' : '읽음';

    return GestureDetector(
      onTap: () {
        // 알람 클릭 시 알람 상세 페이지로 이동
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AlarmDetailPage(alarmTitle: alarmTitle, alarmTime: alarmTime, alarmStatus: alarmStatus),
          ),
        );
      },
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 8.0),
        elevation: 2.0,
        child: ListTile(
          contentPadding: EdgeInsets.all(16.0),
          leading: Icon(Icons.notification_important, color: Colors.red),
          title: Text(alarmTitle, style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(alarmTime),
          trailing: Chip(
            label: Text(alarmStatus, style: TextStyle(color: alarmStatus == '읽지 않음' ? Colors.red : Colors.green)),
            backgroundColor: alarmStatus == '읽지 않음' ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
          ),
        ),
      ),
    );
  }
}

// 알람 상세 페이지
class AlarmDetailPage extends StatelessWidget {
  final String alarmTitle;
  final String alarmTime;
  final String alarmStatus;

  const AlarmDetailPage({
    required this.alarmTitle,
    required this.alarmTime,
    required this.alarmStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('알람 상세')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('알람 제목: $alarmTitle', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Text('발생 시간: $alarmTime', style: TextStyle(fontSize: 16, color: Colors.grey)),
            SizedBox(height: 16),
            Text('알람 상태: $alarmStatus', style: TextStyle(fontSize: 16, color: alarmStatus == '읽지 않음' ? Colors.red : Colors.green)),
            SizedBox(height: 20),
            Divider(),
            SizedBox(height: 16),
            Text(
              '알람 상세 내용:\n\n'
              '이 곳에는 알람에 대한 자세한 내용이 표시됩니다. 예를 들어, 시스템 장애의 원인, 발생 시간, 그리고 해결 방법 등을 기록할 수 있습니다.',
              style: TextStyle(fontSize: 16),
            ),
            Spacer(),
            ElevatedButton(
              onPressed: () {
                // 상태 변경 (읽음으로 표시)
                Navigator.pop(context); // 상세 페이지에서 뒤로 가기
              },
              child: Text('읽음으로 표시'),
            ),
          ],
        ),
      ),
    );
  }
}
