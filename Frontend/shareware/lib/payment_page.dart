import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'pay_completed_page.dart';

class PaymentPage extends StatefulWidget {
  final String warehouseName;
  final String unitType;
  final String unitSize;
  final DateTime startDate;
  final int unitPrice;

  PaymentPage({
    required this.warehouseName,
    required this.unitType,
    required this.unitSize,
    required this.startDate,
    required this.unitPrice,
  });

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String _selectedPaymentMethod = 'card';
  bool _isAccidentPolicyChecked = false;
  bool _isTermsChecked = false;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.isLoggedIn) {
      authProvider.getProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final profile = authProvider.profile;
    final discountedPrice = (widget.unitPrice * (82 / 100)).round();
    final discountAmount = (widget.unitPrice * (18 / 100)).round();

    return Scaffold(
      appBar: AppBar(
        title: Text('결제 페이지'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 계약자 정보
            Text('계약자',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('${profile['user_name'] ?? ''}'),
            Text('(${profile['user_phone'] ?? ''})'),
            Divider(height: 32),

            // 계약 정보
            Text('계약 정보',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            _buildInfoRow('지점', '${widget.warehouseName}'),
            _buildInfoRow('유닛 유형', '${widget.unitType} (${widget.unitSize})',
                isLink: true),
            _buildInfoRow('유닛 번호', '아직 백엔드랑 연결 안했다'),
            _buildInfoRow('이용시작일',
                DateFormat('yyyy.MM.dd (E)', 'ko_KR').format(widget.startDate)),
            Divider(height: 32),

            // 결제 정보
            Text('결제 정보',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            _buildPriceRow('보증금', '어떻게할지 생각해보자'),
            _buildPriceRow(
                '이용요금', '${NumberFormat('#,###').format(discountedPrice)}원',
                discount: '-${NumberFormat('#,###').format(discountAmount)}원'),
            _buildPriceRow('총 결제금액', '1억 원', isTotal: true),
            Divider(height: 32),

            // 결제 수단
            Text('결제 수단',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            RadioListTile(
              value: 'card',
              groupValue: _selectedPaymentMethod,
              title: Row(
                children: [
                  Icon(Icons.payment),
                  SizedBox(width: 8),
                  Text('카드 결제'),
                ],
              ),
              onChanged: (value) {
                setState(() {
                  _selectedPaymentMethod = value!;
                });
              },
            ),
            RadioListTile(
              value: 'cash',
              groupValue: _selectedPaymentMethod,
              title: Row(
                children: [
                  Text('무통장 입금'),
                ],
              ),
              onChanged: (value) {
                setState(() {
                  _selectedPaymentMethod = value!;
                });
              },
            ),
            Divider(height: 32),

            // 유의사항
            Text('유의사항',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            CheckboxListTile(
              value: _isAccidentPolicyChecked,
              onChanged: (value) {
                setState(() {
                  _isAccidentPolicyChecked = value!;
                });
              },
              title: Text('(필수) 사고 발생 시 보상 확인'),
              subtitle: Text('보관된 물품의 전체 한도 보상금의 10배를 넘지 않음...'),
            ),
            CheckboxListTile(
              value: _isTermsChecked,
              onChanged: (value) {
                setState(() {
                  _isTermsChecked = value!;
                });
              },
              title: Text('(필수) 계약 및 결제 유의사항 확인'),
            ),
            Divider(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: Container(
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
        child: ElevatedButton(
          onPressed: _isAccidentPolicyChecked && _isTermsChecked
              ? () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => PayCompletedPage()),
                    (route) => false, // 모든 이전 페이지 제거
                  );
                  print('결제 완료');
                }
              : null,
          child: Text(
            '250,780 원 결제하기',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            backgroundColor: (_isAccidentPolicyChecked && _isTermsChecked)
                ? Color(0xFFAFD485)
                : Colors.grey,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String value, {bool isLink = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          isLink
              ? Text(value, style: TextStyle(color: Colors.blue))
              : Text(value),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String title, String price,
      {String? discount, bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: TextStyle(
                      fontWeight:
                          isTotal ? FontWeight.bold : FontWeight.normal)),
              Text(price,
                  style: TextStyle(
                      fontWeight:
                          isTotal ? FontWeight.bold : FontWeight.normal)),
            ],
          ),
          if (discount != null)
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Text(discount, style: TextStyle(color: Colors.red)),
            ),
        ],
      ),
    );
  }
}
