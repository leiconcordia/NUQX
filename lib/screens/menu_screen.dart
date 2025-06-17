import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/home_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/custom_header_with_title.dart';
import '../widgets/custom_footer_with_nav.dart'; // Updated footer with navigation
import 'editprofile_screen.dart';
import 'location_screen.dart';
import 'login_screen.dart';
import '../utils/custom_page_route.dart';
import 'package:flutter_application_1/DBHelper/mongodb.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_application_1/utils/icon_snackbar.dart';


class MenuScreen extends StatefulWidget {
  final String userName;

  static const String routeName = "/menu";
  const MenuScreen({super.key, required this.userName});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  Map<String, dynamic>? user;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    // 'userName' is the email in this context
    final fetchedUser = await MongoDatabase.getUserByEmail(widget.userName);
    if (fetchedUser != null) {
      setState(() {
        user = fetchedUser;
      });
    }
  }

  void _pickAndUploadImage(BuildContext context) async {
    final picker = ImagePicker();

    showModalBottomSheet(
      context: context,
      builder: (context) => Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Take Photo'),
            onTap: () async {
              Navigator.pop(context);
              final image = await picker.pickImage(source: ImageSource.camera);
              await _handleImageSelection(image, context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Choose from Gallery'),
            onTap: () async {
              Navigator.pop(context);
              final image = await picker.pickImage(source: ImageSource.gallery);
              await _handleImageSelection(image, context);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _handleImageSelection(XFile? image, BuildContext context) async {
    if (image != null) {
      final bytes = await image.readAsBytes();
      final base64Image = base64Encode(bytes);

      await MongoDatabase.setProfileImage(widget.userName, base64Image);

      // Refresh user data
      await fetchUserData();

      // Show SnackBar after rebuild
      Future.delayed(Duration.zero, () {
        IconSnackBar.show(
          context: context,
          snackBarType: SnackBarType.success,
          label: 'Profile picture updated!',
        );
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    if (user == null) {
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
                 CustomHeaderWithTitle(userName: widget.userName, title: "Menu"),

              ],
            ),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    SizedBox(height: 20.h),

                    GestureDetector(
                      onTap: () => _pickAndUploadImage(context),
                      child: CircleAvatar(
                        radius: 50.r,
                        backgroundImage: user!['profileImage'] != null
                            ? MemoryImage(base64Decode(user!['profileImage']))
                            : AssetImage('assets/profile_image.png') as ImageProvider,

                      ),
                    ),




                    // Name
                    Text(
                      '${user!['firstName']} ${user!['lastName']}',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 20.h),

                    // Menu Title
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      color: Colors.grey.shade300,
                      child: Center(
                        child: Text(
                          'Menu',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),

                    // Menu Items
                    _buildMenuItem(Icons.person_outline, 'My Profile', () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfileEditScreen(userName : widget.userName),
                        ),
                      ); Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfileEditScreen(userName : widget.userName),
                        ),
                      );
                    }),
                    _buildMenuItem(Icons.logout, 'Log Out', () {
                      _showLogoutDialog(context);
                    }),

                    SizedBox(height: 20.h), // Bottom spacing
                  ],
                ),
              ),
            ),


            // Footer with Navigation
           //CustomFooterWithNav(userName: widget.userName, activeTab: 'menu'),
          ],
        ),
      ),
    );
  }





  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.black54, size: 24.sp),
      title: Text(
        title,
        style: TextStyle(fontSize: 16.sp, color: Colors.black87),
      ),
      onTap: onTap,
    );
  }

  // Logout Confirmation Dialog
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
          content: Text(
            "Are you sure you want to log out?",
            style: TextStyle(fontSize: 16.sp),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Cancel
              child: Text(
                "Cancel",
                style: TextStyle(color: Colors.blue, fontSize: 14.sp),
              ),
            ),
            TextButton(
              onPressed: () async{

                final prefs = await SharedPreferences.getInstance();
                await prefs.clear(); // ✅ Clear login state
                // Navigate to Login Screen and clear backstack
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginScreen(),
                  ),
                  (route) => false,
                );
              },
              child: Text(
                "Submit",
                style: TextStyle(color: Colors.red, fontSize: 14.sp),
              ),
            ),
          ],
        );
      },
    );
  }
}
