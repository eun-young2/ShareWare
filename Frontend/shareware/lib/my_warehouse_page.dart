import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'manage_items_page.dart';
import 'login_page.dart';
import 'providers/auth_provider.dart';
import 'package:kakaomap_webview/kakaomap_webview.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config.dart';
import 'warehouse.dart';
import 'package:flutter/services.dart';

const String kakaoMapKey = 'cb8f3da28528e158b5e76f2e88e968b8';



class MyWarehousePage extends StatefulWidget {
  @override
  _MyWarehousePageState createState() => _MyWarehousePageState();
}

class _MyWarehousePageState extends State<MyWarehousePage> {
  Future<List<Warehouse>>? _warehouseLocations;

  @override
  void initState() {
    super.initState();
    _warehouseLocations = _fetchWarehouseLocations();
  }

  Future<List<Warehouse>> _fetchWarehouseLocations() async {
    final userId = Provider.of<AuthProvider>(context, listen: false).userId;
    if (userId == null) {
      print("사용자가 로그인하지 않았습니다.");
      return [];
    }

    final url = Uri.parse('${Config.local}/map/user/$userId');

    try {
      final response = await http.get(url);
      print("API 응답 상태 코드: ${response.statusCode}");
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data.isNotEmpty) {
          return data.map<Warehouse>((item) => Warehouse.fromJson(item)).toList();
        } else {
          print("데이터 없음: 예약된 창고가 없습니다.");
          return [];
        }
      } else {
        print('Failed to load location');
        return [];
      }
    } catch (error) {
      print('Error fetching location: $error');
      return [];
    }
  }

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
      appBar: AppBar(
        title: Text('마이 창고'),
      
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (authProvider.isLoggedIn)
            FutureBuilder<List<Warehouse>>(
              future: _warehouseLocations,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("데이터를 불러오는 중 오류 발생"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text("창고 데이터가 없습니다."));
                } else {
                  final warehouses = snapshot.data!;
                  return Column(
                    children: warehouses.take(1).map((warehouse) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                      );
                    }).toList(),
                  );
                }
              },
            ),
          SizedBox(height: 1),
          Container(
            width: double.infinity,
            color: Colors.grey[100],
            child: authProvider.isLoggedIn
                ? FutureBuilder<List<Warehouse>>(
                    future: _warehouseLocations,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        print("위치를 불러오는 중 오류 발생: ${snapshot.error}");
                        return Center(child: Text("위치를 불러올 수 없습니다."));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(child: Text("위치를 불러올 수 없습니다."));
                      } else {
                        final warehouses = snapshot.data!;
                        return Padding(
                          padding: const EdgeInsets.all(0.0), // 양옆 여백 제거
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: EdgeInsets.all(8),
                                color: Colors.grey[100],
                                child: Text(
                                  warehouses[0].name,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black54,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0), // 좌우 여백
                                child: Row(
                                  children: [
                                    // 지도와 여백을 Row로 배치
                                    Expanded(
                                      child: Container(
                                        width: screenWidth * 0.75, // 화면의 3/4을 지도에 할당
                                        height: 200,
                                        child: KakaoMapView(
                                          width: double.infinity,
                                          height: double.infinity,
                                          kakaoMapKey: kakaoMapKey,
                                          lat: warehouses[0].lat,
                                          lng: warehouses[0].lon,
                                          showMapTypeControl: true,
                                          showZoomControl: true,
                                          draggableMarker: true,
                                          mapType: MapType.BICYCLE,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 8),
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                color: Colors.grey[100],
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        warehouses[0].address,
                                        style: TextStyle(fontSize: 16, color: Colors.black),
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Clipboard.setData(ClipboardData(text: warehouses[0].address));
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text("주소가 복사되었습니다.")),
                                        );
                                      },
                                      child: Icon(Icons.copy, size: 20, color: Colors.black54),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
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
          SizedBox(height: 16),
          Divider(),
          Padding(
            padding: const EdgeInsets.only(left: 16.0), // 왼쪽 여백을 16으로 설정
            child: Text(
              '이용 관리',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 9.0), // 리스트 항목에 좌우 여백 추가
            child: Column(
              children: [
                ListTile(
                  title: Text(
                    '내 물품 관리',
                    style: TextStyle(fontSize: 20), // 폰트 크기 1.5배로 키움
                  ),
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
                  title: Text(
                    'QR 발급 내역',
                    style: TextStyle(fontSize: 20), // 폰트 크기 1.5배로 키움
                  ),
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
                  title: Text(
                    '결제 관리',
                    style: TextStyle(fontSize: 20), // 폰트 크기 1.5배로 키움
                  ),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    if (!authProvider.isLoggedIn) {
                      _showLoginRequiredDialog(context);
                    } else {
                      // 결제 관리 페이지로 이동하는 로직 추가 가능
                    }
                  },
                ),
                Divider(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
