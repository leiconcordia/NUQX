import 'package:flutter/material.dart';
import 'package:flutter_application_1/DBHelper/mongodb.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import '../services/notification_service.dart';
import '../services/socket_service.dart';
import '../widgets/custom_header.dart';
import '../widgets/custom_footer.dart';

class NotificationsScreen extends StatefulWidget {
  final String userName;

  const NotificationsScreen({super.key, required this.userName});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreen();
}

class _NotificationsScreen extends State<NotificationsScreen> {
  List<String> notifications = [];
  late final SocketService socket;

  @override
  void initState() {
    super.initState();

    MongoDatabase.markNotificationsAsRead(widget.userName);

    // Initialize local notifications
    NotificationService.init(widget.userName);

    // Load old notifications from MongoDB
    _loadNotifications();

    // Initialize WebSocket
    socket = SocketService();
    socket.connect();

    // 4️⃣ Join user-specific room
    socket.joinUser(widget.userName);

    socket.on("notification", (data) {
      setState(() {
        notifications.insert(
          0,
          "${data['title'] ?? 'Notification'}: ${data['message'] ?? ''}",
        );
      });
    });

    // Start periodic polling if you still need it
    NotificationService.startListening(widget.userName);
  }

  @override
  void dispose() {
    //NotificationService.stopListening();
    socket.disconnect();
    super.dispose();
  }

  Future<void> _loadNotifications() async {
    final results = await MongoDatabase.getUserNotifications(widget.userName);
    if (results != null && mounted) {
      setState(() {
        notifications =
            results
                .map<String>(
                  (doc) =>
                      "${doc['title'] ?? 'Queue Transferred'}: ${doc['message'] ?? 'No Message'}",
                )
                .toList()
                .toList(); // Show latest first
      });
    }
  }

  Future<void> _showClearNotificationsDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button to dismiss dialog
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
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
                // ✅ Delete all notifications from MongoDB
                await MongoDatabase.deleteAllNotificationsForUser(
                  widget.userName,
                );

                // Clear notifications in the UI
                setState(() {
                  notifications = [];
                });

                Navigator.of(context).pop(); // Close dialog
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
            CustomHeader(title: "Notifications", showBackButton: true),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: SingleChildScrollView(
                  child: Column(
                    children:
                        notifications.map((notification) {
                          // ✅ Safely split title and message
                          final parts = notification.split(":");
                          final title =
                              parts.isNotEmpty ? parts[0] : "Queue Transferred";
                          final message = parts.length > 1 ? parts[1] : "";

                          return _buildNotificationCard(
                            title: title.trim(),
                            message: message.trim(),
                          );
                        }).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomFooter(),
      floatingActionButton: FloatingActionButton(
        onPressed:
            notifications.isNotEmpty ? _showClearNotificationsDialog : null,
        tooltip: 'Clear Notifications',
        backgroundColor:
            notifications.isNotEmpty
                ? const Color(0xFF2D3A8C)
                : const Color(0xFF2D3A8C),
        child: Text(
          'Clear',
          style: TextStyle(fontSize: 12.sp, color: Colors.white),
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
