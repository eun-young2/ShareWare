import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'config.dart';

class RTSPApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: RTSPVideoScreen(),
    );
  }
}

class RTSPVideoScreen extends StatefulWidget {
  @override
  _RTSPVideoScreenState createState() => _RTSPVideoScreenState();
}

class _RTSPVideoScreenState extends State<RTSPVideoScreen> {
  late VlcPlayerController _vlcViewController;

  @override
  void initState() {
    super.initState();
    // Node.js 서버의 HTTP 스트림 URL을 사용하여 VLC 플레이어 컨트롤러 초기화
    _vlcViewController = VlcPlayerController.network(
      '${Config.local}/rtsp/stream', // Node.js 서버에서 제공하는 스트림 URL
      options: VlcPlayerOptions(),
    );
  }

  @override
  void dispose() {
    _vlcViewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('HTTP Stream from Node.js')),
      body: VlcPlayer(
        controller: _vlcViewController,
        aspectRatio: 16 / 9,
        placeholder: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

void main() => runApp(RTSPApp());
