import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'config.dart';
import 'package:intl/intl.dart';

class EntryLogPage extends StatefulWidget {
  @override
  _EntryLogPageState createState() => _EntryLogPageState();
}

class _EntryLogPageState extends State<EntryLogPage> {
  List<dynamic> logs = [];

  @override
  void initState() {
    super.initState();
    fetchLogs();
  }

  Future<void> fetchLogs() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      final response = await http.get(
        Uri.parse('${Config.local}/qr/entry-logs'),
        headers: {
          'Authorization':
              'Bearer ${authProvider.token}', // Replace with your JWT token
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          logs = json.decode(response.body)['logs'];
        });
      } else {
        print('Failed to load logs: ${response.statusCode},${response.body}');
      }
    } catch (error) {
      print('Error fetching logs: $error');
    }
  }

  String formatDateTime(String isoTime) {
    DateTime dateTime = DateTime.parse(isoTime); // ISO 문자열을 DateTime 객체로 변환
    return DateFormat('yyyy-MM-dd HH:mm:ss')
        .format(dateTime); // yyyy-MM-dd HH:mm:ss 형식으로 포맷팅
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('출입 로그'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: logs.isEmpty
            ? Center(child: Text('출입 로그가 없습니다.'))
            : ListView.builder(
                itemCount: logs.length,
                itemBuilder: (context, index) {
                  final log = logs[index];
                  final logType = log['log_type'] == 'entry' ? '입장' : '퇴장';
                  final userId = log['user_id'];
                  final logAt = formatDateTime(log['log_at']);

                  return Card(
                    child: ListTile(
                      leading: Icon(Icons.access_time),
                      title: Text('$logAt'),
                      subtitle: Text('$logType: 사용자$userId'),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
