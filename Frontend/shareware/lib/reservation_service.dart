import 'dart:convert';
import 'package:http/http.dart' as http;
import 'reservation.dart'; // 이미 존재하는 Reservation 모델을 사용
import 'config.dart';
import 'providers/auth_provider.dart';
import 'package:provider/provider.dart';

class ReservationService {
  // API로부터 예약 데이터를 가져오는 함수
  Future<List<Reservation>> fetchReservations(String token) async {
    final response = await http.get(
      Uri.parse('${Config.local}/reserv/reservations'), // API URL
      headers: {
        'Authorization': 'Bearer $token', // JWT 토큰을 헤더에 추가
      },
    );

    //print('Response status: ${response.statusCode}');
    //print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      // API 호출이 성공했을 경우
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Reservation.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load reservations');
    }
  }
}
