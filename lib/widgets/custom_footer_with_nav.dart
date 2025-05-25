import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_application_1/screens/home_screen.dart';
import 'package:flutter_application_1/screens/menu_screen.dart';
import 'package:flutter_application_1/screens/tracker_screen.dart';

class CustomFooterWithNav extends StatelessWidget {
  final String userName;



  final String activeTab;

  const CustomFooterWithNav({
    super.key,
    required this.userName,
    required this.activeTab,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 80.h,
      decoration: BoxDecoration(
        color: const Color(0xFF2D3A8C),
        border: const Border(
          top: BorderSide(
            color: Color(0xFFFFD700), // NU Gold
            width: 2,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavButton(
            context,
            icon: Icons.assignment,
            label: "Form",
            isActive: activeTab == 'home',
            onTap:
                () =>
                    _navigateToScreen(context, HomeScreen(userName: userName)),
          ),
          _buildNavButton(
            context,
            icon: Icons.play_arrow,
            label: "Tracker",
            isActive: activeTab == 'tracker',
            onTap:
                () => _navigateToScreen(
                  context,
                  TrackerScreen(userName: userName, ),
                ),
          ),
          _buildNavButton(
            context,
            icon: Icons.menu,
            label: "Menu",
            isActive: activeTab == 'menu',
            onTap:
                () =>
                    _navigateToScreen(context, MenuScreen(userName: userName)),
          ),
        ],
      ),
    );
  }

  void _navigateToScreen(BuildContext context, Widget screen) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => screen,
        transitionDuration: Duration(milliseconds: 200),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  Widget _buildNavButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
        decoration: BoxDecoration(
          color:
              isActive
                  ? const Color(0xFFFFD700).withOpacity(0.15)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? const Color(0xFFFFD700) : Colors.white,
              size: 24.sp,
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                color: isActive ? const Color(0xFFFFD700) : Colors.white,
                fontSize: 12.sp,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: EdgeInsets.only(top: 3.h),
              height: 2.h,
              width: isActive ? 20.w : 0,
              decoration: BoxDecoration(
                color: const Color(0xFFFFD700),
                borderRadius: BorderRadius.circular(1.r),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
