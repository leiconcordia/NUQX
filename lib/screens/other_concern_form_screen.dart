import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/custom_footer_with_nav.dart';
import '../widgets/custom_header_with_title.dart';
import 'home_screen.dart'; //
import '../utils/custom_page_route.dart';

class OtherConcernFormScreen extends StatelessWidget {
  final String userName; // Added this line to accept userName

  const OtherConcernFormScreen({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set background to white
      body: SafeArea(
        child: Column(
          children: [
            Stack(
              children: [
                const CustomHeaderWithTitle(title: "Other Concern"),
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
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 16.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDropdown("Student Type*", [
                        "New",
                        "Returning",
                      ], "Returning"),
                      SizedBox(height: 16.h),

                      _buildDropdown("Department*", [
                        "Accounting",
                        "Admission",
                        "Registrar",
                      ], "Accounting"),
                      SizedBox(height: 16.h),

                      _buildTextField("Student ID*", "2023-105905"),
                      SizedBox(height: 16.h),

                      _buildTextField("Full Name*", "Maureen Jae Cruzada"),
                      SizedBox(height: 16.h),

                      _buildTextField("Summary of Concern*", ""),
                      SizedBox(height: 24.h),

                      _buildSubmitButton(),
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

  // Styled text field with rounded corners
  Widget _buildTextField(String label, String initialValue) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 6.h),
        TextField(
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(
              vertical: 16.h,
              horizontal: 16.w,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.r),
              borderSide: BorderSide(color: Colors.grey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.r),
              borderSide: BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.r),
              borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
            ),
          ),
          controller: TextEditingController(text: initialValue),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, List<String> items, String initialValue) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 6.h),
        DropdownButtonFormField<String>(
          dropdownColor: Colors.white, // 👈 This sets the dropdown background
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(
              vertical: 16.h,
              horizontal: 16.w,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.r),
              borderSide: BorderSide(color: Colors.grey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.r),
              borderSide: BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.r),
              borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
            ),
          ),
          value: initialValue,
          items:
              items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item, style: TextStyle(fontSize: 14.sp)),
                );
              }).toList(),
          onChanged: (value) {},
        ),
      ],
    );
  }

  // Submit button
  Widget _buildSubmitButton() {
    return Center(
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          backgroundColor: Colors.blue.shade900,
          padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 14.h),
        ),
        child: Text(
          "Submit",
          style: TextStyle(color: Colors.white, fontSize: 16.sp),
        ),
      ),
    );
  }
}
