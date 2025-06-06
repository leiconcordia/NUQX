import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomHeader extends StatelessWidget {
  final String title;
  final bool showBackButton;

  const CustomHeader({super.key, required this.title, this.showBackButton = false,});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 28.h, horizontal: 14.w),
      decoration: const BoxDecoration(
        color: Color(0xFF2D3A8C), // Blue background
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFFFC107), // Yellow underline
            width: 2, // Avoid using `.h` for border width
          ),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (showBackButton)
            Positioned(
              left: 0,
              child: IconButton(
                icon: Icon(Icons.arrow_back,
                  color: Colors.white,
                  size: 24.sp,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
