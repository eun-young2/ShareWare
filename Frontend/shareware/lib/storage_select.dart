import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kakaomap_webview/kakaomap_webview.dart';
import 'config.dart';
import 'package:webview_flutter/webview_flutter.dart';

const String kakaoMapKey = 'cb8f3da28528e158b5e76f2e88e968b8';

void main() {
  runApp(MaterialApp(home: KakaoMapTest()));
}

class KakaoMapTest extends StatefulWidget {
  @override
  State<KakaoMapTest> createState() => _KakaoMapTestState();
}

class _KakaoMapTestState extends State<KakaoMapTest> {
  late WebViewController _webViewController;
  List<Map<String, double>> _markers = [];
  TextEditingController _searchController = TextEditingController();

  // 모든 창고 좌표 API 호출
  Future<List<Map<String, double>>> fetchAllWarehouseCoordinates() async {
    final response =
        await http.get(Uri.parse('${Config.local}/map/all/warehouses'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) {
        return {
          'lat': double.tryParse(item['lat'].toString()) ?? 0.0,
          'lon': double.tryParse(item['lon'].toString()) ?? 0.0,
        };
      }).toList();
    } else {
      throw Exception('창고를 찾을 수 없습니다');
    }
  }

  // 창고 이름을 통해 특정 창고 좌표를 가져오는 API 호출
  Future<Map<String, double>?> fetchWarehouseByName(String name) async {
    final response = await http.get(Uri.parse('${Config.local}/map/$name'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return {
        'lat': double.tryParse(data['lat'].toString()) ?? 0.0,
        'lon': double.tryParse(data['lon'].toString()) ?? 0.0,
      };
    } else {
      return null; // 창고를 찾을 수 없을 경우 null 반환
    }
  }

  // 마커 추가 스크립트
  String _generateMarkersScript() {
    StringBuffer script = StringBuffer();
    script.writeln('var markers = [];'); // 마커 배열 초기화

    for (var marker in _markers) {
      double lat = marker['lat']!;
      double lon = marker['lon']!;
      script.writeln('''
      (function() {
        var markerPosition = new kakao.maps.LatLng($lat, $lon);
        var marker = new kakao.maps.Marker({
          position: markerPosition
        });
        marker.setMap(map);
        markers.push(marker);
      })();
      ''');
    }

    return script.toString();
  }

  // 마커 초기화
  void _clearMarkers() {
    if (_webViewController != null) {
      _webViewController
          .runJavascript(
              "markers.forEach(marker => marker.setMap(null)); markers = [];")
          .then((_) {
        print("기존 마커 제거 성공");
      }).catchError((error) {
        print("기존 마커 제거 오류: $error");
      });
    }
  }

  // 여러 개의 마커를 지도에 추가하는 함수
  void _addMarkers() {
    if (_webViewController != null) {
      final markersScript = _generateMarkersScript();
      _webViewController.runJavascript(markersScript).then((_) {
        print("JavaScript 실행 성공: 마커 추가됨");
      }).catchError((error) {
        print("JavaScript 실행 오류: $error");
      });
    } else {
      print("WebViewController가 아직 초기화되지 않았습니다.");
    }
  }

  // 모든 창고 좌표 로드
  Future<void> _loadAllWarehouseCoordinates() async {
    try {
      _markers = await fetchAllWarehouseCoordinates(); // 모든 창고 좌표 가져오기
      setState(() {
        _addMarkers(); // 마커 추가
      });
    } catch (e) {
      print('좌표를 가져오는 중 오류 발생: $e');
    }
  }

  // 검색을 통한 창고 마커 표시
  Future<void> _searchWarehouse(String name) async {
    try {
      // 기존 마커 제거
      _clearMarkers();

      // 검색된 창고 좌표 가져오기
      final warehouse = await fetchWarehouseByName(name);
      if (warehouse != null) {
        setState(() {
          _markers = [warehouse]; // 검색된 창고만 마커로 표시
          _addMarkers(); // 마커 추가
        });
      } else {
        print('검색된 창고가 없습니다');
      }
    } catch (e) {
      print('검색 중 오류 발생: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text('창고찾기'),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: '창고 검색',
                    suffixIcon: IconButton(
                      icon: Icon(Icons.search),
                      onPressed: () {
                        String searchText = _searchController.text;
                        if (searchText.isNotEmpty) {
                          _searchWarehouse(searchText);
                        }
                      },
                    ),
                  ),
                ),
              ),
              Expanded(
                child: KakaoMapView(
                  width: size.width,
                  height: 400,
                  kakaoMapKey: kakaoMapKey,
                  lat: 37.5665,
                  lng: 126.978,
                  showMapTypeControl: true,
                  showZoomControl: true,
                  draggableMarker: true,
                  mapType: MapType.BICYCLE,
                  mapController: (controller) {
                    _webViewController = controller;
                    _loadAllWarehouseCoordinates(); // 모든 좌표 로드
                  },
                  onTapMarker: (message) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(message.message)),
                    );
                  },
                ),
              ),
            ],
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.2,
            minChildSize: 0.1,
            maxChildSize: 0.6,
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10.0,
                      spreadRadius: 5.0,
                    ),
                  ],
                ),
                child: ListView(
                  controller: scrollController,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Container(
                            width: 40,
                            height: 5,
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          SizedBox(height: 10),
                          // 창고 정보 표시
                          for (int i = 0; i < _markers.length; i++)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              child: Text(
                                  '마커 ${i + 1}: ${_markers[i]['lat']}, ${_markers[i]['lon']}'),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
