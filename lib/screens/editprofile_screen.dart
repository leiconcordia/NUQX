import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import 'menu_screen.dart';
import '../widgets/custom_header_with_title.dart';
import '../widgets/custom_footer.dart';
import '../widgets/main_scaffold.dart';
import 'package:flutter_application_1/utils/icon_snackbar.dart';
import 'package:flutter_application_1/DBHelper/mongodb.dart';

class ProfileEditScreen extends StatefulWidget {
  final String userName;

  const ProfileEditScreen({super.key, required this.userName});

  @override
  _ProfileEditScreenState createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  Map<String, dynamic>? user;
  ImageProvider? profileImageProvider;

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

  final List<String> yearLevelOptions = [
    '1st Year',
    '2nd Year',
    '3rd Year',
    '4th Year',
  ];

  final TextEditingController studentIdController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController middleNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  /// Fetch user data and cache profile image to prevent blinking
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

        selectedProgram = user!['program']?.toString().trim();

        selectedCollege = collegePrograms.entries
            .firstWhere(
              (entry) => entry.value.contains(selectedProgram),
          orElse: () => MapEntry('', []),
        )
            .key;

        if (selectedCollege == '') {
          selectedCollege = null;
          selectedProgram = null;
          isSelectingCollege = true;
        } else {
          isSelectingCollege = false;
        }

        selectedYearLevel = yearLevelOptions.contains(
            user!['yearLevel']?.toString().trim())
            ? user!['yearLevel'].toString().trim()
            : null;

        // Cache the profile image
        if (user?['profileImage'] != null) {
          profileImageProvider =
              MemoryImage(base64Decode(user!['profileImage']));
        } else {
          profileImageProvider =
          const AssetImage('assets/profile_image.png');
        }
      });
    }
  }

  /// Detect if data was changed
  bool get isChanged {
    if (user == null) return false;

    return studentIdController.text.trim() != (user!['studentID'] ?? '').trim() ||
        emailController.text.trim() != (user!['email'] ?? '').trim() ||
        firstNameController.text.trim() != (user!['firstName'] ?? '').trim() ||
        middleNameController.text.trim() != (user!['middleName'] ?? '').trim() ||
        lastNameController.text.trim() != (user!['lastName'] ?? '').trim() ||
        selectedProgram != (user!['program']?.toString().trim()) ||
        selectedYearLevel != (user!['yearLevel']?.toString().trim());
  }


  /// Pick image and upload to MongoDB
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

  Future<void> _handleImageSelection(
      XFile? image, BuildContext context) async {
    if (image != null) {
      final bytes = await image.readAsBytes();
      final base64Image = base64Encode(bytes);

      await MongoDatabase.setProfileImage(widget.userName, base64Image);

      // Update cache
      setState(() {
        profileImageProvider = MemoryImage(bytes);
      });

      // Show success snackbar
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
            // 🔷 Header
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
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                              MainScaffold(
                                userName: widget.userName,
                                initialTabIndex: 2,
                              ),
                          transitionsBuilder: (context, animation,
                              secondaryAnimation, child) {
                            const begin = Offset(-1.0, 0.0);
                            const end = Offset.zero;
                            const curve = Curves.easeInOut;

                            var tween = Tween(begin: begin, end: end)
                                .chain(CurveTween(curve: curve));

                            return SlideTransition(
                              position: animation.drive(tween),
                              child: child,
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            // 🔷 Main Profile Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ✅ Profile Avatar - Doesn't rebuild unnecessarily
                    Center(
                      child: GestureDetector(
                        onTap: () => _pickAndUploadImage(context),
                        child: CircleAvatarSection(
                          profileImage: profileImageProvider,
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Form Fields
                    _buildTextField("Student ID", studentIdController,
                        enabled: false),
                    _buildTextField("Email", emailController, enabled: false),
                    _buildTextField("First Name", firstNameController),
                    _buildTextField("Middle Name", middleNameController),
                    _buildTextField("Last Name", lastNameController),

                    buildSingleProgramDropdown(),

                    if (!isSelectingCollege)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          icon: const Icon(Icons.arrow_back,
                              color: Color(0xFF2D3A8C)),
                          label: const Text(
                            "Back to Colleges",
                            style: TextStyle(color: Color(0xFF2D3A8C)),
                          ),
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

                    // Save Button
                    Center(
                      child: ElevatedButton(
                        onPressed: isChanged
                            ? () async {
                          await MongoDatabase.updateUserByEmail(
                            emailController.text.trim(),
                            firstNameController.text.trim(),
                            middleNameController.text.trim(),
                            lastNameController.text.trim(),
                            selectedProgram!.trim(),
                            selectedYearLevel!.trim(),
                          );

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MainScaffold(
                                userName: widget.userName,
                                initialTabIndex: 2,
                              ),
                            ),
                          );
                        }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2D3A8C),
                          padding: EdgeInsets.symmetric(
                            vertical: 12.h,
                            horizontal: 40.w,
                          ),
                        ),
                        child: Text(
                          "Save",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomFooter(),
    );
  }

  /// Dropdown for College and Programs
  Widget buildSingleProgramDropdown() {
    final List<String> dropdownOptions = isSelectingCollege
        ? collegePrograms.keys.toList()
        : collegePrograms[selectedCollege!] ?? [];

    final String? currentValue = isSelectingCollege
        ? (dropdownOptions.contains(selectedCollege) ? selectedCollege : null)
        : (dropdownOptions.contains(selectedProgram) ? selectedProgram : null);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: InputDecorator(
        decoration: _inputDecoration(
            label: isSelectingCollege ? 'College' : 'Program'),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: currentValue,
            isExpanded: true,
            hint: Text(
                isSelectingCollege ? 'Select College' : 'Select Program'),
            dropdownColor: Colors.white,
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
        decoration: _inputDecoration(label: label),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: selectedValue,
            hint: Text(hintText),
            isExpanded: true,
            dropdownColor: Colors.white,
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
      child: Theme(
        data: Theme.of(context).copyWith(
          textSelectionTheme: const TextSelectionThemeData(
            cursorColor: Color(0xFF2D3A8C),
            selectionColor: Color(0x332D3A8C),
            selectionHandleColor: Color(0xFF2D3A8C),
          ),
        ),
        child: TextField(
          controller: controller,
          enabled: enabled,
          onChanged: (_) {
            setState(() {}); // 🔹 Triggers rebuild so isChanged is recalculated
          },
          decoration: _inputDecoration(label: label),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({required String label}) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      labelText: label,
      contentPadding:
      EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24.r),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24.r),
        borderSide: const BorderSide(color: Color.fromARGB(255, 103, 103, 103)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24.r),
        borderSide: const BorderSide(color: Color(0xFF2D3A8C), width: 2),
      ),
    );
  }
}

/// Separate widget for the profile picture to prevent unnecessary rebuilds
class CircleAvatarSection extends StatelessWidget {
  final ImageProvider? profileImage;

  const CircleAvatarSection({super.key, required this.profileImage});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage: profileImage,
        ),
        Positioned(
          bottom: 0,
          right: 4,
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: const Color(0xFF2D3A8C),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Icon(Icons.camera_alt, size: 15, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
