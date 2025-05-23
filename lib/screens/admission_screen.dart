import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/home_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/custom_header_with_title.dart';
import '../widgets/custom_footer_with_nav.dart'; // Updated footer with navigation
import 'inquiryform_screen.dart'; // Imported Inquiry Form Screen
import '../utils/custom_page_route.dart';
import 'package:flutter_application_1/DBHelper/mongodb.dart';
import 'package:flutter_application_1/screens/confirmationticket_screen.dart';

class AdmissionScreen extends StatefulWidget {
  final String userName;

  const AdmissionScreen({super.key, required this.userName});

  @override
  State<AdmissionScreen> createState() => _AdmissionScreen();
}

class _AdmissionScreen extends State<AdmissionScreen> {
  Map<String, dynamic>? user;
  List<Map<String, dynamic>> transactions = [];

  @override
  void initState() {
    super.initState();
    fetchUserData();
    loadAdmission();
  }

  // fetch registrar transactions
  Future<void> loadAdmission() async {
    transactions =
    await MongoDatabase.getTransactionsByDepartment("admission");
    setState(() {});
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
    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Stack(
              children: [
                const CustomHeaderWithTitle(title: "Admission"),
                Positioned(
                  left: 14.w,
                  top: 17.h,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        noAnimationRoute(HomeScreen(userName: widget.userName)),
                        (route) => false,
                      );
                    },
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 30.h),
                    Text(
                      "Hello, ${user!['firstName']}",
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2D3A8C),
                      ),
                    ),
                    SizedBox(height: 5.h),
                    Text(
                      "What will you do today?",
                      style: TextStyle(fontSize: 16.sp, color: Colors.black54),
                    ),
                    SizedBox(height: 40.h),
                    transactions.isEmpty
                        ? Center(
                      child: Text(
                        "No transaction for this department",
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Color(0xFF2D3A8C), // Blue color from your palette
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                        : Wrap(
                      spacing: 12.w,
                      runSpacing: 12.h,
                      alignment: WrapAlignment.center,
                      children: transactions.map((transaction) {
                        return buildTransactionCard(transaction, () {
                          Navigator.push(
                            context,
                            noAnimationRoute(ConfirmationTicketScreen(userName: widget.userName, transactionConcern: transaction['name'])),
                          );
                        });
                      }).toList(),
                    ),
                    SizedBox(height: 20.h),

                  ],
                ),
              ),
            ),


            // Footer remains at the bottom
            CustomFooterWithNav(userName: widget.userName, activeTab: 'home'),
          ],
        ),
      ),
    );
  }
}

Widget buildTransactionCard(Map<String, dynamic> transaction,
    VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
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
          Icon(Icons.newspaper, size: 40.sp, color: Colors.white),
          // You can map from transaction['icon'] if needed
          SizedBox(height: 8.h),
          Text(
            transaction['name'] ?? 'Transaction',
            style: TextStyle(color: Colors.white, fontSize: 14.sp),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}

