import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'config.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import './manage_items_page.dart';
import 'dart:typed_data';

class RegisterItemsPage extends StatefulWidget {
  final Function(Map<String, dynamic>) onSubmit;
  final Map<String, dynamic>? existingItem;
  final Map<String, dynamic>? selectedWarehouseData;

  RegisterItemsPage(
      {required this.onSubmit, this.existingItem, this.selectedWarehouseData});

  @override
  _RegisterItemsPageState createState() => _RegisterItemsPageState();
}

class _RegisterItemsPageState extends State<RegisterItemsPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  String? _encodedImage;
  Uint8List? _decodedImage; // Base64에서 디코딩된 이미지
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingItem != null) {
      _isEditing = true;
      _nameController.text = widget.existingItem!['prod_name'];
      _descriptionController.text = widget.existingItem!['prod_info'];
      _encodedImage = widget.existingItem!['prod_img'] as String?;
      if (widget.existingItem!['prod_img'] != null) {
        _decodedImage = base64Decode(widget.existingItem!['prod_img']);
      }
    }
  }

    // 서버로 이미지 전송 메서드
  Future<void> _sendImageToServer() async {

    final url = Uri.parse('http://10.0.2.2:8000/detect_prod');
    final requestBody = jsonEncode({
      'image_data': _encodedImage, // Base64 인코딩된 이미지 데이터 전송
    });
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );

      if (response.statusCode == 200) {
        print('서버 응답 성공: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('이미지 전송 성공')),
        );
      } else {
        print('서버 응답 실패: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('이미지 전송 실패')),
        );
      }
    } catch (e) {
      print('이미지 전송 중 오류 발생: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('이미지 전송 중 오류가 발생했습니다.')),
      );
    }
  }
  // 갤러리에 이미지 저장 메서드
  Future<void> _saveImageToGallery(XFile image) async {
    if (await Permission.manageExternalStorage.isGranted) {
      try {
        final directory = await getExternalStorageDirectory();
        final imagePath =
            "${directory?.path}/${DateTime.now().toIso8601String()}.jpg";
        final File newImage = await File(image.path).copy(imagePath);

        final result = await ImageGallerySaver.saveFile(newImage.path);

        if (result['isSuccess']) {
          print("이미지가 갤러리에 저장되었습니다: ${newImage.path}");
          final scanResult = await File(imagePath).create();
          await scanResult.create(recursive: true);
          await scanResult.readAsBytes();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("이미지 첨부에 실패했습니다.")),
          );
        }
      } catch (e) {
        print("이미지 저장 오류: $e");
      }
    } else {
      final status = await Permission.manageExternalStorage.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("갤러리 저장 권한이 필요합니다. 설정에서 권한을 허용해주세요.")),
        );
        await Future.delayed(Duration(seconds: 2));
      }
    }
  }

  // 이미지 선택 메서드
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = pickedFile;
        _decodedImage = null; // 기존 디코딩된 이미지 초기화
      });

      // 새 이미지를 base64 인코딩하고 _encodedImage 업데이트
      await _encodeImageToBase64(pickedFile);

      // 갤러리에서 선택된 경우에는 이미지 저장
      if (source == ImageSource.camera) {
        _saveImageToGallery(pickedFile);
      }

      // 서버로 이미지 전송
      await _sendImageToServer();
    }
  }


  // 이미지 base64 인코딩 메서드
  Future<void> _encodeImageToBase64(XFile image) async {
    final bytes = await image.readAsBytes();
    final base64Image = base64Encode(bytes);
    setState(() {
      _encodedImage = base64Image;
    });
  }

  // 이미지 선택 옵션을 띄우는 메서드
  void _showImageSourceSelection() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('카메라 실행'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera); // 카메라에서 이미지 선택
              },
            ),
            ListTile(
              leading: Icon(Icons.photo),
              title: Text('갤러리에서 선택'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery); // 갤러리에서 이미지 선택
              },
            ),
          ],
        );
      },
    );
  }

  // 물품 등록 및 수정 함수
  Future<void> _submitItem() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.userId;
    final url = _isEditing
        ? '${Config.local}/product/update/${widget.existingItem!['prod_idx']}'
        : '${Config.local}/product/register';
    final prodImgData = _encodedImage;

    final requestBody = {
      'user_id': userId,
      'wh_idx': widget.selectedWarehouseData?['wh_idx'],
      'unit_idx': widget.selectedWarehouseData?['unit_idx'],
      'prod_name': _nameController.text,
      'prod_info': _descriptionController.text,
      'prod_img': prodImgData
    };

    final response = await (_isEditing ? http.put : http.post)(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer ${authProvider.token}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(requestBody),
    );

    print('서버 응답 상태 코드: ${response.statusCode}');
    print('서버 응답 본문: ${response.body}');

    if (response.statusCode == (_isEditing ? 200 : 201)) {
      print(_isEditing ? '물품이 성공적으로 수정되었습니다.' : '물품이 성공적으로 등록되었습니다.');
      final updatedItem = jsonDecode(response.body);
      widget.onSubmit(updatedItem);

      Navigator.pop(context, true); // true 값을 전달하여 성공적으로 등록/수정되었음을 알림
    } else {
      print('등록 실패: ${response.body}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('물품 ${_isEditing ? '수정' : '등록'} 실패: 서버 오류가 발생했습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(_isEditing ? '내 물건 수정' : '내 물건 등록'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 사진 추가 및 미리보기 영역
            Row(
              children: [
                Expanded(
                  // Row의 자식으로 Expanded 사용하여 너비를 최대화
                  child: GestureDetector(
                    onTap: _showImageSourceSelection,
                    child: Container(
                      height: 200, // 고정된 높이 설정
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey[200],
                      ),
                      child: _image == null
                          ? (_decodedImage != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.memory(
                                    _decodedImage!,
                                    fit: BoxFit.fill,
                                  ),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.camera_alt, color: Colors.grey),
                                    Text(
                                      '0/1',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ))
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.file(
                                    File(_image!.path),
                                    fit: BoxFit.fill,
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: GestureDetector(
                                      onTap: () =>
                                          setState(() => _image = null),
                                      child: CircleAvatar(
                                        radius: 12,
                                        backgroundColor: Colors.black54,
                                        child: Icon(
                                          Icons.close,
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 16),
            Text("지점명"),
            Text(
                widget.selectedWarehouseData?['wh_branch_name'] ?? '선택된 지점 없음'),
            SizedBox(height: 16),
            Text("유닛번호"),
            Text(widget.selectedWarehouseData?['unit_idx']?.toString() ??
                '유닛 없음'),
            SizedBox(height: 16),
            Text("물건 이름"),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: '물건이름',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            Text("설명"),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: '보관 불가 품목',
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
          onPressed: () {
            if (_nameController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('물품 이름을 입력해주세요')),
              );
              return;
            } else {
              _submitItem();
            }
          },
          child: Text(
            _isEditing ? '수정 완료' : '작성 완료',
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
