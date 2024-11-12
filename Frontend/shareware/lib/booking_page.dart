import 'package:flutter/cupertino.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_33/qr_page.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';

class BookingPage extends StatefulWidget {
  final String warehouseName;

  BookingPage({required this.warehouseName});

  @override
  _BookingPageState createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  DateTime? selectedStartDate; // 시작일
  DateTime? selectedEndDate; // 종료일
  String selectedUnitType = '큐브'; // 선택된 유닛 유형 기본값
  String roundedSize = '9';
  int selectedWeeks = 1; // 선택된 이용 기간 (주 단위)
  int unitPrice = 0; // 기본 가격
  String selectedPeriodType = '주'; // 초기 값: 주
  bool isSelectingDuration = true; // 기간 선택 또는 종료일 선택 상태 관리

  final List<int> weekOptions =
      List<int>.generate(12, (index) => index + 1); // 1~12주 또는 1~12달
  final List<String> periodTypes = ['주', '개월'];

  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    unitPrice = calculatePrice(selectedUnitType, selectedWeeks); // 초기 가격 설정
  }

  // 가격을 계산하는 함수
  int calculatePrice(String unitType, int duration) {
    int pricePerFourWeeks = 0;

    // 유닛 유형에 따른 4주 기준 가격 설정
    if (unitType == '큐브') {
      pricePerFourWeeks = 70000;
    } else if (unitType == '미니') {
      pricePerFourWeeks = 80000;
    } else if (unitType == '스탠다드') {
      pricePerFourWeeks = 90000;
    } else if (unitType == '엑스트라') {
      pricePerFourWeeks = 100000;
    }

    // 선택된 기간 유형에 따른 가격 계산
    int totalPrice;
    if (selectedPeriodType == '주') {
      // 주 단위: 4주 기준 가격을 주 단위로 환산
      totalPrice = (pricePerFourWeeks / 4 * duration).round();
    } else if (selectedPeriodType == '개월') {
      // 개월 단위: 각 개월을 4주 단위로 계산
      totalPrice = pricePerFourWeeks * duration;
    } else {
      totalPrice = 0; // 잘못된 값이 들어올 경우 안전하게 0을 반환
    }

    return totalPrice;
  }

  // 유닛 유형 선택 버튼
  Widget _unitTypeButton(String label) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton(
          onPressed: () {
            setState(() {
              selectedUnitType = label;
              unitPrice =
                  calculatePrice(selectedUnitType, selectedWeeks); // 가격 재계산
              roundedSize = getUnitSize(selectedUnitType).split(' ')[0];
            });
          },
          style: ElevatedButton.styleFrom(
            minimumSize: Size(130, 50),
            backgroundColor: selectedUnitType == label
                ? Colors.transparent
                : Colors.grey[300],
            foregroundColor:
                selectedUnitType == label ? Colors.black : Colors.black,
            side: selectedUnitType == label
                ? BorderSide(color: Color(0xFFAFD485), width: 4)
                : BorderSide.none,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: 16),
          ),
          child: Text(
            label,
            style: TextStyle(
                fontSize: 14,
                height: 1.2,
                fontWeight: selectedUnitType == label
                    ? FontWeight.bold
                    : FontWeight.normal),
            softWrap: false, // 줄바꿈 없이
            overflow: TextOverflow.visible, // 텍스트가 잘리지 않도록
          ),
        ),
      ),
    );
  }

  // 기간 선택과 종료일 선택 버튼을 포함한 위젯
  Widget _durationSelectionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 기간 선택 버튼
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  isSelectingDuration = true;
                });
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(130, 40),
                backgroundColor:
                    isSelectingDuration ? Colors.transparent : Colors.grey[300],
                foregroundColor: Colors.black,
                side: isSelectingDuration
                    ? BorderSide(color: Color(0xFFAFD485), width: 4)
                    : BorderSide.none,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(horizontal: 16),
              ),
              child: Text(
                '기간 선택',
                style: TextStyle(
                    fontSize: 14,
                    height: 1.2,
                    fontWeight: isSelectingDuration
                        ? FontWeight.bold
                        : FontWeight.normal),
                softWrap: false,
                overflow: TextOverflow.visible,
              ),
            ),
          ),
        ),
        // 종료일 선택 버튼
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  isSelectingDuration = false;
                });
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(130, 40),
                backgroundColor: !isSelectingDuration
                    ? Colors.transparent
                    : Colors.grey[300],
                foregroundColor: Colors.black,
                side: !isSelectingDuration
                    ? BorderSide(color: Color(0xFFAFD485), width: 4)
                    : BorderSide.none,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(horizontal: 16),
              ),
              child: Text(
                '종료일 선택',
                style: TextStyle(
                    fontSize: 14,
                    height: 1.2,
                    fontWeight: !isSelectingDuration
                        ? FontWeight.bold
                        : FontWeight.normal),
                softWrap: false,
                overflow: TextOverflow.visible,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _weekAdjustment() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 80,
          height: 80,
          child: CupertinoPicker(
            itemExtent: 32.0,
            scrollController:
                FixedExtentScrollController(initialItem: selectedWeeks - 1),
            onSelectedItemChanged: (index) {
              setState(() {
                selectedWeeks = weekOptions[index];
                unitPrice = calculatePrice(selectedUnitType, selectedWeeks);
              });
            },
            children: weekOptions
                .map((week) => Center(
                      child: Text(
                        '$week',
                        style: TextStyle(fontSize: 16),
                      ),
                    ))
                .toList(),
          ),
        ),
        SizedBox(width: 5),
        SizedBox(
          width: 80,
          height: 80,
          child: CupertinoPicker(
            itemExtent: 32.0,
            scrollController: FixedExtentScrollController(
                initialItem: periodTypes.indexOf(selectedPeriodType)),
            onSelectedItemChanged: (index) {
              setState(() {
                selectedPeriodType = periodTypes[index];
                unitPrice = calculatePrice(selectedUnitType, selectedWeeks);
              });
            },
            children: periodTypes
                .map((type) => Center(
                      child: Text(
                        type,
                        style: TextStyle(fontSize: 16),
                      ),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }

  // 시작일 선택 함수
  void _selectStartDate(BuildContext context) {
    final today = DateTime.now();
    final maxSelectableDate = today.add(Duration(days: 6));
    DateTime? tempSelectedStartDate = selectedStartDate;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('시작일 선택'),
        content: Container(
          width: 300,
          child: StatefulBuilder(
            builder: (context, setDialogState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TableCalendar(
                    calendarFormat: CalendarFormat.month,
                    availableCalendarFormats: const {
                      CalendarFormat.month: 'Month', // 상단에 표시할 포맷 이름 변경 가능
                    },
                    headerStyle: HeaderStyle(
                      titleCentered: true, // 타이틀 가운데 정렬
                      // formatButtonVisible: false, // 포맷 버튼 숨김
                      leftChevronVisible:
                          today.month != maxSelectableDate.month,
                      rightChevronVisible: maxSelectableDate.month !=
                          today.month, // 다음달로 넘기는 화살표 lasdDay가 다음달인 경우만 표시
                      titleTextStyle:
                          TextStyle(fontSize: 20, color: Colors.black),
                    ),
                    firstDay: DateTime.now(),
                    lastDay: maxSelectableDate,
                    focusedDay: DateTime.now(),
                    selectedDayPredicate: (day) =>
                        isSameDay(tempSelectedStartDate, day),
                    onDaySelected: (selectedDay, focusedDay) {
                      setDialogState(() {
                        tempSelectedStartDate = selectedDay;
                      });
                    },
                    calendarStyle: CalendarStyle(
                      todayDecoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.transparent,
                        border: Border.all(
                          color: Colors.blue,
                          width: 2.0,
                        ),
                      ),
                      todayTextStyle: TextStyle(
                        color: Colors.blue, // 텍스트 색상을 파란색으로 설정
                        fontWeight: FontWeight.bold, // 텍스트 굵게
                      ),
                      selectedDecoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('취소'),
                      ),
                      TextButton(
                        onPressed: () {
                          if (tempSelectedStartDate != null) {
                            setState(() {
                              selectedStartDate = tempSelectedStartDate;
                              selectedEndDate = null; // 시작일 선택 시 종료일 초기화
                              _startDateController.text =
                                  DateFormat('yyyy-MM-dd')
                                      .format(tempSelectedStartDate!);
                            });
                          }
                          Navigator.pop(context); // 다이얼로그 닫기
                        },
                        child: Text('확인'),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // 종료일 선택 함수
  void _selectEndDate(BuildContext context) {
    if (selectedStartDate == null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('알림'),
            content: Text('이용 시작일을 먼저 선택해주세요.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // 알림 창 닫기
                },
                child: Text('확인'),
              ),
            ],
          );
        },
      );
      return;
    }

    final maxEndDate =
        selectedStartDate!.add(Duration(days: 366)); // 종료일을 시작일로부터 최대 1년으로 제한
    DateTime? tempSelectedEndDate =
        selectedStartDate!.add(Duration(days: 6)); // 기본 종료일 설정
    DateTime focusedDay = selectedStartDate!; // 초기 focusedDay 설정

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('종료일 선택'),
        content: Container(
          width: 300,
          child: StatefulBuilder(
            builder: (context, setDialogState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TableCalendar(
                    calendarFormat: CalendarFormat.month,
                    availableCalendarFormats: const {
                      CalendarFormat.month: 'Month',
                    },
                    headerStyle: HeaderStyle(
                      titleCentered: true,
                      // leftChevronVisible: false,
                      rightChevronVisible: focusedDay.isBefore(
                          DateTime(maxEndDate.year, maxEndDate.month, 1)),
                      titleTextStyle: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                      ),
                    ),
                    firstDay: selectedStartDate!,
                    lastDay: maxEndDate,
                    focusedDay: focusedDay,
                    rangeSelectionMode: RangeSelectionMode.enforced,
                    rangeStartDay: selectedStartDate,
                    rangeEndDay: tempSelectedEndDate,
                    selectedDayPredicate: (day) =>
                        isSameDay(tempSelectedEndDate, day),
                    onDaySelected: (selectedDay, newFocusedDay) {
                      // 일주일 단위로만 날짜 선택 가능하도록 제한
                      final difference =
                          selectedDay.difference(selectedStartDate!).inDays;
                      if (difference % 7 == 6) {
                        setDialogState(() {
                          tempSelectedEndDate = selectedDay;
                          focusedDay = newFocusedDay;
                          // 이용 기간과 가격 업데이트
                          selectedWeeks =
                              (difference ~/ 7) + 1; // 이용 기간을 주 단위로 계산
                          unitPrice =
                              calculatePrice(selectedUnitType, selectedWeeks);
                        });
                      } else {
                        // 유효하지 않은 날짜 선택 시 알림 표시
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('종료일은 이용 시작일로부터 7일 단위로만 선택 가능합니다.'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    calendarStyle: CalendarStyle(
                      todayDecoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.transparent,
                        border: Border.all(
                          color: Colors.blue,
                          width: 2.0,
                        ),
                      ),
                      todayTextStyle: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                      selectedDecoration: BoxDecoration(
                        color: Color(0xFFAFD485),
                        shape: BoxShape.circle,
                      ),
                    ),
                    calendarBuilders: CalendarBuilders(
                      defaultBuilder: (context, day, focusedDay) {
                        final difference =
                            day.difference(selectedStartDate!).inDays;
                        final isSelectableEndDate =
                            difference % 7 == 6; // 7일 단위로 선택 가능한 날짜

                        return Center(
                          child: isSelectableEndDate
                              ? Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.transparent,
                                    border: Border.all(
                                      color: Color(0xFFAFD485),
                                      width: 2.0,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    '${day.day}',
                                    style: TextStyle(
                                      color: Color(0xFFAFD485),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              : Text(
                                  '${day.day}',
                                  style: TextStyle(
                                    color: Colors.grey[400], // 선택 불가한 날짜는 회색
                                  ),
                                ),
                        );
                      },
                      rangeStartBuilder: (context, day, focusedDay) {
                        return Center(
                          child: Container(
                            width: 35,
                            height: 35,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${day.day}',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('취소'),
                      ),
                      TextButton(
                        onPressed: () {
                          if (tempSelectedEndDate != null) {
                            setState(() {
                              selectedEndDate = tempSelectedEndDate;
                              _endDateController.text = DateFormat('yyyy-MM-dd')
                                  .format(tempSelectedEndDate!);
                            });
                          }
                          Navigator.pop(context);
                        },
                        child: Text('확인'),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // 결제 확인 팝업 (로그인 확인 기능 제거)
  void _showPaymentConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // 둥근 모서리
          ),
          title: Text(
            '결제 재확인',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D2D2D), // 제목 색상
            ),
          ),
          content: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '지점: ${widget.warehouseName}',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 8),
                Text(
                  '유닛 유형: $selectedUnitType',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 8),
                Text(
                  '이용 시작일: ${selectedStartDate == null ? '선택 안됨' : DateFormat('yyyy-MM-dd').format(selectedStartDate!)}',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 8),
                Text(
                  '이용 기간: $selectedWeeks 주',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 8),
                Text(
                  '결제 금액: ${unitPrice.toString()}원',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D2D2D),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text(
                '취소',
                style: TextStyle(color: Colors.grey),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // 팝업 닫기
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFAFD485), // 버튼 색상
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: Text(
                '결제하기',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => QRPage()),
                );
              },
            ),
          ],
        );
      },
    );
  }

  // 유닛 유형에 따른 사이즈 정보를 반환하는 함수
  String getUnitSize(String unitType) {
    String calculateSize(double width, double depth, double height) {
      int roundedSize = (width * depth * height * 10).round();
      return '${roundedSize}형   $width x $depth x $height';
    }

    switch (unitType) {
      case '큐브':
        return calculateSize(0.9, 0.9, 0.9);
      case '미니':
        return calculateSize(0.9, 0.9, 1.9);
      case '스탠다드':
        return calculateSize(2.1, 1.1, 1.9);
      case '엑스트라':
        return calculateSize(2.9, 1.0, 1.9);
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('예약 페이지'),
      ),
      body: SingleChildScrollView(
        child: Padding(
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
                  hintText: '이용 시작일을 선택해주세요.',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                  hintStyle: TextStyle(
                    color:
                        selectedStartDate == null ? Colors.grey : Colors.black,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
                readOnly: true,
                controller: _startDateController,
                onTap: () {
                  _selectStartDate(context);
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
                '이용 기간',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              _durationSelectionButtons(),
              SizedBox(height: 10),
              Container(
                height: 70,
                child: isSelectingDuration
                    ? _weekAdjustment()
                    : TextField(
                        decoration: InputDecoration(
                          hintText: '종료일을 선택해주세요.',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                          hintStyle: TextStyle(
                            color: selectedEndDate == null
                                ? Colors.grey
                                : Colors.black,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                        ),
                        readOnly: true,
                        controller: _endDateController,
                        onTap: () {
                          _selectEndDate(context);
                        },
                      ),
              ),
              SizedBox(height: 10),
              Text(
                selectedStartDate != null
                    ? isSelectingDuration
                        // 기간 선택일 때: 주 단위와 개월 단위에 따라 종료일 계산
                        ? selectedPeriodType == '주'
                            // 주 단위일 때, 주 수에 따라 종료일 계산
                            ? '${DateFormat('yyyy-MM-dd').format(selectedStartDate!)} ~ ${DateFormat('yyyy-MM-dd').format(selectedStartDate!.add(Duration(days: selectedWeeks * 7 - 1)))} ($selectedWeeks주)'
                            // 개월 단위일 때, 개월 수에 따라 종료일 계산
                            : '${DateFormat('yyyy-MM-dd').format(selectedStartDate!)} ~ ${DateFormat('yyyy-MM-dd').format(DateTime(selectedStartDate!.year, selectedStartDate!.month + selectedWeeks, selectedStartDate!.day).subtract(Duration(days: 1)))} ($selectedWeeks개월)'
                        // 종료일 선택일 때, 선택한 종료일 표시
                        : '${DateFormat('yyyy-MM-dd').format(selectedStartDate!)} ~ ${selectedEndDate != null ? DateFormat('yyyy-MM-dd').format(selectedEndDate!) : ''}'
                    : '', // 시작일이 선택되지 않았을 때는 빈 문자열
                style: TextStyle(fontSize: 16, color: Colors.blue),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Text(
                    '유닛 사이즈',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Spacer(),
                  Text(
                    '(너비 x 깊이 x 높이 / 단위 m)',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      getUnitSize(selectedUnitType),
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text:
                                  '${NumberFormat('#,###').format(unitPrice)}원',
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
                              text:
                                  '${NumberFormat('#,###').format((unitPrice * (82 / 100)).round())}원',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomSheet: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Colors.grey[100]!, width: 1), // 상단 경계선
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, -2), // 위쪽으로 그림자 효과
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  selectedStartDate != null
                      ? isSelectingDuration
                          // 기간 선택일 때: 주 단위와 개월 단위에 따라 종료일 계산
                          ? selectedPeriodType == '주'
                              // 주 단위일 때, 주 수에 따라 종료일 계산
                              ? '${DateFormat('yy-MM-dd').format(selectedStartDate!)} ~ ${DateFormat('yy-MM-dd').format(selectedStartDate!.add(Duration(days: selectedWeeks * 7 - 1)))}'
                              // 개월 단위일 때, 개월 수에 따라 종료일 계산
                              : '${DateFormat('yy-MM-dd').format(selectedStartDate!)} ~ ${DateFormat('yy-MM-dd').format(DateTime(selectedStartDate!.year, selectedStartDate!.month + selectedWeeks, selectedStartDate!.day).subtract(Duration(days: 1)))}'
                          // 종료일 선택일 때, 선택한 종료일 표시
                          : '${DateFormat('yy-MM-dd').format(selectedStartDate!)} ~ ${selectedEndDate != null ? DateFormat('yy-MM-dd').format(selectedEndDate!) : ''}'
                      : '', // 시작일이 선택되지 않았을 때는 빈 문자열
                  style: TextStyle(fontSize: 16, color: Colors.blue),
                ),
                SizedBox(height: 5),
                Text(
                  '${selectedUnitType} ${roundedSize}형 / ${NumberFormat('#,###').format((unitPrice * (82 / 100)).round())}원',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ],
            ),
            Spacer(),
            ElevatedButton(
              onPressed: _showPaymentConfirmation,
              child: Text(
                '예약하기',
                style: TextStyle(
                  fontWeight: FontWeight.bold, // 텍스트를 굵게 설정
                  fontSize: 20,
                ),
              ),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                backgroundColor: Color(0xFFAFD485),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
