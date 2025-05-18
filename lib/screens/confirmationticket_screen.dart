import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/custom_footer_with_nav.dart';
import '../widgets/custom_header_with_title.dart';
import 'requestdocuments_form_screen.dart';
import 'tracker_screen.dart';
import '../utils/custom_page_route.dart';

class ConfirmationTicketScreen extends StatelessWidget {
  final String userName;
  final String name;
  final String studentId;
  final String department;
  final String concern;

  const ConfirmationTicketScreen({
    super.key,
    required this.name,
    required this.studentId,
    required this.department,
    required this.concern,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const CustomHeaderWithTitle(title: "Details"),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 16.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCardContent(context),
                      SizedBox(height: 30.h),
                    ],
                  ),
                ),
              ),
            ),
            CustomFooterWithNav(userName: userName, activeTab: 'home',),
          ],
        ),
      ),
    );
  }

  Widget _buildCardContent(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      elevation: 4,
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Confirm",
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                ),
                Image.asset('assets/images/logo2.png', height: 40.h),
              ],
            ),
            SizedBox(height: 10.h),
            _buildDetailText("Name", name),
            _buildDetailText("Student ID", studentId),
            _buildDetailText("Department", department),
            _buildDetailText("Concern", concern),
            SizedBox(height: 20.h),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailText(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Text(
        "$label: $value",
        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              noAnimationRoute(
                RequestDocumentScreen(
                  userName: userName,
                  initialName: name,
                  initialStudentId: studentId,
                  initialDepartment: department,
                  initialConcern: concern,
                ),
              ),
              (route) => false,
            );
          },
          child: Text("Edit", style: TextStyle(fontSize: 16.sp)),
        ),
        SizedBox(width: 10.w),
        ElevatedButton(
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              noAnimationRoute(TrackerScreen(userName: userName)),
              (route) => false,
            );
          },
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            backgroundColor: Colors.blue.shade900,
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          ),
          child: Text(
            "Submit",
            style: TextStyle(color: Colors.white, fontSize: 16.sp),
          ),
        ),
      ],
    );
  }
}
