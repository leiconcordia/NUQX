import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/DBHelper/mongodb.dart';
import 'package:flutter_application_1/screens/home_screen.dart';
import 'package:flutter_application_1/utils/custom_page_route.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/custom_footer_with_nav.dart';
import '../widgets/custom_header_with_title.dart';
import '../widgets/main_scaffold.dart';
import 'package:shared_preferences/shared_preferences.dart';


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
  //List<String> nowServingQueueNumbers = [];
  String? nowServingQueueNumber;

  int peopleInWaiting = 0;
  String approxWaitTime = "0 min";
  String queueStatus = '-';


  bool hasConfirmedCompletion = false;
  final String confirmationKey = 'hasConfirmedTransaction';


  @override
  void initState() {
    super.initState();
    _loadData();
    _loadConfirmationStatus();
    _setupAutoRefresh();// Call async method after widget is initialized

  }
  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadConfirmationStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      hasConfirmedCompletion = prefs.getBool(confirmationKey) ?? false;
    });
  }

  void _setupAutoRefresh() {
    // Refresh data every 30 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _loadData();
    });
  }




  Future<void> _loadData() async {
    try {
      await Future.wait([
        loadQueueInfo(),
        _loadNowServing(),
        loadWaitInfo(),
        //QueueStatusInfo()

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
        peopleInWaiting = result["peopleInWaiting"] ;
        approxWaitTime = result["approxWaitTime"];
      });
    }
  }


  Future<void> _loadNowServing() async {
    final nowServing = await MongoDatabase.getNowServingForUser(widget.userName);
    if (mounted) {
      setState(() {
        nowServingQueueNumber = nowServing;
      });
    }
  }



  Future<void> loadQueueInfo() async {
    try {
      final info = await MongoDatabase.getUserQueueStatus(widget.userName);
      setState(() {
        queueInfo = info;
        print("Status from DB: ${queueInfo?['status']}");


      });
    } catch (e) {
      print('Error loading queue info: $e');
      setState(() {
        queueInfo = null;
        queueStatus = '';
      });
    }
  }




  @override
  Widget build(BuildContext context) {
    if (isLoading != false) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Stack(
              children: [
                CustomHeaderWithTitle(userName: widget.userName, title: "Queue Tracker"),

              ],
            ),

            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                child: Builder(
                  builder: (_) {
                    if (queueInfo != null && queueInfo!.isNotEmpty) {
                      if (queueInfo?['status'] == 'Processing') {
                        return Column(
                          children: [

                            _buildProgressIndicator(peopleInWaiting: peopleInWaiting),
                            buildYourTurnBox(
                              queueNumber: queueInfo?['queueNumber']?.toString() ?? '-',
                              windowNumber: queueInfo?['windowNumber']?.toString() ?? '-',
                            ),


                          ],
                        );

                      } else if (queueInfo?['status'] == 'Waiting') {
                        return Column(
                          children: [
                            _buildProgressIndicator(peopleInWaiting: peopleInWaiting),
                            SizedBox(height: 20.h),
                            _buildQueueInfoBox(),
                          ],
                        );
                      } else if (queueInfo?['status'] == 'Completed') {
                        if (hasConfirmedCompletion) {
                          return _buildNotInQueue(); // ⬅️ Show this AFTER user taps Confirm
                        } else {
                          return _buildTransactionCompleteBox(); // ⬅️ Default display
                        }
                      }
                    }
                    // Default case when queueInfo is null/empty or queueStatus doesn't match
                    return _buildNotInQueue();
                  },
                ),
              ),
            ),


            // CustomFooterWithNav(
            //   userName: widget.userName,
            //   activeTab: 'tracker',
            // ),
          ],
        ),
      ),
    );
  }





  Widget _buildProgressIndicator({required int peopleInWaiting}) {
    int activeIndex;

    if (peopleInWaiting >= 4) {
      activeIndex = 1;
    } else if (peopleInWaiting == 3) {
      activeIndex = 2;
    } else if (peopleInWaiting == 2) {
      activeIndex = 3;
    } else if (peopleInWaiting == 1) {
      activeIndex = 4;
    } else if (peopleInWaiting == 0) {
      activeIndex = 5;
    } else {
      activeIndex = -1; // fallback for invalid negative values
    }



    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final isFilled = index <= activeIndex;

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          child: Column(
            children: [
              // Number above circle
              Text(
                '${index + 1}',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 4.h),
              // Circle with check or empty
              CircleAvatar(
                radius: 20.r,
                backgroundColor: isFilled
                    ? const Color(0xFF34A853) // Green when filled
                    : Colors.grey.shade300,   // Gray when not
                child: isFilled
                    ? Icon(Icons.check, color: Colors.white, size: 14.sp)
                    : null,
              ),
            ],
          ),
        );
      }),
    );
  }






  Widget _buildQueueInfoBox() {
    return Container(
      margin: EdgeInsets.only(left: 5, top: 20, right: 5, bottom: 10),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
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

  Widget _buildNotInQueue() {
    return Container(
      margin: EdgeInsets.only(left: 30, top: 20, right: 30, bottom: 200),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          "You're still \nnot in \nqueue!",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 50.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2D3A8C),
          ),
        ),
      ),
    );
  }



  Widget buildYourTurnBox({
    required String queueNumber,
    required String windowNumber,
  }) {
    return Container(
      margin: EdgeInsets.only(left: 30, top: 20, right: 30, bottom: 100),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.5),
            spreadRadius: 5,
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
              fontSize: 20.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 5.h),
          Text(
            queueNumber,
            style: TextStyle(
              fontSize: 30.sp,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3A8C),
            ),
          ),
          SizedBox(height: 16.h),

          // Split into two Text widgets for better layout
          Text(
            'Please proceed to counter',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3A8C),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 5.h),
          Text(
            windowNumber,
            style: TextStyle(
              fontSize: 35.sp,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3A8C),
            ),
            textAlign: TextAlign.center,
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
          Text(
            "Transaction Complete",
            style: TextStyle(
              fontSize: 25.sp,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3A8C),
            ),
          ),
          SizedBox(height: 32.h),

          // ✅ Confirm Button
          ElevatedButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool(confirmationKey, true);

              setState(() {
                hasConfirmedCompletion = true;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF2D3A8C),
              padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
            ),
            child: Text("Confirm", style: TextStyle(fontSize: 16.sp, color: Colors.white)),
          ),

        ],
      ),
    );
  }




}



