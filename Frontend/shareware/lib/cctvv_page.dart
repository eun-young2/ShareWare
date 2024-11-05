import 'package:flutter/material.dart';

class CCTVPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Text(
          'CCTV 관련 내용이 여기에 표시됩니다.',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
