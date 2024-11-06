import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'config.dart';

class RTSPApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CCTVPage(),
    );
  }
}

class CCTVPage extends StatefulWidget {
  @override
  _CCTVPageState createState() => _CCTVPageState();
}

class _CCTVPageState extends State<CCTVPage> {
  late VlcPlayerController _vlcViewController;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // Node.js 서버의 HTTP 스트림 URL을 사용하여 VLC 플레이어 컨트롤러 초기화
    _vlcViewController = VlcPlayerController.network(
      '${Config.local}/rtsp/stream', // Node.js 서버에서 제공하는 스트림 URL
      options: VlcPlayerOptions(),
      onInit: () {
        _vlcViewController.addListener(_onPlayerStateChanged);
      },
    );
  }

  void _onPlayerStateChanged() {
    final vlcValue = _vlcViewController.value;
    // 영상이 재생 중이고, 버퍼링 상태가 아닐 때 로딩 인디케이터를 해제
    if (!vlcValue.isBuffering && vlcValue.isPlaying) {
      setState(() {
        isLoading = false;
      });
      _vlcViewController.removeListener(_onPlayerStateChanged); // 리스너 해제
    }
  }

  @override
  void dispose() {
    _vlcViewController.removeListener(_onPlayerStateChanged);
    _vlcViewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('CCTV Stream')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 250,
                  child: VlcPlayer(
                    controller: _vlcViewController,
                    aspectRatio: 16 / 9,
                    placeholder: Center(child: CircularProgressIndicator()),
                  ),
                ),
                if (isLoading)
                  Center(
                    child: CircularProgressIndicator(), // 로딩 인디케이터
                  ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              'CCTV 관련 내용이 여기에 표시됩니다.',
              style: TextStyle(fontSize: 24),
            ),
          ],
        ),
      ),
    );
  }
}

void main() => runApp(RTSPApp());
