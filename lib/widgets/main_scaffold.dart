
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_application_1/screens/home_screen.dart';
import 'package:flutter_application_1/screens/menu_screen.dart';
import 'package:flutter_application_1/screens/tracker_screen.dart';
// import 'package:flutter_application_1/screens/editprofile_screen.dart';
// import 'package:flutter_application_1/screens/admission_screen.dart';
// import 'package:flutter_application_1/screens/accounting_screen.dart';
// import 'package:flutter_application_1/screens/confirmationticket_screen.dart';


import 'package:flutter_application_1/widgets/custom_footer_with_nav.dart';




class MainScaffold extends StatefulWidget {
  final String userName;
  final int initialTabIndex;

  const MainScaffold({
    super.key,
    required this.userName,
    this.initialTabIndex = 0, // default to 0 if not provided
  });

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  late int currentIndex;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialTabIndex;

    _screens = [
      HomeScreen(userName: widget.userName),
      TrackerScreen(userName: widget.userName),
      MenuScreen(userName: widget.userName),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: CustomFooterWithNav(
        currentIndex: currentIndex,
        onTabSelected: (index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }
}


