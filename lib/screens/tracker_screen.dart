import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/home_screen.dart';
import 'package:flutter_application_1/utils/custom_page_route.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/custom_footer_with_nav.dart';
import '../widgets/custom_header_with_title.dart';

class TrackerScreen extends StatelessWidget {
  static const String routeName = "/tracker";
  final String userName;


  const TrackerScreen({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Stack(
              children: [
                const CustomHeaderWithTitle(title: "Queue Tracker"),
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
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildProgressIndicator(),
                    SizedBox(height: 20.h),
                    _buildQueueInfoBox(),
                  ],
                ),
              ),
            ),
            CustomFooterWithNav(
              userName: userName,
              activeTab: 'tracker',),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: CircleAvatar(
            radius: 10.r,
            backgroundColor: index == 0 ? Colors.grey : Colors.grey.shade300,
          ),
        );
      }),
    );
  }

  Widget _buildQueueInfoBox() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Now Serving",
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 5.h),
          Text(
            "Queue No. ENR001",
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20.h),
          Text(
            "Your Queue Number",
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 5.h),
          Text(
            "ENR0001",
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3A8C),
            ),
          ),
          SizedBox(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildQueueInfo("29", "People In Waiting"),
              SizedBox(width: 40.w),
              _buildQueueInfo("35 MIN", "Approx. Wait Time"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQueueInfo(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3A8C),
          ),
        ),
        SizedBox(height: 5.h),
        Text(
          label,
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w400),
        ),
      ],
    );
  }
}
