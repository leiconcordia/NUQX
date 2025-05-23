import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'menu_screen.dart'; // Import MenuScreen
import 'package:flutter_application_1/DBHelper/mongodb.dart';

class ProfileEditScreen extends StatefulWidget {
  final String userName;


  const ProfileEditScreen({super.key, required this.userName});


  @override
  _ProfileEditScreenState createState() => _ProfileEditScreenState();

}

class _ProfileEditScreenState extends State<ProfileEditScreen> {



  Map<String, dynamic>? user;

  @override
  void initState() {
    super.initState();
    fetchUserData();

  }



  Future<void> fetchUserData() async {
    final fetchedUser = await MongoDatabase.getUserByEmail(widget.userName);
    if (fetchedUser != null) {
      setState(() {
        user = fetchedUser;

        // Initialize controllers with user data
        studentIdController.text = user!['studentID'] ?? '';
        emailController.text = user!['email'] ?? '';
        firstNameController.text = user!['firstName'] ?? '';
        lastNameController.text = user!['lastName'] ?? '';
        middleNameController.text = user!['middleName'] ?? '';

        // Fetch program and year level from DB if they exist
        selectedProgram = user!['program'];
        selectedYearLevel = user!['yearLevel'];
      });
    }
  }
  String? selectedProgram;
  String? selectedYearLevel;

  final List<String> programOptions = ['BSIT', 'BSHM', 'BSCS', 'BSTM'];
  final List<String> yearLevelOptions = ['1', '2', '3', '4'];

  TextEditingController studentIdController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController middleNameController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("My Profile"),
        backgroundColor: Color(0xFF2D3A8C),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 50.r,
                    backgroundImage: AssetImage('assets/profile_pic.png'),
                  ),
                ),
                SizedBox(height: 16.h),
                _buildTextField("Student ID", studentIdController, enabled: false),
                _buildTextField("Email", emailController, enabled: false),
                _buildTextField("First Name", firstNameController),
                _buildTextField("Middle Name", middleNameController),
                _buildTextField("Last Name", lastNameController),

                _buildDropdownField(
                  label: "Program",
                  selectedValue: selectedProgram,
                  options: programOptions,
                  onChanged: (value) {
                    setState(() {
                      selectedProgram = value;
                    });
                  },
                  hintText: "Enter Department",
                ),
                _buildDropdownField(
                  label: "Year Level",
                  selectedValue: selectedYearLevel,
                  options: yearLevelOptions,
                  onChanged: (value) {
                    setState(() {
                      selectedYearLevel = value;
                    });
                  },
                  hintText: "Enter Year Level",
                ),

                SizedBox(height: 16.h),
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      await MongoDatabase.updateUserByEmail(
                        emailController.text.trim(),
                        firstNameController.text.trim(),
                        middleNameController.text.trim(),
                        lastNameController.text.trim(),
                        selectedProgram!.trim(),
                        selectedYearLevel!.trim(),
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Profile updated successfully')),
                      );

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MenuScreen(userName: widget.userName),
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
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildFooterNav(context),
    );
  }




  Widget _buildDropdownField({
    required String label,
    required String? selectedValue,
    required List<String> options,
    required void Function(String?) onChanged,
    required String hintText,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: selectedValue,
            hint: Text(hintText),
            isExpanded: true,
            onChanged: onChanged,
            items: options.map((option) {
              return DropdownMenuItem<String>(
                value: option,
                child: Text(option),
              );
            }).toList(),
          ),
        ),
      ),
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
