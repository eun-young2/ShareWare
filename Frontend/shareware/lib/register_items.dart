import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class RegisterItemsPage extends StatefulWidget {
  final Function(Map<String, dynamic>) onSubmit;
  final Map<String, dynamic>? existingItem; // 기존 아이템을 수정할 때 전달되는 데이터

  RegisterItemsPage({required this.onSubmit, this.existingItem});

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

  @override
  void initState() {
    super.initState();
    // 기존 아이템이 있을 경우 필드에 데이터 미리 채우기
    if (widget.existingItem != null) {
      _nameController.text = widget.existingItem!['name'];
      _quantityController.text = widget.existingItem!['quantity'];
      _descriptionController.text = widget.existingItem!['description'];
      _images = (widget.existingItem!['images'] as List<String>)
          .map((path) => XFile(path))
          .toList();
    }
  }

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
        title: Text(widget.existingItem == null ? '내 물건 등록' : '내 물건 수정'),
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
              maxLines: 3,
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
        color: Color(0xFFAFD485), // 배경색 브랜드컬러 #AFD485
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
