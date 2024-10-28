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
  String? _selectedWarehouse = '전체'; // 선택된 지점 상태
  List<String> _warehouseList = []; // 지점 목록

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
    _loadUserWarehouses(); // 사용자 지점 정보 불러오기
  }

  // 새로운 물품 추가 함수
  void _addItem(Map<String, dynamic> item) {
    setState(() {
      _items.add(item); // 전달된 물품을 리스트에 추가
    });
  }

  // 물품 수정 함수
  void _editItem(int index, Map<String, dynamic> newItem) {
    setState(() {
      _items[index] = newItem; // 수정된 물품으로 업데이트
    });
  }

  // 사용자 관련 지점 정보 불러오기
  Future<void> _loadUserWarehouses() async {
    try {
      List<String> warehouses = await fetchUserWarehouses(context);
      setState(() {
        _warehouseList = warehouses;
        if (_warehouseList.isNotEmpty) {
          _selectedWarehouse = _warehouseList.first; // 첫 번째 지점 자동 선택
        } else {
          _selectedWarehouse = null; // 지점이 없을 경우 null로 설정
        }
      });
    } catch (e) {
      print('지점 정보를 불러오는 중 오류 발생: $e');
    }
  }

  Future<List<String>> fetchUserWarehouses(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (authProvider.token != null) {
      final response = await http.get(
        Uri.parse('${Config.local}/product/user/warehouses'),
        headers: {
          'Authorization': 'Bearer ${authProvider.token}', // JWT 토큰 추가
        },
      );
      print('서버 응답 상태 코드: ${response.statusCode}'); // 응답 상태 코드 출력
      print('서버 응답 본문: ${response.body}'); // 서버 응답 본문 출력

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => item.toString()).toList(); // 지점 목록 반환
      } else {
        throw Exception('지점 정보를 불러올 수 없습니다.');
      }
    } else {
      throw Exception('사용자가 인증되지 않았습니다.');
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
                  child: DropdownButton<String>(
                    value: _selectedWarehouse,
                    items: _warehouseList.isNotEmpty
                        ? _warehouseList.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList()
                        : [
                            DropdownMenuItem(value: '전체', child: Text('지점 없음'))
                          ], // 기본값 설정
                    onChanged: (newValue) {
                      setState(() {
                        _selectedWarehouse = newValue!;
                        // 필터링 로직 여기에 추가 예정
                      });
                    },
                    hint: Text('지점을 선택하세요'), // 초기 상태에서 힌트 메시지 추가
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
                    leading: _items[index]['images'].isNotEmpty
                        ? Image.file(File(_items[index]['images'][0]),
                            width: 50, height: 50)
                        : Icon(Icons.image, size: 50), // 물품 이미지 자리
                    title: Text(_items[index]['name']!),
                    subtitle: Text(
                      _items[index]['description']!,
                      maxLines: 3, // 최대 3줄까지만 노출
                      overflow: TextOverflow.ellipsis, // 초과된 부분은 '...'으로 처리
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          // 수정 로직 - 선택한 아이템의 상세 페이지로 이동
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RegisterItemsPage(
                                onSubmit: (editedItem) {
                                  _editItem(index, editedItem); // 수정된 아이템 업데이트
                                },
                                existingItem: _items[index], // 선택한 아이템 정보 전달
                              ),
                            ),
                          );
                        } else if (value == 'delete') {
                          setState(() {
                            _items.removeAt(index);
                          });
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
                  onSubmit: _addItem, // RegisterItemsPage에서 물품을 추가할 때 호출
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
