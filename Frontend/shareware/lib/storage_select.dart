import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kakaomap_webview/kakaomap_webview.dart';
import 'config.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'warehouse_details_page.dart'; // WarehouseDetailsPage import
import 'warehouse.dart'; // 이 파일을 import


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
  List<Warehouse> _warehouses = []; // 창고 정보 리스트
  TextEditingController _searchController = TextEditingController();
  double? _currentLat; // 현재 위치의 위도
  double? _currentLon; // 현재 위치의 경도
  bool _isLoading = false; // 로딩 상태 변수

  @override
  void initState() {
    super.initState();
    _getCurrentLocation(); // 현재 위치 가져오기
  }

  void _updateCurrentLocation(double lat, double lon) {
    setState(() {
      _currentLat = lat;
      _currentLon = lon;
    });

    // 현재 위치로 지도 중심 이동
    if (_webViewController != null) {
      _webViewController.runJavascript(
          'map.setCenter(new kakao.maps.LatLng($_currentLat, $_currentLon));');
    }
  }

  // 위치 정보 권한 및 서비스 확인 후 현재 위치 가져오기
  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true; // 로딩 시작
    });

    bool serviceEnabled;
    LocationPermission permission;

    // 위치 서비스 활성화 여부 확인
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _isLoading = false; // 로딩 종료
      });
      return Future.error('Location services are disabled.');
    }

    // 위치 권한 확인
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _isLoading = false; // 로딩 종료
        });
        return Future.error('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _isLoading = false; // 로딩 종료
      });
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // 현재 위치 가져오기
    Position position = await Geolocator.getCurrentPosition();
    _updateCurrentLocation(position.latitude, position.longitude); // 현재 위치 업데이트

    // 위치가 로드된 후 지도의 중심을 업데이트
    if (_webViewController != null) {
      _webViewController.runJavascript(
        'map.setCenter(new kakao.maps.LatLng(${position.latitude}, ${position.longitude}));',
      );
    }

    setState(() {
      _isLoading = false; // 로딩 종료
    });
  }

  // 모든 창고 좌표 및 정보 API 호출
  Future<List<Warehouse>> fetchAllWarehouseCoordinates() async {
    final response =
        await http.get(Uri.parse('${Config.local}/map/all/warehouses'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      print("API 응답 데이터: $data"); // 응답 데이터 출력
      return data.map((item) => Warehouse.fromJson(item)).toList();
    } else {
      throw Exception('창고를 찾을 수 없습니다');
    }
  }

  // 창고 이름을 통해 특정 창고 좌표 및 정보 가져오는 API 호출
  Future<Warehouse?> fetchWarehouseByName(String name) async {
    final response = await http.get(Uri.parse('${Config.local}/map/$name'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return Warehouse.fromJson(data);
    } else {
      return null; // 창고를 찾을 수 없을 경우 null 반환
    }
  }

  // 32번째부터 10개 창고 선택
  List<Warehouse> _selectSubsetOfWarehouses(List<Warehouse> warehouses) {
    if (warehouses.length < 32) {
      return []; // 데이터가 32개 미만인 경우 빈 리스트 반환
    }
    return warehouses.skip(32).take(10).toList();
  }

  // 검색된 창고 마커 추가 스크립트
  String _generateSearchMarkerScript(Warehouse warehouse) {
    return '''
      var searchMarkerPosition = new kakao.maps.LatLng(${warehouse.lat}, ${warehouse.lon});
      var searchMarker = new kakao.maps.Marker({
        position: searchMarkerPosition
      });
      searchMarker.setMap(map);
      markers.push(searchMarker);
    ''';
  }

  // 32번째부터 10개 창고 마커 추가 스크립트
  String _generateMarkersScript() {
    StringBuffer script = StringBuffer();
    script.writeln('var markers = [];'); // 마커 배열 초기화

    // 32번째부터 10개만 표시
    List<Warehouse> limitedWarehouses = _selectSubsetOfWarehouses(_warehouses);

    for (var i = 0; i < limitedWarehouses.length; i++) {
      var warehouse = limitedWarehouses[i];
      script.writeln(''' 
      var markerPosition$i = new kakao.maps.LatLng(${warehouse.lat}, ${warehouse.lon});
      var marker$i = new kakao.maps.Marker({
        position: markerPosition$i
      });
      marker$i.setMap(map);
      markers.push(marker$i);
      ''');
    }

    return script.toString();
  }

  // 마커 초기화
  void _clearMarkers() {
    if (_webViewController != null) {
      _webViewController
          .runJavascript(
              "if (markers) { markers.forEach(marker => marker.setMap(null)); markers = []; }")
          .then((_) {
        print("기존 마커 제거 성공");
      }).catchError((error) {
        print("기존 마커 제거 오류: $error");
      });
    } else {
      print("WebViewController가 아직 초기화되지 않았습니다."); // 디버깅 메시지
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

  // 모든 창고 좌표 및 정보 로드
  Future<void> _loadAllWarehouseCoordinates() async {
    try {
      _warehouses = await fetchAllWarehouseCoordinates(); // 모든 창고 정보 가져오기
      print("불러온 창고 수: ${_warehouses.length}"); // 불러온 창고 수 출력

      // 32번째부터 10개의 창고만 선택하여 마커와 리스트에 표시
      List<Warehouse> selectedWarehouses = _selectSubsetOfWarehouses(_warehouses);

      setState(() {
        _warehouses = selectedWarehouses; // 바텀시트에 표시할 창고 정보를 업데이트
        _addMarkers(); // 마커 추가
      });
    } catch (e) {
      print('좌표를 가져오는 중 오류 발생: $e');
    }
  }

  // 검색을 통한 창고 마커 및 지도 중심 이동
  Future<void> _searchWarehouse(String name) async {
    try {
      _clearMarkers();

      final warehouse = await fetchWarehouseByName(name);
      if (warehouse != null) {
        setState(() {
          _warehouses = [warehouse]; // 검색된 창고만 마커로 표시

          // 검색된 창고 위치에 마커 추가
          final searchMarkerScript = _generateSearchMarkerScript(warehouse);
          _webViewController.runJavascript(searchMarkerScript).then((_) {
            print("검색된 창고 마커 추가 성공");
          }).catchError((error) {
            print("검색된 창고 마커 추가 오류: $error");
          });

          // 검색된 창고 위치로 지도 중심 이동
          _webViewController.runJavascript(
            'map.setCenter(new kakao.maps.LatLng(${warehouse.lat}, ${warehouse.lon}));',
          );
        });
      } else {
        print('검색된 창고가 없습니다');
      }
    } catch (e) {
      print('검색 중 오류 발생: $e');
    }
  }

  void _navigateToWarehouseDetails(Warehouse warehouse) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WarehouseDetailsPage(warehouse: warehouse),
      ),
    );
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
                lat: _currentLat ?? 0.0,
                lng: _currentLon ?? 0.0,
                showMapTypeControl: true,
                showZoomControl: true,
                draggableMarker: true,
                mapType: MapType.BICYCLE,
                mapController: (controller) {
                  _webViewController = controller;
                  _getCurrentLocation();
                  _loadAllWarehouseCoordinates();
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
        if (_isLoading)
          Center(
            child: CircularProgressIndicator(),
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
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      // 핸들을 클릭하면 기본적인 드래그 동작을 시작할 수 있도록
                      Scrollable.of(context)?.position?.jumpTo(
                          Scrollable.of(context)!.position.pixels + 100);
                    },
                    child: Container(
                      width: 60,
                      height: 8, // 핸들의 높이를 늘림
                      margin: EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: _warehouses.length,
                      itemBuilder: (context, index) {
                        final warehouse = _warehouses[index];
                        return ListTile(
                          title: Text(warehouse.name),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('주소: ${warehouse.address}'),
                              Text('연락처: ${warehouse.contact}'),
                              Text('영업시간: ${warehouse.hours}'),
                              Text(
                                '주차 가능 여부: ${warehouse.getParkingAvailability()}',
                              ),
                            ],
                          ),
                          onTap: () => _navigateToWarehouseDetails(warehouse),
                        );
                      },
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
}}
