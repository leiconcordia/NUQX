import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomHeaderWithTitle extends StatelessWidget {
  final String title;

  const CustomHeaderWithTitle({super.key, required this.title});

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
              // Title (centered)
              Center(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // Notification button (aligned to the right)
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: const Icon(Icons.notifications, color: Colors.white),
                  onPressed: () {
                    // Handle notification button press
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
