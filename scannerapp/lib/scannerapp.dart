import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: QRViewExample(),
    );
  }
}

class QRViewExample extends StatefulWidget {
  @override
  _QRViewExampleState createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRViewExample> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool isDialogShown = false; // 다이얼로그 표시 여부를 확인하는 플래그

  @override
  void reassemble() {
    super.reassemble();
    if (controller != null) {
      controller!.pauseCamera();
      controller!.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('QR 코드 스캐너')),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Text('QR 코드를 스캔하세요'),
            ),
          )
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      if (!isDialogShown) {
        // 다이얼로그가 표시되지 않았을 때만 실행
        final qrData = scanData.code;
        if (qrData != null) {
          final parts = qrData.split(',');
          if (parts.length == 3) {
            // QR 코드가 세 가지 값을 가질 때
            final userId = parts[0].trim();
            final reservIdx = parts[1].trim(); // reserv_idx 값
            final time = parts[2].trim();

            setState(() {
              isDialogShown = true; // 다이얼로그가 표시됨을 설정
            });

            // 서버에 요청 보내기
            final response = await http.get(Uri.parse(
                'http://172.30.1.56:3000/qr/check-qr?reserv_idx=$reservIdx'));

            String message;
            if (response.statusCode == 200) {
              try {
                final jsonResponse = jsonDecode(response.body);
                if (jsonResponse['is_valid'] == 1) {
                  message = jsonResponse['message'];
                } else {
                  message = jsonResponse['message'];
                }
              } catch (e) {
                message = '응답 처리 오류';
              }
            } else {
              message = '서버 연결 실패';
            }

            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(message),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      setState(() {
                        isDialogShown = false; // 다이얼로그가 닫힐 때 플래그를 리셋
                      });
                    },
                    child: Text('확인'),
                  ),
                ],
              ),
            );
          }
        }
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
