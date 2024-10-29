import 'package:flutter/material.dart';

class ReservationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('예약 관리'),
      ),
      body: Center(
        child: Text(
          '여기에 예약 관리 내용을 추가하세요.',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
