import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../utils/custom_page_route.dart';
import '../widgets/custom_footer_with_nav.dart';
import '../widgets/custom_header_with_title.dart';
import 'home_screen.dart';
import 'paymentform_screen.dart';

class AccountingScreen extends StatelessWidget {
  final String userName;
  const AccountingScreen({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Stack(
              children: [
                const CustomHeaderWithTitle(title: "Accounting"),
                Positioned(
                  left: 14.w,
                  top: 17.h,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        noAnimationRoute(HomeScreen(userName: userName)),
                        (route) => false,
                      );
                    },
                  ),
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 30.h),
                      Text(
                        "Hello, $userName!",
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2D3A8C),
                        ),
                      ),
                      SizedBox(height: 5.h),
                      Text(
                        "What will you do today?",
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.black54,
                        ),
                      ),
                      SizedBox(height: 40.h),
                      _buildAccountingCard(context),
                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ),
            ),
            CustomFooterWithNav(userName: userName, activeTab: 'home'),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountingCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacement(
          context,
          noAnimationRoute(PaymentFormScreen(userName: userName)),
        );
      },
      child: Container(
        width: 120.w,
        height: 120.h,
        decoration: BoxDecoration(
          color: const Color(0xFF2D3A8C),
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 5,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.credit_card, size: 40.sp, color: Colors.white),
            SizedBox(height: 8.h),
            Text(
              "Payment",
              style: TextStyle(color: Colors.white, fontSize: 14.sp),
            ),
          ],
        ),
      ),
    );
  }
}
