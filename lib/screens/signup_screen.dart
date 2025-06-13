import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/custom_footer.dart';
import '../widgets/custom_header.dart';
import 'login_screen.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:flutter_application_1/screens/verify_screen.dart';
import 'package:flutter_application_1/DBHelper/mongodb.dart';
import 'package:flutter_application_1/utils/icon_snackbar.dart';


class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _studentIDController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _middleNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _studentIDController.dispose();
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const CustomHeader(title: "Sign up"),
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                ScrollViewKeyboardDismissBehavior.onDrag,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 50.h),
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
                        _buildLabel("Student ID*"),
                        _buildTextField(
                          controller: _studentIDController,
                          validator: (value) =>
                          value == null || value.isEmpty ? 'Required' : null,
                        ),
                        _buildLabel("First Name*"),
                        _buildTextField(
                          controller: _firstNameController,
                          validator: (value) =>
                          value == null || value.isEmpty ? 'Required' : null,
                        ),
                        _buildLabel("Middle Name"),
                        _buildTextField(
                          controller: _middleNameController,
                          validator: (value) => null,
                        ),
                        _buildLabel("Last Name*"),
                        _buildTextField(
                          controller: _lastNameController,
                          validator: (value) =>
                          value == null || value.isEmpty ? 'Required' : null,
                        ),
                        _buildLabel("Email*"),
                        _buildTextField(
                          controller: _emailController,
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Required';
                            if (!value.endsWith("@gmail.com")) return 'Must be a @gmail.com email';
                            return null;
                          },
                        ),
                        _buildLabel("Password*"),
                        _buildPasswordField(
                          controller: _passwordController,
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Required';
                            if (value.length < 8) return 'At least 8 characters';
                            return null;
                          },
                        ),
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
                              if (!_formKey.currentState!.validate()) return;

                              String studentID = _studentIDController.text.trim();
                              String firstName = _firstNameController.text.trim();
                              String middleName = _middleNameController.text.trim();
                              String lastName = _lastNameController.text.trim();
                              String email = _emailController.text.trim();
                              String password = _passwordController.text.trim();

                              // ✅ Check if user with same email exists
                              var existingUser = await MongoDatabase.getUserByEmail(email);
                              if (existingUser != null) {
                                IconSnackBar.show(
                                  context: context,
                                  snackBarType: SnackBarType.error,
                                  label: 'Email already in use',
                                );
                                return;
                              }
                              //  check for duplicate Student ID
                              var existingStudent = await MongoDatabase.getUserByStudentID(studentID);
                              if (existingStudent != null) {
                                IconSnackBar.show(
                                  context: context,
                                  snackBarType: SnackBarType.error,
                                  label: ' Student ID already in use',
                                );
                                return;
                              }

                              final hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());

                              bool? result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OTPVerificationScreen(
                                    userName: email,
                                    studentID: studentID,
                                    firstName: firstName,
                                    middleName: middleName.isNotEmpty ? middleName : null,
                                    lastName: lastName,
                                    password: hashedPassword,
                                  ),
                                ),
                              );

                              // if (result == true) {
                              //   _studentIDController.clear();
                              //   _firstNameController.clear();
                              //   _middleNameController.clear();
                              //   _lastNameController.clear();
                              //   _emailController.clear();
                              //   _passwordController.clear();
                              // }
                            },
                            child: Text(
                              "Sign up",
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
                            onPressed: () => _navigateToScreen(context, const LoginScreen()),
                            child: RichText(
                              text: TextSpan(
                                text: "Already have an account? ",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14.sp,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Sign in',
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
          contentPadding: EdgeInsets.symmetric(
            vertical: 8.h,
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

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String? Function(String?) validator,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: TextFormField(
        controller: controller,
        obscureText: _obscurePassword,
        validator: validator,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(
            vertical: 8.h,
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