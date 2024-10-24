// providers/auth_provider.dart

import 'package:flutter/material.dart';
import 'qr_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoggedIn = false;
  String? _token;

  bool get isLoggedIn => _isLoggedIn;
  String? get token => _token;

  Future<void> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token != null) {
      _isLoggedIn = true;
      _token = token;
      notifyListeners(); // 상태 변화 알림
    }
  }

  Future<void> login(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    _isLoggedIn = true;
    _token = token;
    notifyListeners(); // 상태 변화 알림
  }

  Future<void> logout(context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // QRProvider의 resetQRCode 호출
    final qrProvider = Provider.of<QRProvider>(context, listen: false);
    qrProvider.resetQRCode(); // 로그아웃 시 QR 코드 리셋
    print('QR리셋');

    await prefs.remove('token');
    _isLoggedIn = false;
    _token = null;
    print('로그아웃 토큰삭제');
    notifyListeners(); // 상태 변화 알림
  }
}
