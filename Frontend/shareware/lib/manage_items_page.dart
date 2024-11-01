import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'register_items.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'providers/auth_provider.dart';
import 'config.dart';
import 'dart:convert';
import 'my_warehouse_page.dart';

class ManageItemsPage extends StatefulWidget {
  final int selectedIndex;

  ManageItemsPage({required this.selectedIndex});

  @override
  _ManageItemsPageState createState() => _ManageItemsPageState();
}

class _ManageItemsPageState extends State<ManageItemsPage> {
  late int _selectedIndex = 0;
  List<Map<String, dynamic>> _items = []; // 물품 목록 상태 변수
  Map<String, dynamic>? _selectedWarehouse; // 선택된 지점 상태
  List<Map<String, dynamic>> _warehouseList =
      []; // 지점 목록 (unit_idx, wh_branch_name 포함)
  Map<String, List<Map<String, dynamic>>> _cachedItems = {}; // 물품 목록 캐시 저장소

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
    _loadUserWarehouses(); // 사용자 지점 정보 불러오기
  }

  // 서버로부터 사용자의 지점 정보 가져오기
  Future<List<Map<String, dynamic>>> fetchUserWarehouses(
      BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (authProvider.token != null) {
      final response = await http.get(
        Uri.parse('${Config.local}/product/user/warehouses'),
        headers: {
          'Authorization': 'Bearer ${authProvider.token}', // JWT 토큰
        },
      );
      print('서버 응답 상태 코드: ${response.statusCode}');
      print('서버 응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<
            Map<String,
                dynamic>>(); // unit_idx, wh_branch_name을 포함한 지점 정보 리스트 반환
      } else {
        throw Exception('지점 정보를 불러올 수 없습니다.');
      }
    } else {
      throw Exception('사용자가 인증되지 않았습니다.');
    }
  }

  // 지점 데이터를 가져온 후, UI 상태 업데이트
  Future<void> _loadUserWarehouses() async {
    try {
      List<Map<String, dynamic>> warehouses =
          await fetchUserWarehouses(context);
      if (warehouses.isNotEmpty) {
        setState(() {
          _warehouseList = warehouses;
          _selectedWarehouse = _warehouseList.first; // 기본적으로 첫번째 지점 선택
        });
        await _loadItemsForSelectedWarehouse(); // 선택된 지점의 물품 목록 로드
      } else {
        setState(() {
          _warehouseList = [];
          _selectedWarehouse = null;
        });
      }
    } catch (e) {
      print('지점 정보를 불러오는 중 오류 발생: $e');
    }
  }

  // 사용자가 선택한 지점, 유닛에 해당하는 보관 물품 목록 불러오기
  Future<void> _loadItemsForSelectedWarehouse() async {
    if (_selectedWarehouse == null) return;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (authProvider.token != null) {
      final whIdx = _selectedWarehouse!['wh_idx'];
      final unitIdx = _selectedWarehouse!['unit_idx'];
      final cacheKey = '$whIdx-$unitIdx';

      // 캐시에 해당 키가 있는지 확인
      if (_cachedItems.containsKey(cacheKey)) {
        setState(() {
          _items = _cachedItems[cacheKey]!; // 캐시된 데이터 사용
        });
        print('캐시에서 데이터 로드됨: $cacheKey');
        return; // 캐시된 데이터 사용 후 함수 종료
      }

      try {
        final response = await http.get(
          Uri.parse(
              '${Config.local}/product/items?wh_idx=$whIdx&unit_idx=$unitIdx'),
          headers: {
            'Authorization': 'Bearer ${authProvider.token}', // JWT 토큰
          },
        );

        print('서버 응답 상태 코드: ${response.statusCode}');
        print('서버 응답 본문: ${response.body}');

        if (response.statusCode == 200) {
          final List<dynamic> data = jsonDecode(response.body);
          setState(() {
            _items = data.cast<Map<String, dynamic>>(); // 물품 목록을 업데이트
            _cachedItems[cacheKey] = _items; // 캐시에 데이터 저장
          });
        } else {
          print('에러 상태 코드: ${response.statusCode}');
          print('에러 메시지: ${response.body}'); // 서버로부터 받은 오류 메시지 출력
        }
      } catch (e) {
        print('물품 목록을 불러오는 중 오류 발생: $e');
      }
    }
  }

  // 새로운 물품 등록 함수
  void _addItem(Map<String, dynamic> item) {
    setState(() {
      _items.add({
        'name': item['name'] ?? '이름 없음', // name이 없으면 기본값 설정
        'description': item['description'] ?? '설명 없음',
        'prod_img': item['prod_img'] ?? []
      });
    });
  }

  void _editItem(int index, Map<String, dynamic> newItem) {
    print("Edited item data: $newItem"); // 전달된 데이터 확인
    setState(() {
      _items[index] = {
        ..._items[index],
        ...newItem['data'] // 기존 데이터를 유지하면서 새로운 데이터 업데이트
      };
    });
  }

  // 물품 삭제 함수
  Future<void> _deleteItem(int prodIdx) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    print('삭제 요청 prodIdx: $prodIdx'); // prodIdx 값 확인용 로그

    try {
      final response = await http.delete(
        Uri.parse('${Config.local}/product/delete/$prodIdx'),
        headers: {
          'Authorization': 'Bearer ${authProvider.token}', // JWT 토큰
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('물품이 성공적으로 삭제되었습니다.')),
        );
        print('물품이 성공적으로 삭제되었습니다.');

        // 삭제된 물품 데이터가 포함되어 있던 캐시 삭제
        if (_selectedWarehouse != null) {
          final cacheKey =
              '${_selectedWarehouse!['wh_idx']}-${_selectedWarehouse!['unit_idx']}';
          _cachedItems.remove(cacheKey);
        }

        await _loadItemsForSelectedWarehouse(); // 물품 목록을 다시 로드하여 UI 업데이트
      } else {
        print('물품 삭제 실패: ${response.statusCode}');
        print('서버 응답 메시지: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('물품 삭제 실패: 서버 오류가 발생했습니다.')),
        );
      }
    } catch (e) {
      print('물품 삭제 요청 중 오류 발생: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('물품 삭제 중 오류가 발생했습니다. 다시 시도해 주세요.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('내 물품 관리'),
      ),
      body: Column(
        children: [
          // 창고 선택 드롭다운 추가
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButton<Map<String, dynamic>>(
                    value: _selectedWarehouse,
                    items: _warehouseList.isNotEmpty
                        ? _warehouseList.map((Map<String, dynamic> warehouse) {
                            final displayText =
                                '${warehouse['wh_branch_name']} - ${warehouse['unit_idx']}';
                            return DropdownMenuItem<Map<String, dynamic>>(
                              value: warehouse,
                              child: Text(displayText),
                            );
                          }).toList()
                        : [
                            DropdownMenuItem(
                                value: null, child: Text('사용 중인 창고가 없습니다'))
                          ],
                    onChanged: (newValue) {
                      setState(() {
                        _selectedWarehouse = newValue;
                      });
                      if (newValue != null) {
                        _loadItemsForSelectedWarehouse(); // 선택된 지점의 물품 목록 로드
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _items.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: EdgeInsets.all(10),
                  child: ListTile(
                    leading: (_items[index]['prod_img'] != null &&
                            _items[index]['prod_img'] is String)
                        ? Image.memory(
                            base64Decode(_items[index]
                                ['prod_img']), // Base64 디코딩하여 이미지 표시
                            width: 50,
                            height: 50,
                          )
                        : Icon(Icons.image, size: 50), // 이미지가 없을 경우 기본 아이콘 표시

                    title: Text(_items[index]['prod_name'] ?? '이름 없음'),
                    subtitle: Text(
                      _items[index]['prod_info'] ?? '설명 없음',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),

                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RegisterItemsPage(
                                onSubmit: (editedItem) {
                                  _editItem(index, editedItem);
                                },
                                existingItem: _items[index],
                                selectedWarehouseData: _selectedWarehouse,
                              ),
                            ),
                          );
                        } else if (value == 'delete') {
                          final prodIdx = _items[index]['prod_idx'];
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('삭제 확인'),
                                content: Text('이 물품을 삭제하시겠습니까?'),
                                actions: [
                                  TextButton(
                                    child: Text('취소'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  TextButton(
                                    child: Text('삭제'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      _deleteItem(prodIdx); // 삭제 요청 호출
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      },
                      itemBuilder: (BuildContext context) {
                        return [
                          PopupMenuItem(
                            value: 'edit',
                            child: Text('수정하기'),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Text('삭제하기'),
                          ),
                        ];
                      },
                      icon: Icon(Icons.more_vert),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        width: double.infinity,
        height: 48.0,
        color: Color(0xFFAFD485),
        child: TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RegisterItemsPage(
                  onSubmit: _addItem,
                  selectedWarehouseData: _selectedWarehouse, // 선택된 창고 데이터 전달
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Text(
              '보관 물품 등록하기',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
