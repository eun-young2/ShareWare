import 'package:flutter/material.dart';
import 'package:flutter_application_33/qr_page.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'main.dart';

class PayCompletedPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => MainPage()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Spacer(),

              Text(
                '결제완료',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: 30),

              Text(
                '출입을 위한\n1회용 QR 발급하러 가기',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 20),

              // QR 코드 이미지 (플레이스홀더 이미지)
              Container(
                height: 180,
                width: 180,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'assets/qr_img.png',
                      fit: BoxFit.cover,
                      width: 150,
                      height: 150,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30),

              Spacer(),

              // "입장 QR코드 발급" 버튼
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      // // MainPage의 selectedIndex를 2로 설정하여 QRPage로 이동
                      // Navigator.of(context).popUntil((route) => route.isFirst);
                      // final mainPageState =
                      //     context.findAncestorStateOfType<MainPageState>();
                      // Future.delayed(Duration(milliseconds: 100), () {
                      //   mainPageState?.onItemTapped(2); // QRPage 인덱스
                      // });

                      // MainPage로 돌아가 QRPage로 이동
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MainPage(selectedIndex: 2)),
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFAFD485),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 15.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: Text(
                      '입장 QR코드 발급',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
