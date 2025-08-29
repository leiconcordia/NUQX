import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/home_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/custom_header_with_title.dart';
import '../widgets/custom_footer.dart'; // Updated footer with navigation
import '../widgets/main_scaffold.dart'; // Updated footer with navigation
import 'inquiryform_screen.dart'; // Imported Inquiry Form Screen
import '../utils/custom_page_route.dart';
import 'package:flutter_application_1/DBHelper/mongodb.dart';
import 'package:flutter_application_1/screens/confirmationticket_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AdmissionScreen extends StatefulWidget {
  final String userName;

  const AdmissionScreen({super.key, required this.userName});

  @override
  State<AdmissionScreen> createState() => _AdmissionScreen();
}

class _AdmissionScreen extends State<AdmissionScreen> {
  Map<String, dynamic>? user;
  List<Map<String, dynamic>> transactions = [];
  Timer? refreshTimer;

  @override
  void initState() {
    super.initState();
    fetchUserData();
    loadAdmission();

    // ✅ Auto-refresh every 10 seconds
    refreshTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      loadAdmission();
    });
  }

  @override
  void dispose() {
    refreshTimer?.cancel(); // ✅ Stop timer when screen is disposed
    super.dispose();
  }

  // fetch registrar transactions
  Future<void> loadAdmission() async {
    transactions =
    await MongoDatabase.getTransactionsByDepartment("admissions");
    if (mounted) {
      setState(() {}); // ✅ Update UI when new transactions are fetched
    }
  }

  Future<void> fetchUserData() async {
    try {
      final fetchedUser = await MongoDatabase.getUserByEmail(widget.userName);
      setState(() {
        user = fetchedUser;
      });

      if (fetchedUser == null) {
        // Optional: Handle case where user wasn't found
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not found')),
        );
      }
    } catch (e) {
      setState(() {
        user = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching user: $e')),
      );
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
                CustomHeaderWithTitle(
                    userName: widget.userName, title: "Admission"),
                Positioned(
                  left: 14.w,
                  top: 17.h,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        noAnimationRoute(MainScaffold(userName: widget.userName)),
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
                        "Hello, ${user?['firstName'] ?? 'User'}",
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
                            color: Color(0xFF2D3A8C),
                            // Blue color from your palette
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
                              noAnimationRoute(ConfirmationTicketScreen(
                                  userName: widget.userName,
                                  transactionConcern: transaction['name'],
                                  transactionID: transaction['transactionID'],
                                  department: 'admissions',
                                  TransactionAdmin: transaction['adminName'])),
                            );
                          });
                        }).toList(),
                      ),
                      SizedBox(height: 20.h),

                    ],
                  ),
                ),
              ),
            ),

            CustomFooter(),
            // Footer remains at the bottom
            // CustomFooterWithNav(userName: widget.userName, activeTab: 'home'),
          ],
        ),
      ),
    );
  }


  Widget buildTransactionCard(Map<String, dynamic> transaction,
      VoidCallback onTap) {
    final String iconName = transaction['icon'] ?? '';
    final String assetPath = 'assets/icons/mobile-icons/$iconName.svg';

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
            SvgPicture.asset(
              assetPath,
              width: 40.sp,
              height: 40.sp,
              colorFilter: const ColorFilter.mode(
                  Colors.white, BlendMode.srcIn),
              placeholderBuilder: (
                  context) => const CircularProgressIndicator(),
              // Fallback if asset is missing or invalid
              errorBuilder: (context, error, stackTrace) =>
                  Icon(
                    Icons.credit_card,
                    size: 40.sp,
                    color: Colors.white,
                  ),
            ),
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

}