import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart'; // AuthProvider를 통한 JWT 처리
import 'config.dart'; // 서버 URL 관리
import 'package:intl/intl.dart';

// 알람 상세 페이지
class AlarmPage extends StatefulWidget {
  @override
  _AlarmPageState createState() => _AlarmPageState();
}

class _AlarmPageState extends State<AlarmPage> {
  List<Alarm> _alarms = [];

  @override
  void initState() {
    super.initState();
    _fetchAlarms();
  }

  // 알람 데이터 가져오기
  Future<void> _fetchAlarms() async {
    final token = Provider.of<AuthProvider>(context, listen: false).token;

    try {
      final response = await http.get(
        Uri.parse('${Config.local}/user/notifications'),
        headers: {
          'Authorization': 'Bearer $token', // JWT 토큰 추가
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['notifications'];
        setState(() {
          _alarms = data.map((e) => Alarm.fromJson(e)).toList();
        });
      } else {
        throw Exception('알람 목록을 가져오는 데 실패했습니다.');
      }
    } catch (error) {
      print('오류 발생: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('알람 리스트')),
      body: _alarms.isEmpty
          ? Center(child: CircularProgressIndicator()) // 로딩 표시
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                itemCount: _alarms.length,
                itemBuilder: (context, index) {
                  return AlarmTile(
                    alarm: _alarms[index],
                    onTap: () {
                      // Tile을 누르면 알람을 읽음으로 표시 후 상세 페이지로 이동
                      _markAsRead(context, _alarms[index]);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AlarmDetailPage(
                            alarm: _alarms[index],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
    );
  }

  // 알람을 읽음으로 표시하고 상태 업데이트
  Future<void> _markAsRead(BuildContext context, Alarm alarm) async {
    if (alarm.isRead == 1) return; // 이미 읽은 알람은 클릭해도 아무 동작 안함

    final token = Provider.of<AuthProvider>(context, listen: false).token;

    try {
      final response = await http.put(
        Uri.parse('${Config.local}/user/mark-as-read/${alarm.behaviorId}'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          alarm.isRead = 1; // 로컬에서 바로 is_read 상태 변경
        });
        // ScaffoldMessenger.of(context)
        //     .showSnackBar(SnackBar(content: Text('읽음으로 표시되었습니다.')));
      } else {
        throw Exception('알림을 읽음으로 표시하는 데 실패했습니다.');
      }
    } catch (error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('오류 발생: $error')));
    }
  }
}

// 알람 항목 (각 알람을 리스트로 표시)
class AlarmTile extends StatelessWidget {
  final Alarm alarm;
  final VoidCallback onTap;

  const AlarmTile({required this.alarm, required this.onTap});

  // 날짜 변환 함수 (ISO 8601 -> YYYY-MM-DD HH:mm:ss)
  String _formatDate(String isoDate) {
    try {
      final dateTime = DateTime.parse(isoDate);
      return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
    } catch (e) {
      return isoDate; // 변환 실패 시 원본 반환
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Tile을 클릭하면 onTap 호출
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 8.0),
        elevation: 2.0,
        child: ListTile(
          contentPadding: EdgeInsets.all(16.0),
          leading: Icon(Icons.notification_important, color: Colors.red),
          title: Text(alarm.behaviorType,
              style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(_formatDate(alarm.createdAt)), // 날짜 변환 후 표시
          trailing: Chip(
            label: Text(alarm.isRead == 0 ? '읽지 않음' : '읽음',
                style: TextStyle(
                    color: alarm.isRead == 0 ? Colors.red : Colors.green)),
            backgroundColor: alarm.isRead == 0
                ? Colors.red.withOpacity(0.1)
                : Colors.green.withOpacity(0.1),
          ),
        ),
      ),
    );
  }
}

// 알람 모델
class Alarm {
  final int behaviorId;
  final String behaviorType;
  final String createdAt;
  int isRead;

  Alarm({
    required this.behaviorId,
    required this.behaviorType,
    required this.createdAt,
    required this.isRead,
  });

  // JSON 데이터를 Alarm 객체로 변환
  factory Alarm.fromJson(Map<String, dynamic> json) {
    return Alarm(
      behaviorId: json['behavior_id'],
      behaviorType: json['behavior_type'],
      createdAt: json['created_at'],
      isRead: json['is_read'],
    );
  }
}

// 알람 상세 페이지
class AlarmDetailPage extends StatelessWidget {
  final Alarm alarm;

  const AlarmDetailPage({required this.alarm});

  String _formatDate(String isoDate) {
    try {
      final dateTime = DateTime.parse(isoDate);
      return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
    } catch (e) {
      return isoDate;
    }
  }

  Future<void> _markAsRead(BuildContext context) async {
    final token = Provider.of<AuthProvider>(context, listen: false).token;

    try {
      final response = await http.put(
        Uri.parse('${Config.local}/user/mark-as-read/${alarm.behaviorId}'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // ScaffoldMessenger.of(context)
        //     .showSnackBar(SnackBar(content: Text('읽음으로 표시되었습니다.')));
      } else {
        throw Exception('알림을 읽음으로 표시하는 데 실패했습니다.');
      }
    } catch (error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('오류 발생: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('알람 상세')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('알람 제목: ${alarm.behaviorType}',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Text('발생 시간: ${_formatDate(alarm.createdAt)}',
                style: TextStyle(fontSize: 16, color: Colors.grey)),
            SizedBox(height: 16),
            Text('알람 상태: ${alarm.isRead == 0 ? '읽지 않음' : '읽음'}',
                style: TextStyle(
                    fontSize: 16,
                    color: alarm.isRead == 0 ? Colors.red : Colors.green)),
            SizedBox(height: 20),
            Divider(),
            SizedBox(height: 16),
            Text('알람 상세 내용:\n\n창고에서 이상행동이 탐지되었습니다.'),
            Spacer(),
            // ElevatedButton(
            //   onPressed: () {
            //     _markAsRead(context);
            //     Navigator.pop(context);
            //   },
            //   child: Text('읽음으로 표시'),
            // ),
          ],
        ),
      ),
    );
  }
}
