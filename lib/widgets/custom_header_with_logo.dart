import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_application_1/screens/notification_screen.dart';
import 'package:flutter_application_1/utils/custom_page_route.dart';
import 'package:badges/badges.dart' as badges;
import 'package:flutter_application_1/DBHelper/mongodb.dart';

class CustomHeaderWithLogo extends StatefulWidget {
  final String userName;
  const CustomHeaderWithLogo({super.key, required this.userName});

  @override
  State<CustomHeaderWithLogo> createState() => _CustomHeaderWithLogoState();
}

class _CustomHeaderWithLogoState extends State<CustomHeaderWithLogo> {
  int unreadCount = 0;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _loadUnreadNotifications();

    // Start polling every 10 seconds
    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _loadUnreadNotifications();
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadUnreadNotifications() async {
    try {
      final count = await MongoDatabase.getUnreadNotificationCount(
        widget.userName,
      );
      if (mounted) {
        setState(() {
          unreadCount = count;
        });
      }
    } catch (e) {
      print("❌ Error fetching unread notifications: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 14.w),
          decoration: BoxDecoration(
            color: const Color(0xFF2D3A8C), // Blue background
            border: Border(
              bottom: BorderSide(
                color: const Color(0xFFFFD700),
                width: 2.h,
              ), // Yellow underline
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Logo and Title (aligned to the left)
              Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    Image.asset('assets/images/logo.png', height: 40.h),
                    SizedBox(width: 12.w),
                    Text(
                      "NUQX",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Notification button (aligned to the right)
              Align(
                alignment: Alignment.centerRight,
                child: FutureBuilder<int>(
                  future: MongoDatabase.getUnreadNotificationCount(
                    widget.userName,
                  ),
                  builder: (context, snapshot) {
                    int unreadCount = snapshot.data ?? 0;

                    // 🔹
                    // return badges.Badge(
                    //   showBadge: unreadCount > 0,
                    //   badgeContent: Text(
                    //     unreadCount.toString(),
                    //     style: TextStyle(color: Colors.white, fontSize: 10.sp),
                    //   ),
                    //   position: badges.BadgePosition.topEnd(top: -1.h, end: -1.w),
                    //   child: IconButton(
                    //     icon: const Icon(Icons.notifications, color: Colors.white),
                    //     onPressed: () {
                    //       Navigator.push(
                    //         context,
                    //         noAnimationRoute(
                    //           NotificationsScreen(userName: widget.userName),
                    //         ),
                    //       );
                    //     },
                    //   ),
                    // );

                    // 🔹 Only show notification icon without badge
                    return IconButton(
                      icon: const Icon(
                        Icons.notifications,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          noAnimationRoute(
                            NotificationsScreen(userName: widget.userName),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
