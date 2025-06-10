import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'menu_screen.dart'; // Import MenuScreen
import 'package:flutter_application_1/DBHelper/mongodb.dart';
import '../widgets/custom_header_with_title.dart';
import '../widgets/custom_footer_with_nav.dart';
import 'package:flutter_application_1/utils/icon_snackbar.dart';
import 'dart:convert';

import 'package:image_picker/image_picker.dart';

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

        // selectedProgram = collegePrograms[selectedCollege].contains(user!['program']?.toString().trim())
        //     ? user!['yearLevel'].toString().trim()
        //     : null;

        selectedProgram = user!['program']?.toString().trim();

        selectedCollege = collegePrograms.entries
            .firstWhere(
              (entry) => entry.value.contains(selectedProgram),
          orElse: () => MapEntry('', []),
        )
            .key;

// If no matching college was found, reset to selection mode
        if (selectedCollege == '') {
          selectedCollege = null;
          selectedProgram = null;
          isSelectingCollege = true;
        } else {
          isSelectingCollege = false;
        }


        selectedYearLevel = yearLevelOptions.contains(user!['yearLevel']?.toString().trim())
            ? user!['yearLevel'].toString().trim()
            : null;

      });
    }
  }

  String? selectedProgram;
  String? selectedCollege;
  bool isSelectingCollege = true;
  String? selectedYearLevel;


  final Map<String, List<String>> collegePrograms = {
    'College of Computing and Information Technology (CCIT)': [
      'BSCS-ML',
      'BSCS-DF',
      'DIT',
      'ACT',
      'BSIT-MWA',
      'BSIT-MAA',
      'MIT',
      'PhDCS',
      'MSCS',
    ],
    'College of Allied Health (CAH)': ['BSN', 'BSP', 'BSMT'],
    'College of Business and Accountancy (CBA)': [
      'BSAccountancy',
      'BSMA',
      'BSBA-MktgMgt',
      'BSBA-HRM',
      'BSBA-FinMgt',
      'MBA',
      'DBA',
    ],
    'College of Education, Arts, and Sciences (CEAS)': [
      'BEEd',
      'LLC-IEEP',
      'BSEd-ENG',
      'MPES',
      'BSPSY',
      'MAED-FIL',
      'MAED-EM',
      'MAED-ELE',
      'MAED-SPED',
      'EdD',
      'BPEd',
      'AB-PolSci',
      'AB',
      'ABComm',
      'AB-ELS',
      'CertProEd',
    ],
    'College of Architecture (COA)': ['BSEnvPln', 'BSArch'],
    'College of Tourism and Hospitality Management (CTHM)': ['BSTM', 'BSHM'],
    'College of Engineering (ENGG)': [
      'BSME',
      'BSEcE',
      'BSESE',
      'BSCE',
      'BSCpE',
      'MSCE',
      'MSCpE',
      'MSSE',
    ],
  };


  final List<String> yearLevelOptions = ['1st Year', '2nd Year', '3rd Year', '4th Year'];

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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 🔷 Custom Header + Back Button
            Stack(
              children: [
                CustomHeaderWithTitle(
                  userName: widget.userName,
                  title: "My Profile",
                ),
                Positioned(
                  left: 14.w,
                  top: 17.h,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),

            // 🔷 Main Profile Content (Scrollable)
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: GestureDetector(
                        onTap: () => _pickAndUploadImage(context),
                        child: CircleAvatar(
                          radius: 50.r,
                          backgroundImage: (user?['profileImage'] != null)
                              ? MemoryImage(base64Decode(user!['profileImage']))
                              : const AssetImage('assets/profile_image.png') as ImageProvider,
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    _buildTextField("Student ID", studentIdController, enabled: false),
                    _buildTextField("Email", emailController, enabled: false),
                    _buildTextField("First Name", firstNameController),
                    _buildTextField("Middle Name", middleNameController),
                    _buildTextField("Last Name", lastNameController),

                    buildSingleProgramDropdown(),

                    if (!isSelectingCollege)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          icon: const Icon(Icons.arrow_back),
                          label: const Text("Back to Colleges"),
                          onPressed: () {
                            setState(() {
                              isSelectingCollege = true;
                              selectedProgram = null;
                            });
                          },
                        ),
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

                          IconSnackBar.show(
                            context: context,
                            snackBarType: SnackBarType.success,
                            label: 'Profile updated!',
                          );

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  MenuScreen(userName: widget.userName),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2D3A8C),
                          padding: EdgeInsets.symmetric(
                            vertical: 12.h,
                            horizontal: 40.w,
                          ),
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

        CustomFooterWithNav(
        userName: widget.userName, activeTab: 'menu',
        ),
        ],

        ),
      ),

    );
  }

  Widget buildSingleProgramDropdown() {
    final List<String> dropdownOptions = isSelectingCollege
        ? collegePrograms.keys.toList()
        : collegePrograms[selectedCollege!] ?? [];

    // Validate the selected value
    final String? currentValue = isSelectingCollege
        ? (dropdownOptions.contains(selectedCollege) ? selectedCollege : null)
        : (dropdownOptions.contains(selectedProgram) ? selectedProgram : null);

    return InputDecorator(
      decoration: InputDecoration(
        labelText: isSelectingCollege ? 'College' : 'Program',
        border: const OutlineInputBorder(),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentValue,
          isExpanded: true,
          hint: Text(isSelectingCollege ? 'Select College' : 'Select Program'),
          items: dropdownOptions.map((option) {
            return DropdownMenuItem<String>(
              value: option,
              child: Text(option),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              if (isSelectingCollege) {
                selectedCollege = value;
                selectedProgram = null;
                isSelectingCollege = false;
              } else {
                selectedProgram = value;
              }
            });
          },
        ),
      ),
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




}
