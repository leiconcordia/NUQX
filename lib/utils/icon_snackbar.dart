import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum SnackBarType { success, error, alert }

class IconSnackBar {
  static void show({
    required BuildContext context,
    required SnackBarType snackBarType,
    required String label,
  }) {
    final backgroundColor = _getBackgroundColor(snackBarType);
    final icon = _getIcon(snackBarType);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: backgroundColor,
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height - 107, // Position near top
          left: 20.w,
          right: 20.w,
        ),
        elevation: 6.0,
      ),
    );
  }

  static Color _getBackgroundColor(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return const Color(0xFF28A745);
      case SnackBarType.error:
        return const Color(0xFFDC3545);
      case SnackBarType.alert:
        return const Color(0xFFFFC107);
    }
  }

  static IconData _getIcon(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return Icons.check_circle;
      case SnackBarType.error:
        return Icons.error;
      case SnackBarType.alert:
        return Icons.warning;
    }
  }
}