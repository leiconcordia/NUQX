import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/custom_footer.dart';
import '../widgets/custom_header.dart';
import 'login_screen.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:flutter_application_1/screens/verify_screen.dart';
import 'package:flutter_application_1/DBHelper/mongodb.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {

  final TextEditingController _studentIDController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _middleNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

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
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {


    return Scaffold(
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
                      _buildTextField(controller: _studentIDController),
                      _buildLabel("First Name*"),
                      _buildTextField(controller: _firstNameController ),
                      _buildLabel("Middle Name"),
                      _buildTextField(controller: _middleNameController ),
                      _buildLabel("Last Name*"),
                      _buildTextField(controller: _lastNameController),
                      _buildLabel("Email*"),
                      _buildTextField(controller: _emailController),
                      _buildLabel("Password*"),
                      _buildPasswordField(controller: _passwordController),
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
                            String studentID = _studentIDController.text.trim();
                            String firstName = _firstNameController.text.trim();
                            String middleName = _middleNameController.text.trim();
                            String lastName = _lastNameController.text.trim();
                            String email = _emailController.text.trim();
                            String password = _passwordController.text.trim();

                            if (studentID.isEmpty || firstName.isEmpty || lastName.isEmpty || email.isEmpty || password.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Please fill in all required fields")),
                              );
                              return;
                            }
                            // Basic validations
                            if (studentID.isEmpty || firstName.isEmpty || lastName.isEmpty || email.isEmpty || password.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("❌ Please fill in all required fields")),
                              );
                              return;
                            }
                            // // Validate Student ID: must be exactly 11 digits
                            // if (!RegExp(r'^\d{11}$').hasMatch(studentID)) {
                            //   ScaffoldMessenger.of(context).showSnackBar(
                            //     SnackBar(content: Text("❌ Student ID must be 11 digits")),
                            //   );
                            //   return;
                            // }

                            // Validate Email: must be a valid gmail address
                            if (!email.endsWith("@gmail.com")) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("❌ Email must be a valid @gmail.com address")),
                              );
                              return;
                            }

                            // Validate Password: minimum 8 characters
                            if (password.length < 8) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("❌ Password must be at least 8 characters long")),
                              );
                              return;
                            }

                            // ✅ Check if user with same email exists
                            var existingUser = await MongoDatabase.getUserByEmail(email);
                            if (existingUser != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Email already in use")),
                              );
                              return;
                            }

                            //  check for duplicate Student ID
                            var existingStudent = await MongoDatabase.getUserByStudentID(studentID);
                            if (existingStudent != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Student ID already in use")),
                              );
                              return;
                            }


                            final hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());

                            Map<String, dynamic> newUser = {
                              "studentID": studentID,
                              "firstName": firstName,
                              "middleName": middleName,
                              "lastName": lastName,
                              "email": email,
                              "password": hashedPassword,
                              "role": "student",
                              "accountStatus": "not verified",
                              "createdAt": DateTime.now().toIso8601String(),
                            };

                            await MongoDatabase.insertUser(newUser);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Account created")),
                            );

                            // Optionally navigate or clear fields
                            // Redirect to login screen after a short delay (optional for UX)
                            await Future.delayed(Duration(seconds: 1));

                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => LoginScreen()),
                            );
                            _studentIDController.clear();
                            _firstNameController.clear();
                            _middleNameController.clear();
                            _lastNameController.clear();
                            _emailController.clear();
                            _passwordController.clear();

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
                          onPressed:
                              () => _navigateToScreen(
                                context,
                                const LoginScreen(),
                              ),
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
        transitionDuration: Duration.zero, // Instant transition
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

  Widget _buildTextField({required TextEditingController controller}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: TextField(
       controller: controller,
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

  Widget _buildPasswordField({required TextEditingController controller}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: TextField(
        controller: controller,
        obscureText: _obscurePassword,
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
