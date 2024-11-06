import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'config.dart';

class CCTVPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(children: [
        Container(
            // RTSP stream 받아오는 영상 넣을 곳
            ),
        Text(
          'CCTV 관련 내용이 여기에 표시됩니다.',
          style: TextStyle(fontSize: 24),
        ),
      ]),
    );
  }
}
