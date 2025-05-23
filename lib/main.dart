import 'package:flutter/material.dart';
import 'package:flutter_application_1/DBHelper/mongodb.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_application_1/screens/signup_screen.dart';
import 'package:flutter_application_1/screens/login_screen.dart';
import 'package:flutter_application_1/screens/location_screen.dart';

import 'package:mongo_dart/mongo_dart.dart';
import 'dart:ui' as ui;


void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    await MongoDatabase.connect();
    runApp(MyApp());


}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const ui.Size(375, 812),

      minTextAdapt: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'NUQX Mobile System',
          theme: ThemeData(
            primaryColor: const Color(0xFF2D3A8C),
            fontFamily: 'Poppins', // Set global font to Poppins
          ),
          initialRoute: '/signup', // Set Location Screen as the first page
          routes: {
            '/login': (context) => const LoginScreen(),
            '/signup': (context) => const SignUpScreen(),
            '/location': (context) => const LocationScreen(),

          },
        );
      },
    );
  }
}
