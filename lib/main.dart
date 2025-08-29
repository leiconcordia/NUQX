import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/DBHelper/mongodb.dart';
import 'package:flutter_application_1/services/socket_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_application_1/screens/signup_screen.dart';
import 'package:flutter_application_1/screens/login_screen.dart';
import '../widgets/main_scaffold.dart';
import 'package:flutter_application_1/screens/location_screen.dart';
import 'package:flutter_application_1/screens/home_screen.dart';
import 'package:flutter_application_1/services/icon_service.dart';
import 'package:mongo_dart/mongo_dart.dart' hide Center;

import 'dart:ui' as ui;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';


// 👇 this class overrides SSL checks
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true; // accept all certs
  }
}

// ✅ Global WebSocket channel (connect to your backend server)
//late WebSocketChannel channel;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Connect to MongoDB (only if using locally)
  await MongoDatabase.connect();

  HttpOverrides.global = MyHttpOverrides(); // disables SSL cert checks

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
     // return HomeScreen(userName: userName);
      return HomeScreen(userName: "leiconcordia2005@gmail.com");
    } else {
      //return const LoginScreen();
      return HomeScreen(userName: "leiconcordia2005@gmail.com");
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
                return  Scaffold(
                  body: Center(child: CircularProgressIndicator()), // ✅ Fixed center
                );
              } else {
                return snapshot.data!;
              }
            },
          ),
          routes: {
            '/login': (context) => const LoginScreen(),
            '/signup': (context) => const SignUpScreen(),
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
