import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomFooter extends StatelessWidget {
  const CustomFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            height: 2.h,
            color: const Color(0xFFFFC107), // Yellow bar
          ),
          Container(
            width: double.infinity,
            height: 78.h,
            color: const Color(0xFF2D3A8C), // Blue bar
          ),
        ],
      ),
    );
  }
}
