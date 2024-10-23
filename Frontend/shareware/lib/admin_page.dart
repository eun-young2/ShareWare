import 'package:flutter/material.dart';

class AdminPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('관리자 페이지'),
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          '관리자 모드 활성화됨',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
