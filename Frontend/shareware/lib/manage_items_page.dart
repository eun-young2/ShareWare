import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

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
                          // 수정 로직
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

class RegisterItemsPage extends StatefulWidget {
  final Function(Map<String, dynamic>) onSubmit;

  RegisterItemsPage({required this.onSubmit});

  @override
  _RegisterItemsPageState createState() => _RegisterItemsPageState();
}

class _RegisterItemsPageState extends State<RegisterItemsPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController =
      TextEditingController(text: '1'); // 물건수량 초기값 1
  final TextEditingController _descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  List<XFile> _images = []; // 이미지 리스트

  // 카메라에서 사진 촬영
  Future<void> _pickImage() async {
    if (_images.length < 5) {
      final pickedFile = await _picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        setState(() {
          _images.add(pickedFile);
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('최대 5장의 사진만 추가할 수 있습니다.')),
      );
    }
  }

  // 물건 등록 완료 처리
  void _completeRegistration() {
    final newItem = {
      'name': _nameController.text,
      'quantity': _quantityController.text,
      'description': _descriptionController.text,
      'images': _images.map((image) => image.path).toList(), // 이미지 경로 리스트
    };
    widget.onSubmit(newItem); // 부모 페이지로 데이터 전달
    Navigator.pop(context); // 뒤로 가기
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // 뒤로가기
          },
        ),
        title: Text('내 물건 등록'),
        actions: [
          TextButton(
            onPressed: () {
              print('임시저장 클릭됨');
            },
            child: Text(
              '임시저장',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: _pickImage, // 사진 클릭 시 카메라 실행
              child: Container(
                height: 150,
                color: Colors.grey[300],
                child: _images.isEmpty
                    ? Center(child: Text('사진 추가 (최대 5장)'))
                    : PageView(
                        children: _images
                            .map((image) => Image.file(
                                  File(image.path),
                                  fit: BoxFit.cover,
                                ))
                            .toList(),
                      ),
              ),
            ),
            SizedBox(height: 16),
            Text("물건 이름"),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: '물건이름', // placeholder
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            Text("물건 수량"),
            TextField(
              controller: _quantityController,
              keyboardType: TextInputType.number, // 숫자 입력만 가능
              decoration: InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            Text("설명"),
            TextField(
              controller: _descriptionController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: '보관 불가 품목', // placeholder
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        width: double.infinity,
        height: 48.0,
        color: Color(0xFFAFD485),
        child: TextButton(
          onPressed: _completeRegistration, // 작성 완료 처리
          child: Text(
            '작성 완료',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
