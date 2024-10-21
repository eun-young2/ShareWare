import 'package:flutter/gestures.dart'; // 텍스트 스타일 적용을 위해 추가
import 'package:flutter/material.dart';
import 'dart:async'; // 타이머를 사용하기 위해 추가
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data'; // base64Decode
import 'qr_provider.dart';
import 'manage_items_page.dart';
import 'package:provider/provider.dart';

class QRPage extends StatelessWidget {
  final List<Map<String, String>> branches = [
    {
      'name': '시청역점',
      'address': '서울 중구 서소문로 95 B1',
      'contact': '02-123-4567',
    },
    {
      'name': '을지로점',
      'address': '서울 중구 청계천로 100 시그니처타워 서관 B1',
      'contact': '02-234-5678',
    },
    {
      'name': '대학로점',
      'address': '서울 종로구 창경궁로 253-7 (명륜2가, 어젤리아 명륜2) B1',
      'contact': '02-345-6789',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final qrProvider = Provider.of<QRProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('QR 입장 코드 발급'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: '지점 선택'),
              items: branches.map((branch) {
                return DropdownMenuItem<String>(
                  value: branch['name'],
                  child: Text(branch['name']!),
                );
              }).toList(),
              onChanged: (value) {
                final selectedBranch = branches.firstWhere(
                    (branch) => branch['name'] == value,
                    orElse: () => branches[0]);
                qrProvider.selectBranch(selectedBranch);
              },
              value: qrProvider.selectedBranchName,
            ),

            SizedBox(height: 16.0),

            if (qrProvider.selectedBranchName != null) ...[
              Text('${qrProvider.selectedBranchName}'),
              SizedBox(height: 8.0),
              Text('${qrProvider.selectedBranchAddress}'),
              SizedBox(height: 8.0),
              Text('${qrProvider.selectedBranchContact}'),
            ],

            SizedBox(height: 30.0),

            // QR 코드 영역
            Center(
              child: Container(
                width: 200,
                height: 200,
                color: Colors.grey[300],
                child: Center(
                  child: qrProvider.qrImageData != null
                      ? Image.memory(qrProvider.qrImageData!)
                      : Text(''),
                ),
              ),
            ),
            SizedBox(height: 20.0),

            // QR 코드 안내문구
            Center(
              child: Column(
                children: [
                  if (qrProvider.isQRGenerated)
                    Text(
                      '${qrProvider.formatDuration(qrProvider.remainingTime)}',
                      style: TextStyle(fontSize: 20.0),
                      textAlign: TextAlign.center,
                    )
                  else
                    Column(
                      children: [
                        Text(
                          '본 QR 코드는 2시간 동안만 유효합니다.',
                          style: TextStyle(fontSize: 14.0, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                ],
              ),
            ),

            Spacer(),

            // QR 발급 전
            if (!qrProvider.isQRGenerated)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: qrProvider.selectedBranchName == null
                      ? () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text('경고'),
                                content: Text('지점을 선택해주세요.'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('확인'),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      : () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('보관 물품 등록'),
                                content: RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text:
                                            '등록하지 않은 보관물품은\n사고발생 시 배상책임에서 제외될 수 있으며,\n반드시 등록 바랍니다.\n',
                                        style: TextStyle(color: Colors.black),
                                      ),
                                      TextSpan(
                                        text: '보관 불가 물품 보기',
                                        style: TextStyle(
                                          color: Colors.blue,
                                          decoration: TextDecoration.underline,
                                        ),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ProhibitedItemsPage(),
                                              ),
                                            );
                                          },
                                      ),
                                    ],
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('취소'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      // 등록하기 버튼을 눌렀을 때 페이지 이동 구현
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ManageItemsPage(selectedIndex: 3),
                                        ),
                                      );
                                    },
                                    child: Text('등록하기'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                  child: Text('입장 QR 발급하기'),
                ),
              )
            else
              Row(
                children: [
                  // 연장버튼
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // 남은 시간이 30분 이상일 때 알림
                        if (qrProvider.remainingTime > Duration(minutes: 30)) {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text('연장 불가'),
                                content:
                                    Text('유효시간이 30분 이하로\n남았을 때부터 연장 가능합니다.'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('확인'),
                                  ),
                                ],
                              );
                            },
                          );
                        } else {
                          // 30분 이하일 때 연장
                          print('QR 코드 연장');
                          // 연장 기능을 여기에 구현
                        }
                      },
                      child: Text('연장하기'),
                    ),
                  ),

                  SizedBox(width: 16.0),

                  // 퇴실버튼
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        qrProvider.resetQRCode();
                        print('QR 코드 퇴실');
                      },
                      child: Text('퇴실하기'),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

// 보관 불가 물품 보기
class ProhibitedItemsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('보관 불가 물품 안내'),
      ),
      body: Center(
        child: Text('여기에 보관 불가 물품 목록을 표시하세요.'),
      ),
    );
  }
}
