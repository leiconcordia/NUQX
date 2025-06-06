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

  bool isLoading = true;
  Timer? _refreshTimer;
  String? nowServingQueueNumber;
  int peopleInWaiting = 0;
  String approxWaitTime = "0 min";
  String queueStatus = 'waiting';

  @override
  void initState() {
    super.initState();
    loadQueueInfo();
   //_fetchNowServingNumber();
    _setupAutoRefresh();// Call async method after widget is initialized
    loadWaitInfo();
    _loadNowServing();
  }
  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _setupAutoRefresh() {
    // Refresh data every 30 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _loadData();
    });
  }




  Future<void> _loadData() async {
    try {
      await Future.wait([
        loadQueueInfo(),
        _loadNowServing(),
        loadWaitInfo(),
        QueueStatusInfo()

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

  Future<void> loadWaitInfo() async {
    final result = await MongoDatabase.getQueueWaitInfo(widget.userName);

    if (mounted) {
      setState(() {
        peopleInWaiting = result["peopleInWaiting"];
        approxWaitTime = result["approxWaitTime"];
      });
    }
  }


  Future<void> _loadNowServing() async {
    final nowServing = await MongoDatabase.getNowServingForUser(widget.userName);
    if (mounted) {
      setState(() {
        nowServingQueueNumber = nowServing; // Save it to state
      });
    }
  }



  Future<void> loadQueueInfo() async {
    final info = await MongoDatabase.getQueueInfoByEmail(widget.userName);
    setState(() {
      queueInfo = info;

    });
  }

  Future<void> QueueStatusInfo() async {
    final result = await MongoDatabase.getUserQueueInfoAndStatus(widget.userName);

    if (mounted && result != null) {
      setState(() {
        queueStatus = result['status'] ?? 'not found';
        queueInfo = result;
      });
    } else {
      setState(() {
        queueStatus = 'not found';
        queueInfo = null;
      });
    }
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
                CustomHeaderWithTitle(userName: widget.userName, title: "Queue Tracker"),
                Positioned(
                  left: 14.w,
                  top: 17.h,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      _refreshTimer?.cancel();
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
                child: Builder(
                  builder: (_) {
                    if (isLoading) {
                      // Show loading spinner or blank container to avoid flicker
                      return Center(child: CircularProgressIndicator());
                    } else if (queueInfo != null && queueInfo!.isNotEmpty) {
                      // Your existing queue UI based on status
                      if (queueStatus == 'processing') {
                        return buildYourTurnBox(
                          queueNumber: queueInfo?['generatedQueuenumber']?.toString() ?? '-',
                        );
                      } else if (queueStatus == 'done') {
                        return _buildTransactionCompleteBox();
                      } else {
                        return Column(
                          children: [
                            _buildProgressIndicator(),
                            SizedBox(height: 20.h),
                            _buildQueueInfoBox(),
                          ],
                        );
                      }
                    } else {
                      // No queue data after loading
                      return Center(
                        child: Text(
                          "You're still \nnot in \nqueue!",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 50.sp,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D3A8C),
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
            ),

            CustomFooterWithNav(
              userName: widget.userName,
              activeTab: 'tracker',
            ),
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
            // Now serving queue number or fallback
            "Queue No. ${nowServingQueueNumber ?? '-'}",
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
              Flexible(child: _buildQueueInfo("$peopleInWaiting", "People In Waiting")),
              Flexible(child: _buildQueueInfo(approxWaitTime, "Approx. Wait Time")),
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



  Widget buildYourTurnBox({required String queueNumber}) {
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
            "It's your turn",
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            "Your Queue Number",
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 5.h),
          Text(
            queueNumber,
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3A8C),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Please proceed to counter "1"',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3A8C),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildTransactionCompleteBox() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Big blue circle with check icon
          Container(
            width: 200.w,
            height: 200.w,

            child: Center(
              child: Icon(
                Icons.check_circle,
                color: Color(0xFF2D3A8C),
                size: 150.sp,
              ),
            ),
          ),

          SizedBox(height: 24.h),

          // Transaction complete text
          Text(
            "Transaction Complete",
            style: TextStyle(
              fontSize: 25.sp,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3A8C),
            ),
          ),

          SizedBox(height: 32.h),

        ],
      ),
    );
  }


}



