import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../utils/custom_page_route.dart';
import '../widgets/custom_footer_with_nav.dart';
import '../widgets/custom_header_with_title.dart';
import 'home_screen.dart';
import 'paymentform_screen.dart';
import 'confirmationticket_screen.dart';
import 'package:flutter_application_1/DBHelper/mongodb.dart';

class AccountingScreen extends StatefulWidget {
  final String userName ;
  const AccountingScreen({super.key, required this.userName});

  @override
  State<AccountingScreen> createState() => _AccountingScreen();
}

class _AccountingScreen extends State<AccountingScreen> {
  Map<String, dynamic>? user;
  List<Map<String, dynamic>> transactions = [];

  @override
  void initState() {
    super.initState();
    fetchUserData();
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    transactions =
    await MongoDatabase.getTransactionsByDepartment("accounting");
    setState(() {});
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
                        noAnimationRoute(HomeScreen(userName: widget.userName)),
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
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.black54,
                        ),
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
            ),
            CustomFooterWithNav(userName: widget.userName, activeTab: 'home'),
          ],
        ),
      ),
    );
  }

//   Widget _buildAccountingCard(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         Navigator.push(
//           context,
//           noAnimationRoute(ConfirmationTicketScreen(userName: widget.userName)),
//         );
//       },
//       child: Container(
//         width: 120.w,
//         height: 120.h,
//         decoration: BoxDecoration(
//           color: const Color(0xFF2D3A8C),
//           borderRadius: BorderRadius.circular(12.r),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black26,
//               blurRadius: 5,
//               offset: const Offset(2, 2),
//             ),
//           ],
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.credit_card, size: 40.sp, color: Colors.white),
//             SizedBox(height: 8.h),
//             Text(
//               "Payment",
//               style: TextStyle(color: Colors.white, fontSize: 14.sp),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

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
            Icon(Icons.credit_card, size: 40.sp, color: Colors.white),
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
}

