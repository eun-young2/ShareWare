import 'package:flutter_dotenv/flutter_dotenv.dart';

class Config {
  static String get local =>
      dotenv.env['LOCAL'] ?? 'http://default.url'; // 기본값 설정
}

// class Config {
//   static const String apiUrl = 'http://192.168.70.158:3000';
// }

