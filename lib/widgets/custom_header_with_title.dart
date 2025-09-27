import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../screens/notification_screen.dart';
import '../utils/custom_page_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:badges/badges.dart' as badges;
import 'package:flutter_application_1/DBHelper/mongodb.dart';

class CustomHeaderWithTitle extends StatefulWidget {
  final String title;
  final String userName;

  const CustomHeaderWithTitle({
    super.key,
    required this.userName,
    required this.title,
  });

  @override
  State<CustomHeaderWithTitle> createState() => _CustomHeaderWithTitleState();
}

class _CustomHeaderWithTitleState extends State<CustomHeaderWithTitle> {
  int unreadCount = 0;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();

    // Start polling for unread notifications
    _startPolling();
  }

  void _startPolling() {
    // Fetch immediately
    _fetchUnreadCount();

    // Then poll every 10 seconds
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _fetchUnreadCount();
    });
  }

  Future<void> _fetchUnreadCount() async {
    final count = await MongoDatabase.getUnreadNotificationCount(
      widget.userName,
    );
    if (mounted) {
      setState(() {
        unreadCount = count;
      });
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 14.w),
          decoration: BoxDecoration(
            color: const Color(0xFF2D3A8C),
            border: Border(
              bottom: BorderSide(color: const Color(0xFFFFD700), width: 2.h),
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Center(
                child: Text(
                  widget.title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

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
