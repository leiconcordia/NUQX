import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/admission_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/custom_header_with_title.dart';
import '../widgets/custom_footer_with_nav.dart'; // Updated footer with navigation
import '../utils/custom_page_route.dart';

class InquiryScreen extends StatelessWidget {
  final String userName;

  const InquiryScreen({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Stack(
              children: [
                //const CustomHeaderWithTitle(title: "Inquiry"),
                Positioned(
                  left: 14.w,
                  top: 17.h,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        noAnimationRoute(AdmissionScreen(userName: userName)),
                        (route) => false,
                      );
                    },
                  ),
                ),
              ],
            ),

            // Scrollable Main Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 20.h,
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Hello,',
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade900,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 5.h),
                      Text(
                        'Please select the category of your question.',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.black54,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 30.h),

                      // Inquiry Buttons
                      _buildInquiryButton(context, 'Enrollment & Admissions'),
                      _buildInquiryButton(context, 'Payment & Fees'),
                      _buildInquiryButton(context, 'Document Requests'),
                      _buildInquiryButton(context, 'Campus Facilities'),
                      _buildInquiryButton(context, 'Scholarships'),
                      _buildInquiryButton(context, 'General Concerns'),

                      SizedBox(height: 15.h),
                      GestureDetector(
                        onTap: () {},
                        child: Text(
                          "Didn't find your question? Please go to 'Others'.",
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.blue.shade900,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h), // Bottom spacing
                    ],
                  ),
                ),
              ),
            ),

            // Footer remains at the bottom
            //CustomFooterWithNav(userName: userName, activeTab: 'home',),
          ],
        ),
      ),
    );
  }

  Widget _buildInquiryButton(BuildContext context, String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            backgroundColor: Colors.blue.shade900,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
          onPressed: () {},
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
