import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/custom_footer.dart';
import '../widgets/custom_header.dart';
import '../utils/custom_page_route.dart';
import 'home_screen.dart'; // Ensure this import path is correct

class VerifiedPage extends StatelessWidget {
  final String userName; // ✅ Fixed userName as a class property

  const VerifiedPage({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const CustomHeader(title: "Verified"), // ✅ Custom Header Used
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 40.r,
                    backgroundColor: const Color(0xFF2D3A8C),
                    child: Icon(Icons.check, size: 50.r, color: Colors.white),
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    "Successfully",
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2D3A8C),
                    ),
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    "Your Account Has\nBeen Verified",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14.sp, color: Colors.black),
                  ),
                  SizedBox(height: 30.h),
                  SizedBox(
                    width: 200.w,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2D3A8C),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25.r),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          noAnimationRoute(HomeScreen(userName: userName)),
                          (route) => false,
                        );
                      },
                      child: Text(
                        "Continue",
                        style: TextStyle(fontSize: 16.sp, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const CustomFooter(), // ✅ Custom Footer Used
          ],
        ),
      ),
    );
  }
}
