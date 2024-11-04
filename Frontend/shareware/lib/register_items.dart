import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert'; // base64로 encode해서 서버로 보내기 위해
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'config.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';

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
  List<XFile> _images = [];
  final int maxImageCount = 5;
  List<String> _encodedImages = []; // base64 인코딩된 이미지 리스트
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingItem != null) {
      _isEditing = true;
      _nameController.text = widget.existingItem!['prod_name'];
      _descriptionController.text = widget.existingItem!['prod_info'];
      _encodedImages =
          List<String>.from(widget.existingItem!['prod_img'] ?? []);
    }
  }

  // 갤러리에 이미지 저장 메서드
  Future<void> _saveImageToGallery(XFile image) async {
    // 저장 권한 요청
    PermissionStatus status = await Permission.storage.request();

    // 권한이 거부된 경우 권한 요청
    if (!status.isGranted) {
      status = await Permission.storage.request();
    }

    if (status.isGranted) {
      try {
        // 이미지 저장 경로 지정
        final directory = await getExternalStorageDirectory();
        final imagePath =
            "${directory?.path}/${DateTime.now().toIso8601String()}.jpg";
        final File newImage = await File(image.path).copy(imagePath);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("이미지가 갤러리에 저장되었습니다: ${newImage.path}")),
        );
      } catch (e) {
        print("이미지 저장 오류: $e");
      }
    } else if (status.isDenied || status.isPermanentlyDenied) {
      // 권한 요청 실패 시 사용자에게 안내
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("갤러리 저장 권한이 필요합니다. 설정에서 권한을 허용해주세요.")),
      );
      // 권한이 거부되었을 경우 설정 페이지로 이동
      await openAppSettings();
    }
  }

  // 이미지 선택 메서드 수정
  Future<void> _pickImage(ImageSource source) async {
    if (_images.length < 5) {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _images.add(pickedFile);
          _encodeImageToBase64(pickedFile); // 이미지 base64 인코딩
        });
        _saveImageToGallery(pickedFile); // 선택된 이미지를 갤러리에 저장
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('최대 5장의 사진만 추가할 수 있습니다.')),
      );
    }
  }

  // 이미지 삭제 메서드
  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  // 이미지 선택 옵션을 띄우는 메서드
  void _showImageSourceSelection() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          child: Wrap(
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
          ),
        );
      },
    );
  }

  // 이미지 base64 인코딩 메서드
  Future<void> _encodeImageToBase64(XFile image) async {
    final bytes = await image.readAsBytes();
    final base64Image = base64Encode(bytes);
    setState(() {
      _encodedImages.add(base64Image);
    });
  }

  // 물품 등록 및 수정 함수
  Future<void> _submitItem() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.userId;
    final url = _isEditing
        ? '${Config.local}/product/update/${widget.existingItem!['prod_idx']}' // 수정 요청 URL
        : '${Config.local}/product/register'; // 등록 요청 URL

    final prodImgData = _encodedImages.isNotEmpty
        ? _encodedImages
        : (widget.existingItem?['prod_img'] ?? null);

    // 요청 바디 생성
    final requestBody = {
      'user_id': userId,
      'wh_idx': widget.selectedWarehouseData?['wh_idx'],
      'unit_idx': widget.selectedWarehouseData?['unit_idx'],
      'prod_name': _nameController.text,
      'prod_info': _descriptionController.text,
    };

    // prod_img가 있을 때만 requestBody에 추가
    if (prodImgData != null && prodImgData.isNotEmpty) {
      requestBody['prod_img'] = prodImgData;
    }

    // 서버에 물품 등록 및 수정 요청
    final response = await (_isEditing ? http.put : http.post)(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer ${authProvider.token}', // JWT 토큰
        'Content-Type': 'application/json',
      },
      body: jsonEncode(requestBody),
    );

    // 서버 응답 상태 코드와 본문 출력
    print('서버 응답 상태 코드: ${response.statusCode}');
    print('서버 응답 본문: ${response.body}');

    if (response.statusCode == (_isEditing ? 200 : 201)) {
      print(_isEditing ? '물품이 성공적으로 수정되었습니다.' : '물품이 성공적으로 등록되었습니다.');
      final updatedItem = jsonDecode(response.body); // 서버에서 반환된 수정된 데이터
      widget.onSubmit(updatedItem); // UI 업데이트 위해 콜백 호출
      Navigator.pop(context);
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
        title: Text(_isEditing ? '내 물건 등록' : '내 물건 수정'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 사진 추가 및 미리보기 영역
            Row(
              children: [
                // 사진 추가 버튼
                GestureDetector(
                  onTap: _showImageSourceSelection,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt, color: Colors.grey),
                        Text(
                          '${_images.length}/5',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 10),
                // 이미지 미리보기 리스트
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(_images.length, (index) {
                        return Stack(
                          children: [
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 5),
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image: FileImage(File(_images[index].path)),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              child: index == 0
                                  ? Align(
                                      alignment: Alignment.bottomCenter,
                                      child: Container(
                                        width: double.infinity,
                                        color: Colors.black54,
                                        padding:
                                            EdgeInsets.symmetric(vertical: 2),
                                        child: Text(
                                          "대표사진",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12),
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                            // 삭제 버튼
                            Positioned(
                              top: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _images.removeAt(index)),
                                child: CircleAvatar(
                                  radius: 12,
                                  backgroundColor: Colors.black54,
                                  child: Icon(Icons.close,
                                      size: 16, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
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
