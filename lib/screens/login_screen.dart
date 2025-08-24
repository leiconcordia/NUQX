import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/verified_page_screen.dart';
import 'package:flutter_application_1/screens/verify_screen.dart';
import 'package:flutter_application_1/screens/home_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:location/location.dart';
import '../widgets/custom_footer.dart';
import '../widgets/custom_header.dart';
import 'package:flutter_application_1/utils/icon_snackbar.dart';


import 'home_screen.dart';
import 'signup_screen.dart';
import 'location_screen.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:flutter_application_1/DBHelper/mongodb.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const CustomHeader(title: "Log in"),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
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
                        _buildTextField(
                          controller: _emailController,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Email is required';
                            }
                            if (!value.trim().endsWith('@gmail.com')) {
                              return 'Must be a valid Gmail address';
                            }
                            return null;
                          },
                        ),
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
                            onPressed: _handleLogin,
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
                            onPressed: () =>
                                _navigateToScreen(context, const SignUpScreen()),
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
            ),
            const CustomFooter(),
          ],
        ),
      ),
    );
  }



  Future<void> _handleLogin() async {

    if (!_formKey.currentState!.validate()) return;

    String email = _emailController.text.trim();
    String password = _passwordController.text;

    var user = await MongoDatabase.getUserByEmail(email);

    if (user == null) {
      _formKey.currentState!.validate(); // trigger UI update
      IconSnackBar.show(
        context: context,
        snackBarType: SnackBarType.error,
        label: 'User not found',
      );

      return;
    }


    if (user['role'] != 'student') {
      IconSnackBar.show(
        context: context,
        snackBarType: SnackBarType.error,
        label: 'You are not authorized to log in',
      );
      return;

    }

    bool passwordMatch = BCrypt.checkpw(password, user['password']);
    if (!passwordMatch) {
      IconSnackBar.show(
        context: context,
        snackBarType: SnackBarType.error,
        label: 'Incorrect password',
      );
      return;
    }


    await _saveLoginState(user['email']);
    IconSnackBar.show(
      context: context,
      snackBarType: SnackBarType.success,
      label: 'Login successful!',
    );

    // _navigateToScreen(
    //        context,
    //   LocationScreen(userName: user['email']),
    //  // HomeScreen(userName: user['email']),
    // );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => HomeScreen(userName: user['email']),
      ),
    );
  }



  Future<void> _saveLoginState(String userName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userName', userName);
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String? Function(String?) validator,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: TextFormField(
        controller: controller,
        validator: validator,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
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
      child: TextFormField(
        obscureText: _obscurePassword,
        controller: _passwordController,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Password is required';
          }

          return null;
        },
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
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
