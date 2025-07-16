import 'package:flutter/material.dart';
import 'package:flutter_application_1/DBHelper/mongodb.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/custom_header.dart';


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
  String windowNumber = '1';

  List<String> notifications = [];
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    _initializeSharedPreferences();
    loadWaitInfo(); // initial load
  }

  Future<void> _initializeSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    List<String>? existingNotifications = prefs.getStringList('notifications') ?? [];
    setState(() {
      notifications = existingNotifications;
    });
  }

  Future<void> loadWaitInfo() async {
    final result = await MongoDatabase.getQueueWaitInfo(widget.userName);
    final statusResult = await MongoDatabase.getUserQueueStatus(widget.userName);

    if (mounted) {
      setState(() {
        peopleInWaiting = result["peopleInWaiting"] ?? 0;
        approxWaitTime = result["approxWaitTime"] ?? "0 min";
        queueStatus = statusResult['status'] ?? 'waiting';
        windowNumber = statusResult['windowNumber'] ?? '1';
      });

      // Load previous data from shared preferences
      int? previousPeopleInWaiting = prefs.getInt('previousPeopleInWaiting');
      String? previousApproxWaitTime = prefs.getString('previousApproxWaitTime');
      String? previousQueueStatus = prefs.getString('previousQueueStatus');
      String? previousWindowNumber = prefs.getString('previousWindowNumber');

      // Check if there are changes in the data
      bool hasChanges = peopleInWaiting != previousPeopleInWaiting ||
          approxWaitTime != previousApproxWaitTime ||
          queueStatus != previousQueueStatus ||
          windowNumber != previousWindowNumber;

      if (hasChanges) {
        // Generate notification messages based on conditions
        List<String> newNotifications = [];
        if (queueStatus == 'Processing') {
          newNotifications.add("It's your turn: Please proceed to counter $windowNumber");
        }
        if (peopleInWaiting == 1) {
          newNotifications.add("Up next: You're next! Please proceed to the counter.");
        }
        if (peopleInWaiting >= 1) {
          newNotifications.add("$approxWaitTime wait: $peopleInWaiting people remaining before it's your turn. Please get ready.");
        }

        // Load existing notifications from shared preferences
        List<String>? existingNotifications = prefs.getStringList('notifications') ?? [];

        // Insert new notifications at the beginning of the list
        existingNotifications.insertAll(0, newNotifications);

        // Save the updated list to shared preferences
        await prefs.setStringList('notifications', existingNotifications);

        // Update the UI with the new notifications
        setState(() {
          notifications = existingNotifications;
        });

        // Save the current data as previous data
        await prefs.setInt('previousPeopleInWaiting', peopleInWaiting);
        await prefs.setString('previousApproxWaitTime', approxWaitTime);
        await prefs.setString('previousQueueStatus', queueStatus);
        await prefs.setString('previousWindowNumber', windowNumber);
      }
    }
  }


  Future<void> _showClearNotificationsDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button to dismiss dialog
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to delete all notifications?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss dialog
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () async {
                // Clear notifications from shared preferences
                await prefs.remove('notifications');
                await prefs.remove('previousPeopleInWaiting');
                await prefs.remove('previousApproxWaitTime');
                await prefs.remove('previousQueueStatus');
                await prefs.remove('previousWindowNumber');
                setState(() {
                  notifications = [];
                });
                Navigator.of(context).pop(); // Dismiss dialog
              },
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            CustomHeader(
              title: "Notifications",
              showBackButton: true,
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: SingleChildScrollView(
                  child: Column(
                    children: notifications.map((notification) {
                      return _buildNotificationCard(
                        title: notification.split(":")[0],
                        message: notification.split(":")[1],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: notifications.isNotEmpty ? _showClearNotificationsDialog : null,
        tooltip: 'Clear Notifications',
        backgroundColor: notifications.isNotEmpty ? const Color(0xFF2D3A8C) : Colors.grey.shade400,
        child: Text(
          'Clear',
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.white,
          ),
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