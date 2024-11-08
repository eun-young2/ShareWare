class Warehouse {
  final String name;
  final String address;
  final String contact;
  final String hours;
  final double lat;
  final double lon;
  final int facilities; // 주차 가능 여부 (1: 가능, 0: 불가능)
  final String imageUrl; // 창고의 이미지 URL

  Warehouse({
    required this.name,
    required this.address,
    required this.contact,
    required this.hours,
    required this.lat,
    required this.lon,
    required this.facilities,
    required this.imageUrl, // 이미지 URL 추가
  });

  // 주차 가능 여부 반환
  String getParkingAvailability() {
    return facilities == 1 ? '주차 가능' : '주차 불가능';
  }

  // 창고 이미지 자동 할당 (이미지 순서대로)
  static List<String> warehouseImages = [
    'assets/warehouse1.jpg',
    'assets/warehouse2.jpg',
    'assets/warehouse3.jpg',
  ];

  // 창고 데이터를 JSON으로부터 생성
  factory Warehouse.fromJson(Map<String, dynamic> json) {
    // wh_idx가 숫자로 잘 전달되는지 로그를 찍어보세요
    int? wh_idx = int.tryParse(json['wh_idx'].toString());

    // wh_idx 값 확인
    print("wh_idx: $wh_idx");

    // wh_idx 값이 null이거나 1보다 작을 경우, 기본값으로 1을 사용합니다.
    int index = (wh_idx != null && wh_idx >= 1) ? wh_idx! - 1 : 0;

    // 이미지 순차적으로 할당, index가 warehouseImages의 길이를 넘지 않도록 처리
    String imageUrl = warehouseImages[index % warehouseImages.length]; // 3개 이미지 순차적 할당

    return Warehouse(
      name: json['wh_branch_name'],
      address: json['wh_addr'],
      contact: json['contact_info'],
      hours: json['business_hours'],
      lat: double.parse(json['lat'].toString()),
      lon: double.parse(json['lon'].toString()),
      facilities: int.tryParse(json['facilities'].toString()) ?? 0,
      imageUrl: imageUrl, // 순차적으로 이미지 URL 할당
    );
  }
}
