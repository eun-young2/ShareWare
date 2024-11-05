import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'manage_items_page.dart';
import 'login_page.dart';
import 'providers/auth_provider.dart';
import 'package:kakaomap_webview/kakaomap_webview.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config.dart';
import 'package:kakaomap_webview/kakaomap_webview.dart';

const String kakaoMapKey = 'cb8f3da28528e158b5e76f2e88e968b8';

void main() {
  runApp(MaterialApp(home: MyWarehousePage()));
}

class MyWarehousePage extends StatefulWidget {
  @override
  _MyWarehousePageState createState() => _MyWarehousePageState();
}

class _MyWarehousePageState extends State<MyWarehousePage> {
  double? _currentLat;
  double? _currentLon;
  Future<Map<String, double>?>? _warehouseLocation;

  @override
  void initState() {
    super.initState();
    _warehouseLocation = _fetchWarehouseLocation();
  }

  // 사용자 ID로 데이터베이스에서 창고 좌표를 가져오는 함수
  Future<Map<String, double>?> _fetchWarehouseLocation() async {
    final userId = Provider.of<AuthProvider>(context, listen: false).userId;
    if (userId == null) {
      print("사용자가 로그인하지 않았습니다.");
      return null;
    }

    final url = Uri.parse('${Config.local}/map/user/$userId');

    try {
      final response = await http.get(url);
      print("API 응답 상태 코드: ${response.statusCode}");
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data.isNotEmpty) {
          final lat = double.tryParse(data[0]['lat'].toString());
          final lon = double.tryParse(data[0]['lon'].toString());
          //print("창고 위치 설정됨: lat=$lat, lon=$lon");
          if (lat != null && lon != null) {
            return {'lat': lat, 'lon': lon};
          }
        } else {
          print("데이터 없음: 예약된 창고가 없습니다.");
          return null;
        }
      } else {
        print('Failed to load location');
        return null;
      }
    } catch (error) {
      print('Error fetching location: $error');
      return null;
    }
    return null;
  }

  void _getCurrentLocation() {
    // 현재 위치를 가져오는 로직을 추가하세요
    _currentLat = 37.5665; // 예시: 서울
    _currentLon = 126.978; // 예시: 서울
  }

  // void _loadAllWarehouseCoordinates() {
  //   // 모든 창고 좌표를 불러오는 로직을 추가하세요
  // }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final authProvider = Provider.of<AuthProvider>(context);

    void _showLoginRequiredDialog(BuildContext context) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text('로그인이 필요한 기능입니다.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('닫기'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
                child: Text('로그인하기'),
              ),
            ],
          );
        },
      );
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: screenWidth,
              height: 133, // 지도 높이를 줄임
              child: authProvider.isLoggedIn
                  ? FutureBuilder<Map<String, double>?>(
                      future: _warehouseLocation,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          print("위치를 불러오는 중 오류 발생: ${snapshot.error}");
                          return Center(child: Text("위치를 불러올 수 없습니다."));
                        } else if (!snapshot.hasData || snapshot.data == null) {
                          print("위치를 불러올 수 없음: 데이터가 null");
                          return Center(child: Text("위치를 불러올 수 없습니다."));
                        } else {
                          final lat = snapshot.data!['lat']!;
                          final lon = snapshot.data!['lon']!;
                          print("위치 불러오기 성공: lat=$lat, lon=$lon");
                          return KakaoMapView(
                            width: screenWidth,
                            height: 133,
                            kakaoMapKey: kakaoMapKey,
                            lat: lat,
                            lng: lon,
                            showMapTypeControl: true,
                            showZoomControl: true,
                            draggableMarker: true,
                            mapType: MapType.BICYCLE,
                          );
                        }
                      },
                    )
                  : Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginPage(),
                            ),
                          );
                        },
                        child: Text(
                          '로그인이 필요한 기능입니다.',
                          style: TextStyle(fontSize: 22, color: Colors.blue),
                        ),
                      ),
                    ),
            ),
            SizedBox(height: 30),
            Text(
              '이용 관리',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Divider(),
            ListTile(
              title: Text('내 물품 관리'),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                if (!authProvider.isLoggedIn) {
                  _showLoginRequiredDialog(context);
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ManageItemsPage(selectedIndex: 3),
                    ),
                  );
                }
              },
            ),
            Divider(),
            ListTile(
              title: Text('QR 발급 내역'),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                if (!authProvider.isLoggedIn) {
                  _showLoginRequiredDialog(context);
                } else {
                  // QR 발급 내역 페이지로 이동하는 로직 추가 가능
                }
              },
            ),
            Divider(),
            ListTile(
              title: Text('결제 관리'),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                if (!authProvider.isLoggedIn) {
                  _showLoginRequiredDialog(context);
                } else {
                  // 결제 관리 페이지로 이동하는 로직 추가 가능
                }
              },
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
