import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'menu_screen.dart'; // Import MenuScreen

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  _ProfileEditScreenState createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final TextEditingController studentIdController = TextEditingController(
    text: "2023-109905",
  );
  final TextEditingController emailController = TextEditingController(
    text: "mcruzada@student.nu",
  );
  final TextEditingController firstNameController = TextEditingController(
    text: "Maureen Joe",
  );
  final TextEditingController lastNameController = TextEditingController(
    text: "Cruzada",
  );
  final TextEditingController middleNameController = TextEditingController();

  var userName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Profile"),
        backgroundColor: Color(0xFF2D3A8C),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50.r,
              backgroundImage: AssetImage(
                'assets/profile_pic.png',
              ), // Replace with actual image asset
            ),
            SizedBox(height: 16.h),
            _buildTextField("Student ID", studentIdController, enabled: false),
            _buildTextField("Email", emailController, enabled: false),
            _buildTextField("First Name", firstNameController),
            _buildTextField("Last Name", lastNameController),
            _buildTextField("Middle Name", middleNameController),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () {
                // Navigate back to MenuScreen after saving
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MenuScreen(userName: userName),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF2D3A8C),
                padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 40.w),
              ),
              child: Text(
                "Save",
                style: TextStyle(color: Colors.white, fontSize: 16.sp),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildFooterNav(context),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool enabled = true,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: TextField(
        controller: controller,
        enabled: enabled,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildFooterNav(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 70.h,
      decoration: BoxDecoration(
        color: Color(0xFF2D3A8C),
        border: Border(top: BorderSide(color: Color(0xFFFFD700), width: 3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavButton(context, Icons.assignment, "Form"),
          _buildNavButton(context, Icons.play_arrow, "Tracker"),
          _buildNavButton(context, Icons.menu, "Menu"),
        ],
      ),
    );
  }

  Widget _buildNavButton(BuildContext context, IconData icon, String label) {
    return IconButton(
      onPressed: () {
        // TODO: Implement navigation
      },
      icon: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 24.sp),
          Text(label, style: TextStyle(color: Colors.white, fontSize: 12.sp)),
        ],
      ),
    );
  }
}
