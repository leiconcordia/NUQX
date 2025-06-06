import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'verified_page_screen.dart';
import '../widgets/custom_footer.dart';
import '../widgets/custom_header.dart';
import 'package:flutter_application_1/DBHelper/mongodb.dart';
import 'package:email_otp/email_otp.dart';



class OTPVerificationScreen extends StatefulWidget {
  final String userName; // email
final String studentID;
final String firstName;
final String? middleName; // nullable
final String lastName;
final String password;


  const OTPVerificationScreen({
    super.key,
    required this.userName,
    required this.studentID,
    required this.firstName,
    this.middleName, // ✅ optional
    required this.lastName,
    required this.password,
  });

  @override
  _OTPVerificationScreenState createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {


  late EmailOTP myAuth;
  List<String> otp = ["", "", "", "", "", ""];
  int currentIndex = 0;
  int countdown = 60;
  late Timer timer;
  bool isLoading = false;



  @override
  void initState() {
    super.initState();
    // Unfocus any text fields to prevent keyboard from opening
    Future.delayed(Duration.zero, () {
      FocusScope.of(context).unfocus();
    });

    // Step 1: Configure the package (no params needed)
    EmailOTP.config(
      appName: 'NUQX',
      otpType: OTPType.numeric,
      expiry: 60000,
      emailTheme: EmailTheme.v4,
      appEmail: 'leiconcordia2005@gmail.com',
      otpLength: 6,
    );

    myAuth = EmailOTP();

    sendOTP();        // Step 2: Send OTP with the user's email
    startCountdown(); // Optional: countdown UI
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }



  Future<void> sendOTP() async {
    try {
      bool result = await EmailOTP.sendOTP(email: widget.userName); // ✅ provide email here

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result
              ? "OTP sent to ${widget.userName}"
              : "Failed to send OTP"),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  void resendOTP() {
    setState(() {
      countdown = 60;
      otp = ["", "", "", "", "", ""];
      currentIndex = 0;
    });
    sendOTP();
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

  Future<bool> verifyOTP(String otp) async {
    return await EmailOTP.verifyOTP(otp: otp);
  }


  void onSubmit() async {
    if (isLoading) return;
    setState(() => isLoading = true);

    final enteredOTP = otp.join();

    bool isVerified = await verifyOTP(enteredOTP);
    if (!isVerified) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid OTP")),
      );
      return;
    }
    await Future.delayed(const Duration(seconds: 3));
    // ✅ Insert user into DB after OTP verification
      Map<String, dynamic> newUser = {
        "studentID": widget.studentID,
        "firstName": widget.firstName,
        "middleName": widget.middleName, // can be null
        "lastName": widget.lastName,
        "email": widget.userName,
        "password": widget.password,
        "role": "student",
        "accountStatus": "verified",
        "createdAt": DateTime.now().toIso8601String(),
      };

      await MongoDatabase.insertUser(newUser);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => VerifiedPage(userName: widget.userName),
        ),
      );
    }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(

        child: Column(
          children: [
            const CustomHeader(
              title: "Verify",
              showBackButton: true, // This enables the back button
            ),
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
              style: TextStyle(fontSize: 12.sp, color: Colors.black54),
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


            SizedBox(height: 19.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "The code has been sent. ",
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.black87,
                  ),
                ),
                countdown > 0
                    ? Text(
                  "Resend in ${countdown}s",
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey,
                  ),
                )
                    : GestureDetector(
                  onTap: resendOTP,
                  child: Text(
                    "Resend now",
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

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


            const CustomFooter(),// 📌 Using Custom Footer
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




