// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';

// class RegisterItemsPage extends StatefulWidget {
//   @override
//   _RegisterItemsPageState createState() => _RegisterItemsPageState();
// }

// class _RegisterItemsPageState extends State<RegisterItemsPage> {
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _quantityController = TextEditingController(text: '1'); // 초기값 1
//   final TextEditingController _descriptionController = TextEditingController();
//   final ImagePicker _picker = ImagePicker();
//   List<XFile> _images = []; // 이미지 리스트

//   // 카메라에서 사진 촬영
//   Future<void> _pickImage() async {
//     if (_images.length < 5) {
//       final pickedFile = await _picker.pickImage(source: ImageSource.camera);
//       if (pickedFile != null) {
//         setState(() {
//           _images.add(pickedFile);
//         });
//       }
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('최대 5장의 사진만 추가할 수 있습니다.')),
//       );
//     }
//   }

//   // 물건 등록 완료 처리
//   void _completeRegistration() {
//     // 완료 로직 처리
//     print('물건 등록 완료');
//     print('이름: ${_nameController.text}');
//     print('수량: ${_quantityController.text}');
//     print('설명: ${_descriptionController.text}');
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back),
//           onPressed: () {
//             Navigator.pop(context); // 뒤로가기
//           },
//         ),
//         title: Text('내 물건 등록'),
//         actions: [
//           TextButton(
//             onPressed: () {
//               print('임시저장 클릭됨');
//             },
//             child: Text(
//               '임시저장',
//               style: TextStyle(color: Colors.white),
//             ),
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             GestureDetector(
//               onTap: _pickImage, // 사진 클릭 시 카메라 실행
//               child: Container(
//                 height: 150,
//                 color: Colors.grey[300],
//                 child: _images.isEmpty
//                     ? Center(child: Text('사진 추가 (최대 5장)'))
//                     : PageView(
//                         children: _images
//                             .map((image) => Image.file(
//                                   File(image.path),
//                                   fit: BoxFit.cover,
//                                 ))
//                             .toList(),
//                       ),
//               ),
//             ),
//             SizedBox(height: 16),
//             TextField(
//               controller: _nameController,
//               decoration: InputDecoration(
//                 labelText: '물건 이름',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             SizedBox(height: 16),
//             TextField(
//               controller: _quantityController,
//               keyboardType: TextInputType.number, // 숫자 입력만 가능
//               decoration: InputDecoration(
//                 labelText: '물건 수량',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             SizedBox(height: 16),
//             TextField(
//               controller: _descriptionController,
//               maxLines: 3,
//               decoration: InputDecoration(
//                 labelText: '설명',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//           ],
//         ),
//       ),
//       bottomSheet: Container(
//         width: double.infinity,
//         height: 48.0,
//         color: Color(0xFFAFD485), // 배경색 브랜드컬러 #AFD485
//         child: TextButton(
//           onPressed: _completeRegistration, // 작성 완료 처리
//           child: Text(
//             '작성 완료',
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class RegisterItems extends StatefulWidget {
//   final int selectedIndex;

//   RegisterItems({required this.selectedIndex});

//   @override
//   _RegisterItemsState createState() => _RegisterItemsState();
// }

// class _RegisterItemsState extends State<RegisterItems> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('내 물품 관리'),
//       ),
//       body: Center(
//         child: Text('물품 등록 내용을 여기에 표시'),
//       ),
//       bottomSheet: Container(
//         width: double.infinity,
//         height: 48.0,
//         color: Color(0xFFAFD485),
//         child: TextButton(
//           onPressed: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (context) => RegisterItemsPage()), // 새 페이지로 이동
//             );
//           },
//           child: Text(
//             '보관 물품 등록하기',
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
