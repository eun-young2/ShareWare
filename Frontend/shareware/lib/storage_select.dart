import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kakaomap_webview/kakaomap_webview.dart';
import 'config.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'search_filter_page.dart'; // 추가된 import

const String kakaoMapKey = 'cb8f3da28528e158b5e76f2e88e968b8';

void main() {
  runApp(MaterialApp(home: KakaoMapTest()));
}

class KakaoMapTest extends StatefulWidget {
  @override
  State<KakaoMapTest> createState() => _KakaoMapTestState();
}

class _KakaoMapTestState extends State<KakaoMapTest> {
  late WebViewController _webViewController; // WebViewController 선언
  List<Map<String, double>> _markers = []; // 마커 리스트
  TextEditingController _searchController = TextEditingController(); // 검색창 컨트롤러

  // 모든 창고 좌표 API 호출
  Future<List<Map<String, double>>> fetchAllWarehouseCoordinates() async {
    final response =
        await http.get(Uri.parse('${Config.local}/map/all/warehouses'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      print('API 응답: $data');
      print('data의 타입: ${data.runtimeType}');

      return data.map((item) {
        return {
          'lat':
              double.tryParse(item['lat'].toString()) ?? 0.0, // lat을 double로 변환
          'lon':
              double.tryParse(item['lon'].toString()) ?? 0.0, // lon을 double로 변환
        };
      }).toList();
    } else {
      throw Exception('창고를 찾을 수 없습니다');
    }
  }

  // 창고 이름을 통해 특정 창고 좌표를 가져오는 API 호출
  Future<Map<String, double>?> fetchWarehouseByName(String name) async {
    final response = await http.get(
        Uri.parse('${Config.local}/map/warehouse?name=$name')); // 이름을 통한 검색 API

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return {
        'lat': double.tryParse(data['lat'].toString()) ?? 0.0,
        'lon': double.tryParse(data['lon'].toString()) ?? 0.0,
      };
    } else {
      print('창고를 찾을 수 없습니다');
      return null;
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
    '''); // 즉시 실행 함수로 블록 스코프 생성
    }

    return script.toString();
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
      if (_webViewController != null) {
        _addMarkers(); // 마커 추가
      }
    } catch (e) {
      print('좌표를 가져오는 중 오류 발생: $e');
    }
  }

  // 검색을 통한 창고 마커 표시
  Future<void> _searchWarehouse(String name) async {
    try {
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

  // KakaoMapView 빌드
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
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController, // 검색창 컨트롤러
                        decoration: InputDecoration(
                          labelText: '창고 검색',
                          suffixIcon: IconButton(
                            icon: Icon(Icons.search),
                            onPressed: () {
                              String searchText = _searchController.text;
                              if (searchText.isNotEmpty) {
                                _searchWarehouse(searchText); // 창고 검색 기능 호출
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.filter_list), // 필터 아이콘
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SearchFilterPage(),
                          ),
                        ); // 필터 페이지로 이동
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: KakaoMapView(
                  width: size.width,
                  height: 400,
                  kakaoMapKey: kakaoMapKey,
                  lat: 37.5665, // 지도 기본 중심 좌표 (최초 로딩 시)
                  lng: 126.978,
                  showMapTypeControl: true,
                  showZoomControl: true,
                  draggableMarker: true,
                  mapType: MapType.BICYCLE,
                  mapController: (controller) async {
                    _webViewController = controller; // WebViewController 초기화
                    await _webViewController.runJavascriptReturningResult("document.readyState").then((result) {
                      if (result == "complete") {
                        _loadAllWarehouseCoordinates(); // 모든 좌표 로드
                      }
                    });
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
          // 하단에 창고 리스트 정보 표시하는 드래그 가능한 바
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
