// bottom_nav_bar.dart
import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  BottomNavBar({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed, // 모든 라벨 항상 표시
      backgroundColor: Colors.white,
      selectedItemColor: Color(0xFFAFD485),
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: '홈',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.map),
          label: '창고찾기',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.qr_code),
          label: 'QR입장',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.store),
          label: '마이창고',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: '마이페이지',
        ),
      ],
      currentIndex: currentIndex,
      onTap: onTap,
    );
  }
}
