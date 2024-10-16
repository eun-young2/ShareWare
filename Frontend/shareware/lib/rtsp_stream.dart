import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: VideoScreen(),
    );
  }
}

class VideoScreen extends StatefulWidget {
  @override
  _VideoScreenState createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  late VlcPlayerController _vlcViewController;
  bool _isPlaying = true;
  bool _isRecording = false;
  Process? _recordingProcess;

  @override
  void initState() {
    super.initState();
    _vlcViewController = VlcPlayerController.network(
      'rtsp://dhdmsgud:rmaWhrdlemf@192.168.70.23:554/stream1',
      options: VlcPlayerOptions(),
    );
  }

  @override
  void dispose() {
    _vlcViewController.dispose();
    if (_recordingProcess != null) {
      _recordingProcess!.kill();
    }
    super.dispose();
  }

  Future<void> _startRecording() async {
    setState(() {
      _isRecording = true;
    });

    // 바탕화면 경로 설정
    String outputPath = 'C:/Users/USER/Desktop/output_file.ts'; // 사용자 이름에 맞게 변경

    // VLC 명령어로 녹화 시작
    _recordingProcess = await Process.start(
      'C:\\Program Files\\VideoLAN\\VLC\\vlc.exe',
      [
        'rtsp://dhdmsgud:rmaWhrdlemf@192.168.70.23:554/stream1',
        '--sout',
        'file/ts:$outputPath',
        '--run-time=60',
        '--no-playlist-autostart',
        '--intf',
        'dummy',
      ],
    );

    // 프로세스 종료를 기다림
    _recordingProcess!.exitCode.then((_) {
      setState(() {
        _isRecording = false;
      });
    });
  }

  void _stopRecording() {
    if (_recordingProcess != null) {
      _recordingProcess!.kill();
      setState(() {
        _isRecording = false;
        _recordingProcess = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('RTSP Stream')),
      body: Column(
        children: [
          Expanded(
            child: VlcPlayer(
              controller: _vlcViewController,
              aspectRatio: 16 / 9,
              placeholder: Center(child: CircularProgressIndicator()),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                onPressed: () {
                  if (_isPlaying) {
                    _vlcViewController.pause();
                  } else {
                    _vlcViewController.play();
                  }
                  setState(() {
                    _isPlaying = !_isPlaying;
                  });
                },
              ),
              IconButton(
                icon: Icon(Icons.record_voice_over),
                onPressed: _isRecording ? null : _startRecording,
              ),
              IconButton(
                icon: Icon(Icons.stop),
                onPressed: _isRecording ? _stopRecording : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MyApp());
}
