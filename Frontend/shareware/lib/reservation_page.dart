import 'package:flutter/material.dart';
import 'reservation.dart'; // 이미 존재하는 Reservation 모델을 사용
import 'reservation_service.dart'; // ReservationService 클래스
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';

class ReservationPage extends StatefulWidget {
  @override
  _ReservationPageState createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> {
  late Future<List<Reservation>> futureReservations;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;

    // token이 null일 경우 예외를 던지거나 다른 처리
    if (token == null || token.isEmpty) {
      throw Exception('유효하지 않은 토큰입니다.'); // 예외 처리
    }
    futureReservations =
        ReservationService().fetchReservations(token); // API 호출
  }

  String getDisplayStatus(String status) {
    switch (status) {
      case 'in_use':
        return '사용중';
      case 'confirmed':
        return '예약확정';
      case 'completed':
        return '사용완료';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('예약 관리'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            SizedBox(height: 10),
            Expanded(
              child: FutureBuilder<List<Reservation>>(
                future: futureReservations,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('예약 내역이 없습니다.'));
                  } else {
                    List<Reservation> reservations = snapshot.data!;

                    return SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: PaginatedDataTable(
                        columns: [
                          DataColumn(label: Text('')),
                          DataColumn(label: Text('예약상태')),
                          DataColumn(label: Text('예약자')),
                          DataColumn(label: Text('사용기간')),
                        ],
                        source: ReservationDataSource(
                            reservations, getDisplayStatus),
                        columnSpacing: 16,
                        horizontalMargin: 16,
                        rowsPerPage: 7,
                        showCheckboxColumn: false,
                      ),
                    );
                  }
                },
              ),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

class ReservationDataSource extends DataTableSource {
  final List<Reservation> reservations;
  final String Function(String) getDisplayStatus;

  ReservationDataSource(this.reservations, this.getDisplayStatus);

  @override
  DataRow getRow(int index) {
    // index가 reservations 리스트 범위를 벗어나는 경우 빈 DataRow 반환
    if (index >= reservations.length) {
      return DataRow(cells: [
        DataCell(Text('')),
        DataCell(Text('')),
        DataCell(Text('')),
        DataCell(Text('')),
      ]);
    }

    final reservation = reservations[index];
    return DataRow(cells: [
      DataCell(
        GestureDetector(
          onTap: () {
            // 예약 ID 클릭 시 상세 페이지 이동 로직 추가 가능
          },
          child: Text(reservation.reservIdx.toString()),
        ),
      ),
      DataCell(
        Container(
          width: 70,
          color: reservation.reservStatus == 'confirmed'
              ? Colors.orange[400]
              : reservation.reservStatus == 'in_use'
                  ? Colors.green[300]
                  : Colors.blueAccent,
          padding: EdgeInsets.all(4),
          child: Text(
            getDisplayStatus(reservation.reservStatus),
            style: TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ),
      ),
      DataCell(Text(reservation.userName)),
      DataCell(
          Text('${reservation.startDate} ~ ${reservation.expirationDate}')),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => reservations.length;

  @override
  int get selectedRowCount => 0;
}
