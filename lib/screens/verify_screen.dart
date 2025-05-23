import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'verified_page_screen.dart';
import '../widgets/custom_footer.dart';
import '../widgets/custom_header.dart';




class OTPVerificationScreen extends StatefulWidget {
  final String userName;
  const OTPVerificationScreen({super.key, required this.userName});

  @override
  _OTPVerificationScreenState createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  List<String> otp = ["", "", "", "", "", ""];
  int currentIndex = 0;
  int countdown = 60;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    startCountdown();
  }

  void startCountdown() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdown > 0) {
        setState(() {
          countdown--;
        });
      }
    });
  }

  void onNumberTap(String value) {
    if (currentIndex < 6) {
      setState(() {
        otp[currentIndex] = value;
        currentIndex++;
      });
    }
  }

  void onBackspace() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
        otp[currentIndex] = "";
      });
    }
  }

  void onSubmit() {
    if (otp.join().length == 6) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VerifiedPage(userName: widget.userName),
        ),
      );
    }
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const CustomHeader(title: "Verify"), // 🏷 Using Custom Header
            SizedBox(height: 30.h),
            Text(
              "Enter Verification Code",
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              "Enter the OTP sent to \n${widget.userName}!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp, color: Colors.black54),
            ),
            SizedBox(height: 20.h),

            // OTP Input Boxes
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(6, (index) {
                return Container(
                  width: 40.w,
                  height: 40.h,
                  margin: EdgeInsets.symmetric(horizontal: 5.w),
                  decoration: BoxDecoration(
                    color:
                        index == currentIndex
                            ? const Color(0xFF2D3A8C)
                            : Colors.grey[300],
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    otp[index],
                    style: TextStyle(
                      fontSize: 18.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }),
            ),

            SizedBox(height: 20.h),
            Text(
              "The Code Has Been Sent  Resend (${countdown}s)",
              style: TextStyle(fontSize: 14.sp, color: Colors.black87),
            ),

            SizedBox(height: 30.h),

            // Number Pad
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.symmetric(horizontal: 40.w),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1.5,
                ),
                itemCount: 12,
                itemBuilder: (context, index) {
                  if (index == 9) {
                    return const SizedBox(); // Empty space
                  } else if (index == 10) {
                    return _buildNumberButton("0");
                  } else if (index == 11) {
                    return _buildActionButton(Icons.backspace, onBackspace);
                  } else {
                    return _buildNumberButton("${index + 1}");
                  }
                },
              ),
            ),

            // Submit Button
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20.h),
              child: ElevatedButton(
                onPressed: onSubmit,
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  backgroundColor: const Color(0xFF2D3A8C),
                  padding: EdgeInsets.all(18.w),
                ),
                child: Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                  size: 24.sp,
                ),
              ),
            ),

            const CustomFooter(), // 📌 Using Custom Footer
          ],
        ),
      ),
    );
  }

  Widget _buildNumberButton(String number) {
    return GestureDetector(
      onTap: () => onNumberTap(number),
      child: Container(
        margin: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          number,
          style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 24.sp),
      ),
    );
  }
}
