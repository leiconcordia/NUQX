import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../services/socket_service.dart';
import '../widgets/custom_header_with_title.dart';
import '../widgets/custom_footer.dart';
import '../utils/custom_page_route.dart';
import '../widgets/main_scaffold.dart';
import 'package:flutter_application_1/DBHelper/mongodb.dart';
import 'package:flutter_application_1/screens/confirmationticket_screen.dart';

class AdmissionScreen extends StatefulWidget {
  final String userName;

  const AdmissionScreen({super.key, required this.userName});

  @override
  State<AdmissionScreen> createState() => _AdmissionScreenState();
}

class _AdmissionScreenState extends State<AdmissionScreen> {
  Map<String, dynamic>? user;
  List<Map<String, dynamic>> transactions = [];
  Timer? refreshTimer;

  @override
  void initState() {
    super.initState();
    fetchUserData();
    loadAdmission();
    SocketService().joinDepartment("admissions");

    // Auto-refresh every 5 seconds
    refreshTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => loadAdmission(),
    );
  }

  @override
  void dispose() {
    refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> loadAdmission() async {
    transactions = await MongoDatabase.getTransactionsByDepartment(
      "admissions",
    );
    if (mounted) setState(() {});
  }

  Future<void> fetchUserData() async {
    try {
      final fetchedUser = await MongoDatabase.getUserByEmail(widget.userName);
      setState(() => user = fetchedUser);
      if (fetchedUser == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('User not found')));
      }
    } catch (e) {
      setState(() => user = null);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error fetching user: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF2D3A8C)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,

      // We will use a bottomNavigationBar for the footer so it can paint
      // the system gesture area itself. No white gap.
      body: SafeArea(
        bottom: false, // DO NOT reserve bottom space for the content
        child: Column(
          children: [
            // Header with back button
            Stack(
              children: [
                CustomHeaderWithTitle(
                  userName: widget.userName,
                  title: "Admission",
                ),
                Positioned(
                  left: 14.w,
                  top: 17.h,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        noAnimationRoute(
                          MainScaffold(userName: widget.userName),
                        ),
                        (route) => false,
                      );
                    },
                  ),
                ),
              ],
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
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

                    // Transactions grid
                    transactions.isEmpty
                        ? Center(
                          child: Text(
                            "No transaction for this department",
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: const Color(0xFF2D3A8C),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                        : Wrap(
                          spacing: 12.w,
                          runSpacing: 12.h,
                          alignment: WrapAlignment.center,
                          children:
                              transactions.map((transaction) {
                                return buildTransactionCard(transaction, () {
                                  Navigator.push(
                                    context,
                                    noAnimationRoute(
                                      ConfirmationTicketScreen(
                                        userName: widget.userName,
                                        transactionConcern: transaction['name'],
                                        transactionID:
                                            transaction['transactionID'],
                                        department: 'admissions',
                                        TransactionAdmin:
                                            transaction['adminName'],
                                      ),
                                    ),
                                  );
                                });
                              }).toList(),
                        ),

                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // IMPORTANT: Footer mounted as bottomNavigationBar so it paints the bottom inset.
      bottomNavigationBar: const CustomFooter(),
    );
  }

  Widget buildTransactionCard(
    Map<String, dynamic> transaction,
    VoidCallback onTap,
  ) {
    final String iconName = transaction['icon'] ?? '';
    final String assetPath = 'assets/icons/mobile-icons/$iconName.svg';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150.w,
        height: 150.h,
        decoration: BoxDecoration(
          color: const Color(0xFF2D3A8C),
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 5,
              offset: Offset(2, 2),
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
                Colors.white,
                BlendMode.srcIn,
              ),
              placeholderBuilder:
                  (context) => const Center(
                    child: CircularProgressIndicator(color: Color(0xFF2D3A8C)),
                  ),
              // Fallback if asset is missing/invalid
              // (SvgPicture has no errorBuilder, so add a try-catch wrapper if needed)
            ),
            SizedBox(height: 8.h),
            Text(
              transaction['name'] ?? 'Transaction',
              style: TextStyle(color: Colors.white, fontSize: 14.sp),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
