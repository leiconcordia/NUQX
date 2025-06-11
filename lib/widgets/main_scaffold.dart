
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
  const MainScaffold({super.key, required this.userName});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeScreen(userName: widget.userName),
      TrackerScreen(userName: widget.userName),
      MenuScreen(userName: widget.userName),
      // ProfileEditScreen(userName: widget.userName),
      // AdmissionScreen(userName: widget.userName),
      // AccountingScreen(userName: widget.userName),
      // ConfirmationTicketScreen( userName: widget.userName,
      //   transactionConcern: 'Sample Concern',
      //   transactionID: 'TEMP123',
      //   department: 'Sample Department',
      //   TransactionAdmin: 'sample@admin.com')

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

