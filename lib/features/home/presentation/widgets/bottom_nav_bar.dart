import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class HomeBottomNavBar extends StatelessWidget {
  const HomeBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      backgroundColor: Colors.white,
      indicatorColor: Colors.transparent, 
      overlayColor: MaterialStateProperty.all(
        Colors.transparent,
      ), 
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      destinations: [
        NavigationDestination(
          icon: SizedBox(
            width: 35,
            child: Image.asset('assets/images/home/home.png'),
          ),
          selectedIcon: SizedBox(
            width: 35,
            child: Image.asset(
              'assets/images/home/home.png',
              color: Colors.red,
            ),
          ),
          label: 'Home',
        ),
        NavigationDestination(
          icon: SizedBox(
            width: 35,
            child: Image.asset('assets/images/home/booking.png'),
          ),
          selectedIcon: SizedBox(
            width: 35,
            child: Image.asset(
              'assets/images/home/booking.png',
              color: Colors.red,
            ),
          ),
          label: 'My Bookings',
        ),
        NavigationDestination(
          icon: SizedBox(
            width: 35,
            child: Image.asset('assets/images/home/qr.png'),
          ),
          selectedIcon: SizedBox(
            width: 35,
            child: Image.asset('assets/images/home/qr.png', color: Colors.red),
          ),
          label: 'QR Pass',
        ),
        NavigationDestination(
          icon: SizedBox(
            width: 35,
            child: Image.asset('assets/images/home/support.png'),
          ),
          selectedIcon: SizedBox(
            width: 35,
            child: Image.asset(
              'assets/images/home/support.png',
              color: Colors.red,
            ),
          ),
          label: 'Support',
        ),
      ],
    );
  }
}
