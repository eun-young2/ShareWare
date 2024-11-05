class Reservation {
  final int reservIdx;
  final String reservStatus;
  final String userName;
  final String startDate;
  final String expirationDate;

  Reservation({
    required this.reservIdx,
    required this.reservStatus,
    required this.userName,
    required this.startDate,
    required this.expirationDate,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      reservIdx: json['reserv_idx'],
      reservStatus: json['reserv_status'],
      userName: json['user_name'],
      startDate: json['start_date'],
      expirationDate: json['expiration_date'],
    );
  }
}
