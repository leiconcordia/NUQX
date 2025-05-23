import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/custom_footer_with_nav.dart';
import '../widgets/custom_header_with_title.dart';
import 'requestdocuments_form_screen.dart';
import 'tracker_screen.dart';
import '../utils/custom_page_route.dart';
import 'package:flutter_application_1/DBHelper/mongodb.dart';

class ConfirmationTicketScreen extends StatefulWidget {
  final String userName;
  final String transactionConcern;

  const ConfirmationTicketScreen({super.key, required this.userName, required this.transactionConcern});
  @override
  State<ConfirmationTicketScreen> createState() => _ConfirmationTicketScreen();
}

class _ConfirmationTicketScreen extends State<ConfirmationTicketScreen> {
  Map<String, dynamic>? user;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    // 'userName' is the email in this context
    final fetchedUser = await MongoDatabase.getUserByEmail(widget.userName);
    if (fetchedUser != null) {
      setState(() {
        user = fetchedUser;
      });
    }
  }


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
            CustomFooterWithNav(userName: widget.userName, activeTab: 'home',),
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
            _buildDetailText("Name", '${user!['firstName']} ${user!['lastName']}'),
            _buildDetailText("Student ID", '${user!['studentID']}' ),
            _buildDetailText("Department", '${user!['program']}' ),
            _buildDetailText("Concern", widget.transactionConcern ),
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
            Navigator.pop(context);
          },
          child: Text("Back", style: TextStyle(fontSize: 16.sp)),
        ),

        SizedBox(width: 10.w),
        ElevatedButton(
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              noAnimationRoute(TrackerScreen(userName: widget.userName)),
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