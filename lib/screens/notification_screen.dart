import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/home_screen.dart';
import 'package:flutter_application_1/utils/custom_page_route.dart';
import 'package:flutter_application_1/widgets/custom_footer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_application_1/widgets/custom_footer_with_nav.dart';
import 'package:flutter_application_1/widgets/custom_header_with_title.dart';
import 'package:flutter_application_1/DBHelper/mongodb.dart';
import 'dart:async';
class NotificationsScreen extends StatefulWidget {
  final String userName;



  const NotificationsScreen({super.key, required this.userName});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreen();
}

class _NotificationsScreen extends State<NotificationsScreen> {

  int peopleInWaiting = 0;
  String approxWaitTime = "0 min";
  String queueStatus = 'waiting';
  String windowNumber = '1';// add at top of your State class


  List<Widget> persistentNotifications = [];
  bool hasInitialWaitNotification = false;

  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    loadWaitInfo(); // initial load

    // Start auto-refresh every 3 seconds
    _refreshTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      loadWaitInfo();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel(); // Cancel timer when widget is disposed
    super.dispose();
  }


  Future<void> loadWaitInfo() async {
    final result = await MongoDatabase.getQueueWaitInfo(widget.userName);
    final statusResult = await MongoDatabase.getUserQueueStatus(widget.userName);

    if (mounted) {
      setState(() {
        peopleInWaiting = result["peopleInWaiting"];
        approxWaitTime = result["approxWaitTime"];
        queueStatus = statusResult['status'];
        windowNumber = statusResult['windowNumber'];
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
            Stack(
              children: [
                 CustomHeaderWithTitle(userName: widget.userName, title: "Notifications"),
                Positioned(
                  left: 14.w,
                  top: 17.h,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () async {


                        Navigator.of(context, rootNavigator: true).pop();
                        }

                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: SingleChildScrollView(
                  child: Builder(
                    builder: (context) {
                      List<Widget> notifications = [];

                      // Add notifications based on conditions
                      if (queueStatus == 'Processing') {
                        notifications.add(
                          _buildNotificationCard(
                            title: "It's your turn",
                            message: "Please proceed to counter $windowNumber",
                          ),
                        );
                      }

                      if (peopleInWaiting == 1) {
                        notifications.add(_buildNotificationCard(
                          title: "Up next",
                          message: "You're next! Please proceed to the counter.",
                        ));
                      }

                      if (peopleInWaiting >= 1) {
                        notifications.add(_buildNotificationCard(
                          title: "$approxWaitTime wait",
                          message: "$peopleInWaiting people remaining before it's your turn. Please get ready.",
                        ));
                      }

                      // If no notifications were added
                      if (notifications.isEmpty) {
                        notifications.add(
                          Padding(
                            padding: EdgeInsets.only(top: 20.h),
                            child: Center(
                              child: Text(
                                "No notifications yet.",
                                style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                              ),
                            ),
                          ),
                        );
                      }

                      return Column(children: notifications);
                    },
                  ),
                ),
              ),
            ),

            CustomFooter(),
          ],
        ),
      ),
    );
  }




  Widget _buildNotificationCard({
    required String title,
    required String message,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2D3A8C),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  message,
                  style: TextStyle(fontSize: 14.sp, color: Colors.black54),
                ),
              ],
            ),
          ),
          Icon(Icons.more_vert, color: Colors.black54),
        ],
      ),
    );



  }
}
