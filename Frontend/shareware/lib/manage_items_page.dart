import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'register_items.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'providers/auth_provider.dart';
import 'config.dart';
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
  List<Map<String, dynamic>> _warehouseList = []; // 지점 목록
  Map<String, List<Map<String, dynamic>>> _cachedItems = {}; // 물품 목록 캐시 저장소

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
    _loadUserWarehouses(); // 사용자 지점 정보 불러오기
  }

  Future<List<Map<String, dynamic>>> fetchUserWarehouses(
      BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.token != null) {
      final response = await http.get(
        Uri.parse('${Config.local}/product/user/warehouses'),
        headers: {
          'Authorization': 'Bearer ${authProvider.token}',
        },
      );
      print('서버 응답 상태 코드: ${response.statusCode}');
      print('서버 응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('지점 정보를 불러올 수 없습니다.');
      }
    } else {
      throw Exception('사용자가 인증되지 않았습니다.');
    }
  }

  Future<void> _loadUserWarehouses() async {
    try {
      List<Map<String, dynamic>> warehouses =
          await fetchUserWarehouses(context);
      if (warehouses.isNotEmpty) {
        setState(() {
          _warehouseList = warehouses;
          _selectedWarehouse = _warehouseList.first;
        });
        await _loadItemsForSelectedWarehouse();
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
            'Authorization': 'Bearer ${authProvider.token}',
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
          print('에러 메시지: ${response.body}');
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
        'name': item['name'] ?? '이름 없음',
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

  Future<void> _deleteItem(int prodIdx) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    print('삭제 요청 prodIdx: $prodIdx'); // prodIdx 값 확인용 로그

    try {
      final response = await http.delete(
        Uri.parse('${Config.local}/product/delete/$prodIdx'),
        headers: {
          'Authorization': 'Bearer ${authProvider.token}',
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

        await _loadItemsForSelectedWarehouse();
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 창고 선택 드롭다운 추가
            Row(
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
            SizedBox(height: 8),

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
                              base64Decode(
                                  (_items[index]['prod_img'] as String).trim()),
                              width: 50,
                              height: 50,
                              errorBuilder: (context, error, stackTrace) {
                                print('이미지 디코딩 오류: $error');
                                return Icon(Icons.broken_image, size: 50);
                              },
                            )
                          : Icon(
                              Icons.photo_size_select_actual_outlined,
                              size: 50,
                              color: Colors.grey.shade300, // 연한 회색으로 설정
                            ),
                      title: Text(
                        _items[index]['prod_name'] ?? '이름없음',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        (_items[index]['prod_info'] == null ||
                                (_items[index]['prod_info'] as String).isEmpty)
                            ? '설명 없음'
                            : _items[index]['prod_info'] as String,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: (_items[index]['prod_info'] == null ||
                                  (_items[index]['prod_info'] as String)
                                      .isEmpty)
                              ? Colors.grey.shade400 // 설명 없음일 경우 희미한 회색
                              : Colors.grey[800], // 설명이 있을 경우 기본 색상
                        ),
                      ),
                      onTap: () async {
                        final result = await Navigator.push(
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

                        if (result == true) {
                          // 캐시 삭제하여 최신 데이터 로드
                          final cacheKey =
                              '${_selectedWarehouse?['wh_idx']}-${_selectedWarehouse?['unit_idx']}';
                          _cachedItems.remove(cacheKey); // 캐시 삭제
                          await _loadItemsForSelectedWarehouse(); // 서버에서 새 데이터 가져오기
                        }
                      },
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
                        icon: Icon(
                          Icons.more_vert,
                          color: Colors.grey[400],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

        SizedBox(
  width: double.infinity,
  height: 55,
  child: ElevatedButton(
    onPressed: () async {
      // 창고가 선택되지 않은 경우 경고 메시지 표시
      if (_selectedWarehouse == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('먼저 사용 중인 창고를 선택해 주세요.'),
            backgroundColor: Colors.black,
          ),
        );
        return; // 창고 선택을 강제로 요구하는 부분
      }

      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RegisterItemsPage(
            onSubmit: _addItem,
            selectedWarehouseData: _selectedWarehouse, // 선택된 창고 데이터 전달
          ),
        ),
      );

      if (result == true) {
        // 캐시 삭제하여 최신 데이터 로드
        final cacheKey =
            '${_selectedWarehouse?['wh_idx']}-${_selectedWarehouse?['unit_idx']}';
        _cachedItems.remove(cacheKey); // 캐시 삭제
        await _loadItemsForSelectedWarehouse(); // 서버에서 새 데이터 가져오기
      }
    },
    child: Text(
      '보관 물품 등록하기',
      style: TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),
    style: ElevatedButton.styleFrom(
      padding: EdgeInsets.symmetric(vertical: 15.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
      backgroundColor: Color(0xFFAFD485),
      foregroundColor: Colors.white,
    ),
  ),
)

          ],
        ),
      ),
    );
  }
}
