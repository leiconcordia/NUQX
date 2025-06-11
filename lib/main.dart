import 'package:flutter/material.dart';
import 'package:flutter_application_1/DBHelper/mongodb.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_application_1/screens/signup_screen.dart';
import 'package:flutter_application_1/screens/login_screen.dart';
import 'package:flutter_application_1/screens/location_screen.dart';
import 'package:flutter_application_1/screens/home_screen.dart';
import 'package:flutter_application_1/services/icon_service.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'dart:ui' as ui;
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MongoDatabase.connect();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Function to check login state
  Future<Widget> _getInitialScreen() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final userName = prefs.getString('userName') ?? '';

    if (isLoggedIn && userName.isNotEmpty) {
      return LocationScreen(userName: userName);
    } else {
      return const LoginScreen();
    }
  }

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
            fontFamily: 'Poppins',
          ),
          home: FutureBuilder<Widget>(
            future: _getInitialScreen(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Scaffold(
                  body: CircularProgressIndicator(),  // Removed Center widget here
                );
              }
              else {
                return snapshot.data!;
              }
            },
          ),

          routes: {
            '/login': (context) => const LoginScreen(),
            '/signup': (context) => const SignUpScreen(),
            //'/homescreen': (context) => const HomeScreen(userName: 'leiconcordia2005@gmail.com'),
          },
        );
      },
    );
  }
}

// void main() async {
//     WidgetsFlutterBinding.ensureInitialized();
//     await MongoDatabase.connect();
//     //await IconService.initialize();
//     runApp(MyApp());
//
//
// }
//
// class MyApp extends StatelessWidget {
//
//   const MyApp({super.key});
//
//
//   // Function to check login state
//   Future<Widget> _getInitialScreen() async {
//     final prefs = await SharedPreferences.getInstance();
//     final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
//     final userName = prefs.getString('userName') ?? '';
//
//     if (isLoggedIn && userName.isNotEmpty) {
//       return LocationScreen(userName: userName);
//     } else {
//       return const LoginScreen();
//     }
//   }
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     return ScreenUtilInit(
//       designSize: const ui.Size(375, 812),
//
//       minTextAdapt: true,
//       builder: (context, child) {
//         return MaterialApp(
//           debugShowCheckedModeBanner: false,
//           title: 'NUQX Mobile System',
//           theme: ThemeData(
//             primaryColor: const Color(0xFF2D3A8C),
//             fontFamily: 'Poppins', // Set global font to Poppins
//           ),
//           initialRoute: '/login', // Set Location Screen as the first page
//           routes: {
//             '/login': (context) => const LoginScreen(),
//             '/signup': (context) => const SignUpScreen(),
//             //'/location': (context) => const LocationScreen(userName: '',),
//             //'/homescreen': (context) => const HomeScreen(userName: 'leiconcordia2005@gmail.com'),
//
//           },
//         );
//       },
//     );
//   }
// }
