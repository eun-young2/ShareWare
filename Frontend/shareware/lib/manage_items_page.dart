import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'register_items.dart';

class ManageItemsPage extends StatefulWidget {
  final int selectedIndex;

  ManageItemsPage({required this.selectedIndex});

  @override
  _ManageItemsPageState createState() => _ManageItemsPageState();
}

class _ManageItemsPageState extends State<ManageItemsPage> {
  late int _selectedIndex = 0;
  List<Map<String, dynamic>> _items = []; // 물품 목록 상태 변수
  String _selectedWarehouse = '전체'; // 선택된 지점 상태

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
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
                    items: <String>[
                      '전체',
                      '광주 동명점 - unit_idx',
                      '광주 충장점 - unit_idx',
                      '광주 구시청점 - unit_idx',
                    ].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedWarehouse = newValue!;
                        // 필터링 로직 여기에 추가 예정
                      });
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
