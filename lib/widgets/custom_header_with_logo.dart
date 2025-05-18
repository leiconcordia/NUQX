import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_application_1/screens/notification_screen.dart';
import 'package:flutter_application_1/utils/custom_page_route.dart';

class CustomHeaderWithLogo extends StatelessWidget {
  final String userName;
  const CustomHeaderWithLogo({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 14.w),
          decoration: BoxDecoration(
            color: const Color(0xFF2D3A8C), // Blue background
            border: Border(
              bottom: BorderSide(
                color: const Color(0xFFFFC107),
                width: 2.h,
              ), // Yellow underline
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Logo and Title (aligned to the left)
              Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    Image.asset('assets/images/logo.png', height: 40.h),
                    SizedBox(width: 12.w),
                    Text(
                      "NUQX",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 21.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Notification button (aligned to the right)
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: const Icon(Icons.notifications, color: Colors.white),
                  onPressed: () {
                    // Navigate to NotificationScreen when button is pressed
                    Navigator.pushAndRemoveUntil(
                      context,
                      noAnimationRoute(
                        NotificationsScreen(userName: userName),
                      ), // Assuming NotificationScreen is the target
                      (route) => false, // Removes all previous routes
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
