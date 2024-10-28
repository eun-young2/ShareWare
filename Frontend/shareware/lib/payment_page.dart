import 'package:flutter/material.dart';
import 'package:flutter_application_33/qr_page.dart';
import 'package:intl/intl.dart';

class PaymentPage extends StatefulWidget {
  final String warehouseName;

  PaymentPage({required this.warehouseName});

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  DateTime? selectedDate; // 선택된 날짜를 저장할 변수
  String selectedUnitType = '큐브'; // 선택된 유닛 유형 기본값
  int selectedWeeks = 1; // 선택된 이용 기간 (주 단위)
  int unitPrice = 0; // 기본 가격

  @override
  void initState() {
    super.initState();
    unitPrice = calculatePrice(selectedUnitType, selectedWeeks); // 초기 가격 설정
  }

  // 가격을 계산하는 함수
  int calculatePrice(String unitType, int weeks) {
    int price = 0;

    // 유닛 유형에 따른 가격 설정
    if (unitType == '큐브') {
      price = 70000;
    } else if (unitType == '미니') {
      price = 80000;
    } else if (unitType == '스탠다드') {
      price = 90000;
    } else if (unitType == '엑스트라') {
      price = 100000;
    }

    // 주 단위에 따른 가격 설정 (4주 기준으로 계산)
    price = (price / 4 * weeks).round();

    return price;
  }

  // 날짜 선택을 위한 함수
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  // 유닛 유형 선택 버튼
  Widget _unitTypeButton(String label) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: ElevatedButton(
          onPressed: () {
            setState(() {
              selectedUnitType = label;
              unitPrice =
                  calculatePrice(selectedUnitType, selectedWeeks); // 가격 재계산
            });
          },
          style: ElevatedButton.styleFrom(
            minimumSize: Size(130, 50),
            backgroundColor: selectedUnitType == label
                ? Color(0xFFAFD485)
                : Colors.grey[300],
            foregroundColor:
                selectedUnitType == label ? Colors.white : Colors.black,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(fontSize: 14, height: 1.2),
          ),
        ),
      ),
    );
  }

  // 이용 기간을 조정하는 위젯
  Widget _weekAdjustment() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: Icon(Icons.remove),
          onPressed: () {
            setState(() {
              if (selectedWeeks > 1) selectedWeeks--;
              unitPrice =
                  calculatePrice(selectedUnitType, selectedWeeks); // 가격 재계산
            });
          },
        ),
        Text('$selectedWeeks 주',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        IconButton(
          icon: Icon(Icons.add),
          onPressed: () {
            setState(() {
              selectedWeeks++;
              unitPrice =
                  calculatePrice(selectedUnitType, selectedWeeks); // 가격 재계산
            });
          },
        ),
      ],
    );
  }

  // 결제 확인 팝업
  void _showPaymentConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('결제 재확인'),
          content: Text(
            '지점: ${widget.warehouseName}\n'
            '유닛 유형: $selectedUnitType\n'
            '이용 기간: $selectedWeeks 주\n'
            '결제 금액: ${unitPrice.toString()}원',
          ),
          actions: [
            TextButton(
              child: Text('결제하기'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => QRPage()),
                );
              },
            ),
            TextButton(
              child: Text('취소'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('결제 페이지'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.warehouseName}',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  Text(
                    '이용 시작일',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    decoration: InputDecoration(
                      hintText: selectedDate == null
                          ? '이용 시작일을 선택해주세요.'
                          : DateFormat('yyyy-MM-dd').format(selectedDate!),
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                    onTap: () {
                      _selectDate(context);
                    },
                  ),
                  SizedBox(height: 20),
                  Text(
                    '유닛 유형',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _unitTypeButton('큐브'),
                      _unitTypeButton('미니'),
                      _unitTypeButton('스탠다드'),
                      _unitTypeButton('엑스트라'),
                    ],
                  ),
                  SizedBox(height: 20),
                  Text(
                    '이용 기간 (주 단위)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  _weekAdjustment(),
                  SizedBox(height: 20),
                  Text(
                    '유닛 사이즈',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '7형 0.9 x 0.9 x 0.9',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: '85,490원 ',
                                style: TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.grey,
                                ),
                              ),
                              TextSpan(
                                text: ' 18% ',
                                style: TextStyle(color: Colors.red),
                              ),
                              TextSpan(
                                text: '${unitPrice.toString()}원',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '쉐어웨어 페밀리 최대 4인 이용시 약 ${(unitPrice / 4).round()}원부터 이용 가능.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 15),
            color: Colors.grey[200],
            child: Column(
              children: [
                Text(
                  '$selectedUnitType 7형',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5),
                Text(
                  '결제 금액: ${unitPrice.toString()}원',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _showPaymentConfirmation,
                  child: Text('결제하기'),
                  style: ElevatedButton.styleFrom(
                    padding:
                        EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                    minimumSize: Size(double.infinity, 50), // 버튼의 최소 크기를 설정
                    backgroundColor: Color(0xFFAFD485),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
