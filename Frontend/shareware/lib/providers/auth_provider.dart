import 'package:flutter/material.dart';
import 'qr_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoggedIn = false;
  String? _token;
  String? _userId;

  bool get isLoggedIn => _isLoggedIn;
  String? get token => _token;
  String? get userId => _userId;
  Map<String, String> _profile = {}; // 사용자 프로필 정보를 저장할 변수
  Map<String, String> get profile => _profile;

  Future<void> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token != null) {
      _isLoggedIn = true;
      _token = token;
      await getProfile(); // 로그인 상태일 경우 프로필 정보 가져오기
      notifyListeners(); // 상태 변화 알림
    }
  }

  Future<void> login(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    _isLoggedIn = true;
    _token = token;
    await getProfile(); // 로그인 후 프로필 정보 가져오기
    notifyListeners(); // 상태 변화 알림
  }

  Future<void> logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // QRProvider의 resetQRCode 호출
    final qrProvider = Provider.of<QRProvider>(context, listen: false);
    qrProvider.resetQRCode(); // 로그아웃 시 QR 코드 리셋
    print('QR리셋');

    // CCTV 스트림 연결 해제 시도 및 결과 확인
    bool isStreamDisconnected = await disconnCCTVStream();
    if (isStreamDisconnected) {
      print('CCTV 스트림이 성공적으로 해제되었습니다.');
    } else {
      print('CCTV 스트림 해제에 실패했습니다.');
    }

    await prefs.remove('token');
    _isLoggedIn = false;
    _token = null;
    _profile = {}; // 프로필 정보 초기화
    print('로그아웃 토큰삭제');
    notifyListeners(); // 상태 변화 알림
  }

  Future<void> setUserId(String userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId); // SharedPreferences에 저장
    _userId = userId; // 메모리에도 저장
    notifyListeners(); // 상태 변화 알림
  }

// 서버에 CCTV 스트림을 끊는 요청을 보내는 메서드
  Future<bool> disconnCCTVStream() async {
    final String apiUrl = '${Config.local}/rtsp/disconnect';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        print('서버에서 스트림 연결 해제 성공');
        return true; // 성공적으로 해제된 경우
      } else {
        print('스트림 연결 해제 실패: ${response.statusCode}');
        return false; // 해제 실패
      }
    } catch (e) {
      print('스트림 해제 요청 중 오류 발생: $e');
      return false; // 요청 중 오류 발생
    }
  }

//프로필 가져오기
  Future<void> getProfile() async {
    if (_token == null) return;

    final url = '${Config.local}/user/profile'; // 서버의 프로필 엔드포인트
    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $_token'}, // 토큰을 포함한 요청
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _profile = {
        'user_id': data['user_id'],
        'user_name': data['user_name'],
        'user_phone': data['user_phone'],
      };
      notifyListeners(); // 상태 변화 알림
    } else {
      print('프로필 정보를 불러오는 데 실패했습니다.');
    }
  }

//휴대폰번호 변경
  Future<bool> updatePhoneNumber(String newPhone) async {
    if (_token == null) return false;

    final url = '${Config.local}/user/update-phone';
    final response = await http.put(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $_token',
        'Content-Type': 'application/json'
      },
      body: json.encode({'newPhone': newPhone}),
    );

    if (response.statusCode == 200) {
      _profile['user_phone'] = newPhone; // 프로필 정보 업데이트
      notifyListeners(); // 상태 변경 알림
      return true;
    } else {
      print('휴대폰 번호 변경 실패: ${response.body}');
      return false;
    }
  }

  // 회원 탈퇴
  Future<bool> deleteAccount() async {
    if (_token == null) return false;

    final url = '${Config.local}/user/delete-account';

    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $_token'},
      );

      if (response.statusCode == 200) {
        // 회원 탈퇴 성공 시 상태 초기화
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.remove('token'); // 토큰 삭제
        _isLoggedIn = false;
        _token = null;
        _profile = {};
        notifyListeners(); // 상태 변화 알림
        return true;
      } else {
        print('회원 탈퇴 실패: ${response.body}');
        return false;
      }
    } catch (e) {
      print('회원 탈퇴 중 오류 발생: $e');
      return false;
    }
  }
}
