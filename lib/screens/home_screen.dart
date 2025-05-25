import 'package:flutter/material.dart';
import 'package:flutter_application_1/DBHelper/mongodb.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/custom_footer_with_nav.dart';
import '../widgets/custom_header_with_logo.dart';
import 'admission_screen.dart';
import 'accounting_screen.dart';
import 'registrar_screen.dart';
import 'other_concern_form_screen.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = "/home";
  final String userName; // This is actually the email

  const HomeScreen({super.key, required this.userName});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? user;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      final fetchedUser = await MongoDatabase.getUserByEmail(widget.userName);
      setState(() {
        user = fetchedUser;
      });

      if (fetchedUser == null) {
        // Optional: Handle case where user wasn't found
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not found')),
        );
      }
    } catch (e) {
      setState(() {
        user = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching user: $e')),
      );
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
      backgroundColor: Colors.white, // Ensure white background
      body: SafeArea(
        child: Column(
          children: [
            CustomHeaderWithLogo(userName: user!['firstName']),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 55.h),

                      // Bigger and blue text
                      Text(
                        "Hi, ${user!['firstName']}!",
                        style: TextStyle(
                          fontSize: 40.sp, // Increased size
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2D3A8C), // Fully blue
                        ),
                      ),
                      Text(
                        "Welcome to NUQX.",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 22.sp, // Slightly bigger
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2D3A8C), // Fully blue
                        ),
                      ),
                      SizedBox(height: 40.h),

                      // Grid of Options
                      GridView(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16.w,
                          mainAxisSpacing: 16.h,
                          childAspectRatio: 1,
                        ),
                        children: [
                          _buildCategoryTile(
                            title: "Admission",
                            icon: Icons.school_outlined, // Changed icon
                            onTap:
                                () => _navigateToScreen(
                                  context,
                                  AdmissionScreen(userName: widget.userName),
                                ),
                          ),
                          _buildCategoryTile(
                            title: "Accounting",
                            icon: Icons.credit_card,
                            onTap: () {
                              try {
                                _navigateToScreen(
                                  context,
                                  AccountingScreen(userName: widget.userName),
                                );
                              } catch (e, stackTrace) {
                                debugPrint('Navigation Error: $e');
                                debugPrint('StackTrace: $stackTrace');
                              }
                            },
                          ),

                          _buildCategoryTile(
                            title: "Registrar",
                            icon: Icons.create_outlined, // Changed icon
                            onTap:
                                () => _navigateToScreen(
                                  context,
                                  RegistrarScreen(userName: widget.userName),
                                ),
                          ),
                          _buildCategoryTile(
                            title: "Other Concern",
                            icon: Icons.question_mark_outlined, // Changed icon
                            onTap:
                                () => _navigateToScreen(
                                  context,
                                  OtherConcernFormScreen(userName: widget.userName),
                                ),
                          ),
                        ],
                      ),

                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ),
            ),

            CustomFooterWithNav(
              userName: widget.userName,
              activeTab: 'home', // Tell footer you're on Form tab
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToScreen(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionDuration: Duration.zero, // Instantly switch screens
        reverseTransitionDuration: Duration.zero,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return child; // No animation
        },
      ),
    );
  }

  Widget _buildCategoryTile({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2D3A8C),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 50.sp),
            SizedBox(height: 8.h),
            Text(
              title,
              style: TextStyle(color: Colors.white, fontSize: 18.sp),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
