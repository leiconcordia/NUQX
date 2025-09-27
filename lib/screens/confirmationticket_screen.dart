import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/notification_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../services/socket_service.dart';
import '../widgets/custom_footer.dart';
import '../widgets/custom_header_with_title.dart';
import 'requestdocuments_form_screen.dart';
import 'tracker_screen.dart';
import '../utils/custom_page_route.dart';
import 'package:flutter_application_1/DBHelper/mongodb.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/main_scaffold.dart';

class ConfirmationTicketScreen extends StatefulWidget {
  final String userName;
  final String transactionConcern;
  final String transactionID;
  final String department;
  final String TransactionAdmin;

  const ConfirmationTicketScreen({
    super.key,
    required this.userName,
    required this.transactionConcern,
    required this.transactionID,
    required this.department,
    required this.TransactionAdmin,
  });
  @override
  State<ConfirmationTicketScreen> createState() => _ConfirmationTicketScreen();
}

class _ConfirmationTicketScreen extends State<ConfirmationTicketScreen> {
  Map<String, dynamic>? user;
  int peopleInWaiting = 0;
  String approxWaitTime = "0 min";

  @override
  void initState() {
    super.initState();
    fetchUserData();
    loadWaitInfo();
  }

  static Future<void> resetConfirmationFlag() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasConfirmedTransaction', false);
  }

  Future<void> loadWaitInfo() async {
    final result = await MongoDatabase.getQueueWaitInfo(widget.userName);

    if (mounted) {
      setState(() {
        peopleInWaiting = result["peopleInWaiting"];
        //approxWaitTime = result["approxWaitTime"];
      });
    }
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
            CustomHeaderWithTitle(userName: widget.userName, title: "Details"),
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
          ],
        ),
      ),
      bottomNavigationBar: const CustomFooter(),
    );
  }

  Widget _buildCardContent(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      elevation: 4,
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child:
            user == null
                ? const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF2D3A8C), // 🔵 custom blue
                  ),
                ) // or a placeholder
                : Column(
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

                    _buildDetailText(
                      "Student ID",
                      '${user?['studentID'] ?? 'N/A'}',
                    ),
                    _buildDetailText(
                      "Student Name",
                      '${user?['firstName'] ?? ''} ${user?['lastName'] ?? 'User'}',
                    ),

                    _buildDetailText(
                      "Year Level",
                      '${user?['yearLevel'] ?? 'N/A'}',
                    ),
                    _buildDetailText("Program", '${user?['program'] ?? 'N/A'}'),
                    // _buildDetailText(
                    //   "Concern",
                    //   widget.transactionConcern,
                    // ),
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
          child: Text(
            "Back",
            style: TextStyle(fontSize: 16.sp, color: Color(0xFF2D3A8C)),
          ),
        ),
        SizedBox(width: 10.w),
        ElevatedButton(
          onPressed: () async {
            final hasActive = await MongoDatabase.hasActiveQueue(
              widget.userName,
            );

            if (hasActive) {
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: Text("Queue Already Exists"),
                      content: Text(
                        "You already have an ongoing queue. Please wait until it is completed before queuing again.",
                      ),
                      actions: [
                        TextButton(
                          child: Text("OK"),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
              );
              return;
            }

            // Instead of generating + inserting separately, use the atomic method
            final queueData = {
              'studentID': user?['studentID'] ?? 'N/A',
              'user': widget.userName,
              'studentName':
                  (user?['firstName'] ?? '') +
                  ' ' +
                  (user?['lastName'] ?? 'User'),
              'program': user?['program'] ?? 'N/A',
              'yearLevel': user?['yearLevel'] ?? 'N/A',
              'transactionName': widget.transactionConcern,
              'transactionID': widget.transactionID,
              'isPriority': false,
              'status': 'Waiting',
              'departmentAdmin': widget.TransactionAdmin,
              'windowNumber': '',
              'createdAt': DateTime.now().toUtc(),
              'updatedAt': '',
              'dateEnded': '',
              'department': widget.department,
            };

            // 🔑 Generate queue number + insert atomically
            final result = await MongoDatabase.generateAndInsertQueueNumber(
              widget.transactionID,
              widget.transactionConcern,
              queueData,
            );

            if (result != null) {
              // result will return full inserted document with _id
              final insertedDoc = result;

              // Emit socket event only AFTER transaction succeeds
              SocketService().emitWhenConnected('queueChanged', {
                'action': 'create',
                'department': widget.department,
                'data': {
                  ...insertedDoc,
                  '_id':
                      insertedDoc['_id']
                          .toHexString(), // ensure _id is plain string
                  'createdAt': insertedDoc['createdAt'].toIso8601String(),
                },
              });
            }

            print("✅ Queue generated, inserted, and broadcast successfully!");
            await loadWaitInfo();

            await MongoDatabase.pushNotification(
              user: widget.userName,
              title: "$approxWaitTime wait time",
              message: "$peopleInWaiting people ahead of you.",
            );
            NotificationService.showLocalNotification(
              "$approxWaitTime wait time",
              "$peopleInWaiting people ahead of you.",
            );

            // Navigate after success
            Navigator.pushAndRemoveUntil(
              context,
              noAnimationRoute(
                MainScaffold(
                  userName: widget.userName,
                  initialTabIndex: 1, // Tracker tab
                ),
              ),
              (route) => false,
            );

            await resetConfirmationFlag();
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
