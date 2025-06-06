import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/verified_page_screen.dart';
import 'package:flutter_application_1/screens/verify_screen.dart';
import 'package:flutter_application_1/screens/home_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/custom_footer.dart';
import '../widgets/custom_header.dart';
import 'signup_screen.dart';
import 'location_screen.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:flutter_application_1/DBHelper/mongodb.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const CustomHeader(title: "Log in"),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 100.h),
                      Center(
                        child: Text(
                          "Welcome to NUQX!",
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2D3A8C),
                          ),
                        ),
                      ),
                      SizedBox(height: 30.h),
                      _buildLabel("Email*"),
                      _buildTextField(controller: _emailController),
                      _buildLabel("Password*"),
                      _buildPasswordField(),
                      SizedBox(height: 20.h),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2D3A8C),
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24.r),
                            ),
                          ),

                          onPressed: () async {
                            String email = _emailController.text.trim();
                            String password = _passwordController.text;

                            // 1. Get user from MongoDB
                            var user = await MongoDatabase.getUserByEmail(email);

                            if (user == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("User not found")),
                              );
                              return;
                            }

                            // 2. Check role
                            if (user['role'] != 'student') {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("You are not authorized to log in.")),
                              );
                              return;
                            }

                            // 3. Compare password using BCrypt
                            bool passwordMatch = BCrypt.checkpw(password, user['password']);

                            if (passwordMatch) {
                              await MongoDatabase.verifyAccountByEmail(email);

                              _navigateToScreen(
                                     context,
                                LocationScreen(userName: user['email']),
                              );

                              // // Check account verification status
                              // if (user['AccountStatus'] == 'verified') {
                              //   // Account is verified, navigate to HomeScreen
                              //   _navigateToScreen(
                              //     context,
                              //     HomeScreen(userName: user['email']),
                              //   );
                              // } else {
                              //   // Account is not verified, navigate to OTPVerificationScreen
                              //   _navigateToScreen(
                              //     context,
                              //     OTPVerificationScreen(
                              //         userName: user['email']),
                              //   );
                              // }

                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Incorrect password")),
                              );
                            }
                          },

                          child: Text(
                            "Log in",
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Center(
                        child: TextButton(
                          onPressed:
                              () => _navigateToScreen(
                                context,
                                const SignUpScreen(),
                              ),
                          child: RichText(
                            text: TextSpan(
                              text: "Don’t have an account? ",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14.sp,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Sign up',
                                  style: TextStyle(
                                    color: const Color(0xFF2D3A8C),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ),
            ),
            const CustomFooter(),
          ],
        ),
      ),
    );
  }

  void _navigateToScreen(BuildContext context, Widget screen) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return child;
        },
      ),
    );
  }

  /// ✅ Added missing helper methods

  Widget _buildLabel(String label) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(
            vertical: 14.h,
            horizontal: 16.w,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24.r),
            borderSide: const BorderSide(color: Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: TextField(
        obscureText: _obscurePassword,
        controller: _passwordController,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(
            vertical: 14.h,
            horizontal: 16.w,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24.r),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey,
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
        ),
      ),
    );
  }
}
