import 'package:flutter/gestures.dart'; // 텍스트 스타일 적용을 위해 추가
import 'package:flutter/material.dart';
import 'dart:async'; // 타이머를 사용하기 위해 추가
import 'dart:convert'; // base64Decode 사용을 위해 추가
import 'providers/qr_provider.dart';
import 'manage_items_page.dart';
import 'package:provider/provider.dart';
import 'login_page.dart';
import 'providers/auth_provider.dart'; // AuthProvider 추가
import 'package:http/http.dart' as http; // HTTP 요청용
import 'config.dart'; // API URL 등 설정 파일

class QRPage extends StatefulWidget {
  @override
  _QRPageState createState() => _QRPageState();
}

class _QRPageState extends State<QRPage> {
  List<Map<String, String>> branches = []; // DB에서 가져올 데이터
  Map<String, String>? selectedBranch;
  String? selectedBranchAddress;
  String? selectedBranchContact;

  @override
  void initState() {
    super.initState();
    fetchBranches(); // 서버로부터 지점 정보 가져오기
  }

  Future<void> fetchBranches() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // JWT 토큰을 HTTP 헤더에 포함하여 서버에 요청
    final response = await http.get(
      Uri.parse('${Config.local}/qr/branches'), // Config에서 API URL 사용
      headers: {
        'Authorization': 'Bearer ${authProvider.token}', // JWT 토큰을 헤더에 추가
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      setState(() {
        branches = List<Map<String, String>>.from(
          (data['branches'] as List).map((branch) => {
                'name': branch['name'].toString(),
                'address': branch['address'].toString(),
                'contact': branch['contact'].toString(),
              }),
        ); // 서버로부터 지점 정보 가져오기
      });
    } else {
      // 오류 처리
      print('지점 정보 가져오기 실패: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final qrProvider = Provider.of<QRProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context); // AuthProvider 사용

    return Scaffold(
      appBar: AppBar(
        title: Text('QR 입장 코드 발급'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 서버에서 받아온 지점 정보로 DropdownButtonFormField 구성
            DropdownButtonFormField<Map<String, String>>(
              decoration: InputDecoration(labelText: '지점 선택'),
              items: branches.map((branch) {
                return DropdownMenuItem<Map<String, String>>(
                  value: branch, // 전체 지점 정보를 value로 설정
                  child: Text(branch['name']!),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedBranch = value; // 선택된 전체 지점 정보 저장
                });
                qrProvider.selectBranch(
                    selectedBranch!); // 선택된 지점 정보를 selectBranch에 전달
              },
              value: selectedBranch,
            ),

            SizedBox(height: 16.0),

            // 선택된 지점 정보 표시
            if (selectedBranch != null) ...[
              Text('지점: ${selectedBranch!['name']}'),
              SizedBox(height: 8.0),
              Text('주소: ${selectedBranch!['address']}'),
              SizedBox(height: 8.0),
              Text('연락처: ${selectedBranch!['contact']}'),
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
                  onPressed: () {
                    if (!authProvider.isLoggedIn) {
                      // 비로그인 상태에서 '로그인하기' 알림창 띄우기
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            content: Text('로그인이 필요한 기능입니다.'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(); // 닫기
                                },
                                child: Text('닫기'),
                              ),
                              TextButton(
                                onPressed: () {
                                  // 로그인 페이지로 이동
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => LoginPage(),
                                    ),
                                  );
                                },
                                child: Text('로그인하기'),
                              ),
                            ],
                          );
                        },
                      );
                    } else if (qrProvider.selectedBranchName == null) {
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
                    } else {
                      // QR 발급 로직
                      qrProvider.generateQRCode();
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
                    }
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
                          print('QR 코드 연장');
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

// 보관 불가 물품 보기 페이지
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
