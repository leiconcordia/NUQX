import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/DBHelper/mongodb.dart';
import 'package:flutter_application_1/screens/home_screen.dart';
import 'package:flutter_application_1/utils/custom_page_route.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/custom_footer_with_nav.dart';
import '../widgets/custom_header_with_title.dart';

class TrackerScreen extends StatefulWidget {
  static const String routeName = "/tracker";
  final String userName;



  const TrackerScreen({super.key, required this.userName});
  @override
  State<TrackerScreen> createState() => _TrackerScreen();
}

class _TrackerScreen extends State<TrackerScreen> {
  Map<String, dynamic>? queueInfo; // Holds the queue info

  String? nowServingQueue;


  bool isLoading = true;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    loadQueueInfo();
   //_fetchNowServingNumber();
    _setupAutoRefresh();// Call async method after widget is initialized
  }
  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _setupAutoRefresh() {
    // Refresh data every 30 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _loadData();
    });
  }


  Future<void> _loadData() async {
    try {
      await Future.wait([
        loadQueueInfo(),
        //_loadNowServing(),
      ]);
    } catch (e) {
      // Handle any errors that occur during loading
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }


  // Future<void> _loadNowServing() async {
  //   final nowServing = await MongoDatabase.getNowServingQueueNumber();
  //   if (mounted) {
  //     setState(() => nowServingQueue = nowServing);
  //   }
  // }



  Future<void> loadQueueInfo() async {
    final info = await MongoDatabase.getQueueInfoByEmail(widget.userName);
    setState(() {
      queueInfo = info;
      isLoading = false;
    });
  }


  // Future<void> _fetchNowServingNumber() async {
  //   try {
  //     final number = await MongoDatabase.getNowServingQueueNumber(widget.transactionName);
  //     if (mounted) {
  //       setState(() {
  //         nowServingQueue = number;
  //       });
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       setState(() {
  //         nowServingQueue = null;
  //       });
  //     }
  //     // Optionally show error message
  //     debugPrint('Error fetching queue number: $e');
  //   }
  // }
  //



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Stack(
              children: [
                const CustomHeaderWithTitle(title: "Queue Tracker"),
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
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (queueInfo != null && queueInfo!.isNotEmpty) ...[
                      _buildProgressIndicator(),
                      SizedBox(height: 20.h),
                      _buildQueueInfoBox(),
                    ] else ...[
                      SizedBox(height: 15.h),
                      Text(
                        "NO QUEUE FOUND",
                        style: TextStyle(
                          fontSize: 30.sp,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3A8C), // blue text
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),


            CustomFooterWithNav(
              userName: widget.userName,
              activeTab: 'tracker',),
          ],
        ),
      ),
    );
  }



  Widget _buildProgressIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: CircleAvatar(
            radius: 10.r,
            backgroundColor: index == 0 ? Colors.grey : Colors.grey.shade300,
          ),
        );
      }),
    );
  }



  Widget _buildQueueInfoBox() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Now Serving",
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 5.h),
          Text(
            //now serving queue number
            "Queue No. ",
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20.h),
          Text(
            "Your Queue Number",
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 5.h),
          Text(
            //your queue number
            "${queueInfo!['generatedQueuenumber']}",
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3A8C),
            ),
          ),
          SizedBox(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Flexible(child: _buildQueueInfo("29", "People In Waiting")),
              Flexible(child: _buildQueueInfo("35 MIN", "Approx. Wait Time")),
            ],
          ),


        ],
      ),
    );
  }

  Widget _buildQueueInfo(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3A8C),
          ),
        ),
        SizedBox(height: 5.h),
        Text(
          label,
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w400),
        ),
      ],
    );
  }
}
