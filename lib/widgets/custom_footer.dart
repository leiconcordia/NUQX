import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Solid footer bar (NU Blue with NU Gold top border) that also paints
/// the system gesture area to avoid any white gap.
class CustomFooter extends StatelessWidget {
  final double? height; // visible bar height (excluding system inset)

  const CustomFooter({super.key, this.height});

  @override
  Widget build(BuildContext context) {
    // Use SafeArea to apply ONLY the bottom inset to this footer.
    return Material(
      color: const Color(0xFF2D3A8C), // NU Blue
      child: SafeArea(
        top: false,
        left: false,
        right: false,
        bottom: true,
        child: Container(
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(
                color: Color(0xFFFFD700), // NU Gold
                width: 2,
              ),
            ),
          ),
          width: double.infinity,
          height: (height ?? 63.7.h),
        ),
      ),
    );
  }
}
