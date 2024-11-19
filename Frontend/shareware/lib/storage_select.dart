import 'dart:convert'; // base64 인코딩을 위해 추가된 부분
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle; // base64 인코딩을 위해 추가된 부분
import 'package:http/http.dart' as http;
import 'package:kakaomap_webview/kakaomap_webview.dart';
import 'config.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'warehouse_details_page.dart'; // WarehouseDetailsPage import
import 'warehouse.dart'; // Warehouse 모델 import

const String kakaoMapKey = 'cb8f3da28528e158b5e76f2e88e968b8';

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
  Warehouse? _searchedWarehouse;

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
      _webViewController
          .runJavascript('map.setLevel(8);'); // 값이 작을수록 확대되고, 클수록 축소됨
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true; // 로딩 시작
    });

    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _isLoading = false; // 로딩 종료
      });
      return Future.error('Location services are disabled.');
    }

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
      return Future.error('Location permissions are permanently denied.');
    }

    Position position = await Geolocator.getCurrentPosition();
    _updateCurrentLocation(position.latitude, position.longitude); // 현재 위치 업데이트

    if (_webViewController != null) {
      _webViewController.runJavascript(
        'map.setCenter(new kakao.maps.LatLng(${position.latitude}, ${position.longitude}));',
      );
    }

    setState(() {
      _isLoading = false; // 로딩 종료
    });
  }

  Future<List<Warehouse>> fetchAllWarehouseCoordinates() async {
    final response =
        await http.get(Uri.parse('${Config.local}/map/all/warehouses'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => Warehouse.fromJson(item)).toList();
    } else {
      throw Exception('창고를 찾을 수 없습니다');
    }
  }

  Future<Warehouse?> fetchWarehouseByName(String name) async {
    final response = await http.get(Uri.parse('${Config.local}/map/$name'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return Warehouse.fromJson(data);
    } else {
      return null;
    }
  }

  Future<String> _loadLogoAsBase64() async {
    final bytes = await rootBundle.load('assets/ShareWare_logo.png');
    return base64Encode(bytes.buffer.asUint8List());
  }

  String _generateMarkersScript(String logoDataUri) {
    StringBuffer script = StringBuffer();
    script.writeln('var markers = [];');

    for (var i = 0; i < _warehouses.length; i++) {
      var warehouse = _warehouses[i];
      script.writeln('''
      var markerPosition$i = new kakao.maps.LatLng(${warehouse.lat}, ${warehouse.lon});
      var marker$i = new kakao.maps.Marker({
        position: markerPosition$i
      });
      marker$i.setMap(map);
      markers.push(marker$i);

      var content = `
        <div style="padding:10px; background-color:#fff; border:1px solid #AFD485; border-radius: 3px; font-size: 14px; white-space: nowrap; box-shadow: 2px 2px 5px rgba(0, 0, 0, 0.2); text-align: center;">
          <img src="$logoDataUri" style="width: 40px; height: 40px; margin-bottom: 5px;" />
          <div style="font-weight: bold; font-size: 16px;">${warehouse.name}</div>
          <div>${warehouse.address}</div>
        </div>
      `;
      var customOverlay$i = new kakao.maps.CustomOverlay({
        position: markerPosition$i,
        content: content,
        yAnchor: 1.2
      });

      kakao.maps.event.addListener(marker$i, 'click', function() {
        customOverlay$i.setMap(map);
      });

      kakao.maps.event.addListener(map, 'click', function() {
        customOverlay$i.setMap(null);
      });
      ''');
    }

    return script.toString();
  }

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
      print("WebViewController가 아직 초기화되지 않았습니다.");
    }
  }

  void _addMarkers() async {
    if (_webViewController != null) {
      final logoBase64 = await _loadLogoAsBase64();
      final logoDataUri = 'data:image/png;base64,$logoBase64';
      final markersScript = _generateMarkersScript(logoDataUri);
      _webViewController.runJavascript(markersScript).then((_) {
        print("JavaScript 실행 성공: 마커 추가됨");

        if (_warehouses.isNotEmpty) {
          final warehouse = _warehouses.first;
          _webViewController.runJavascript(
            'map.setCenter(new kakao.maps.LatLng(${warehouse.lat}, ${warehouse.lon}));',
          );
          _webViewController.runJavascript('map.setLevel(8);');
        }
      }).catchError((error) {
        print("JavaScript 실행 오류: $error");
      });
    } else {
      print("WebViewController가 아직 초기화되지 않았습니다.");
    }
  }

  Future<void> _loadAllWarehouseCoordinates() async {
    try {
      _warehouses = await fetchAllWarehouseCoordinates();
      print("불러온 창고 수: ${_warehouses.length}");

      setState(() {
        _addMarkers();
      });
    } catch (e) {
      print('좌표를 가져오는 중 오류 발생: $e');
    }
  }

  Future<void> _searchWarehouse(String name) async {
    try {
      _clearMarkers();
      final warehouse = await fetchWarehouseByName(name);
      if (warehouse != null) {
        final logoBase64 = await _loadLogoAsBase64();
        final logoDataUri = 'data:image/png;base64,$logoBase64';
        final searchMarkerScript = '''
          var searchMarkerPosition = new kakao.maps.LatLng(${warehouse.lat}, ${warehouse.lon});
          var searchMarker = new kakao.maps.Marker({
            position: searchMarkerPosition
          });
          searchMarker.setMap(map);
          var content = `
            <div style="padding:10px; background-color:#fff; border:1px solid #AFD485; border-radius: 3px; font-size: 14px; white-space: nowrap; box-shadow: 2px 2px 5px rgba(0, 0, 0, 0.2); text-align: center;">
              <img src="$logoDataUri" style="width: 40px; height: 40px; margin-bottom: 5px;" />
              <div style="font-weight: bold; font-size: 16px;">${warehouse.name}</div>
              <div>${warehouse.address}</div>
            </div>
          `;
          var customOverlay = new kakao.maps.CustomOverlay({
            position: searchMarkerPosition,
            content: content,
            yAnchor: 1.2
          });
          customOverlay.setMap(map);
        ''';
        _webViewController.runJavascript(searchMarkerScript).then((_) {
          print("검색된 창고 마커 추가 성공");
          _webViewController.runJavascript(
            'map.setCenter(new kakao.maps.LatLng(${warehouse.lat}, ${warehouse.lon}));',
          );
          _webViewController.runJavascript('map.setLevel(8);');
        });
        setState(() {
          _searchedWarehouse = warehouse;
        });
      } else {
        print('창고를 찾을 수 없습니다.');
        setState(() {
          _searchedWarehouse = null;
        });
      }
    } catch (e) {
      print('창고 검색 중 오류 발생: $e');
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
        automaticallyImplyLeading: false,
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
                        Scrollable.of(context)?.position?.jumpTo(
                            Scrollable.of(context)!.position.pixels + 100);
                      },
                      child: Container(
                        width: 60,
                        height: 8,
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
                        itemCount:
                            _searchedWarehouse != null ? 1 : _warehouses.length,
                        itemBuilder: (context, index) {
                          final warehouse =
                              _searchedWarehouse ?? _warehouses[index];

                          // warehouse.imageUrl 값이 비어있는지 확인하는 print문 추가
                          print(
                              "Checking imageUrl for warehouse ${warehouse.name}: ${warehouse.imageUrl}");

                          // warehouse.imageUrl 값이 비어있으면 순차적인 이미지 사용
                          String imageUrl = warehouse.imageUrl.isNotEmpty
                              ? 'assets/warehouse${(index % 6) + 1}.jpg' // imageUrl이 비어 있지 않으면 그대로 사용
                              : warehouse.imageUrl; // index에 따라 순차적으로 이미지 사용

                          return ListTile(
                            leading: Image.asset(
                              imageUrl,
                              width: 70,
                              height: 70,
                              fit: BoxFit.cover,
                            ),
                            title: Text(
                              warehouse.name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold, // 지점명 폰트 두껍게
                              ),
                            ),
                            subtitle: Text('${warehouse.address}'),
                            trailing: Text(
                              "영업중",
                              style: TextStyle(
                                color: Color(0xFFAFD485), // 파란색 텍스트
                                fontWeight: FontWeight.bold,
                              ),
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
  }
}
