class Warehouse {
  final String name;
  final String address;
  final String contact;
  final String hours;
  final double lat;
  final double lon;
  final int facilities; // 주차 가능 여부 (1: 가능, 0: 불가능)

  Warehouse({
    required this.name,
    required this.address,
    required this.contact,
    required this.hours,
    required this.lat,
    required this.lon,
    required this.facilities,
  });

  // 주차 가능 여부 반환
  String getParkingAvailability() {
    return facilities == 1 ? '주차 가능' : '주차 불가능';
  }

  factory Warehouse.fromJson(Map<String, dynamic> json) {
    return Warehouse(
      name: json['wh_branch_name'],
      address: json['wh_addr'],
      contact: json['contact_info'],
      hours: json['business_hours'],
      lat: double.parse(json['lat'].toString()),
      lon: double.parse(json['lon'].toString()),
      facilities: int.tryParse(json['facilities'].toString()) ?? 0, // String을 int로 변환
    );
  }
}
