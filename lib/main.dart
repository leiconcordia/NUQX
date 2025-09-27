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
import 'package:workmanager/workmanager.dart';
import 'package:flutter_application_1/services/notification_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Android & iOS settings
  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const DarwinInitializationSettings iosSettings =
      DarwinInitializationSettings();
  const InitializationSettings initSettings = InitializationSettings(
    android: androidSettings,
    iOS: iosSettings,
  );

  // Initialize local notifications plugin
  await flutterLocalNotificationsPlugin.initialize(
    initSettings,
    onDidReceiveNotificationResponse: (payload) {
      print('Notification clicked: $payload');
    },
  );

  // Connect to MongoDB and WebSocket
  await MongoDatabase.connect();
  SocketService().connect();

  // ✅ Get the logged-in user
  final prefs = await SharedPreferences.getInstance();
  final userName = prefs.getString('userName') ?? '';

  // Only initialize notifications if a user is logged in
  if (userName.isNotEmpty) {
    await NotificationService.init(userName);
    NotificationService.startListening(userName);
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Function to check login state
  Future<Widget> _getInitialScreen() async {
    // Connect to MongoDB (only if using locally)
    await MongoDatabase.connect();
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final userName = prefs.getString('userName') ?? '';

    if (isLoggedIn && userName.isNotEmpty) {
      //return LocationScreen(userName: userName);
      return LocationScreen(userName: "leiconcordia2005@gmail.com");
    } else {
      //return const LoginScreen();
      return LocationScreen(userName: "leiconcordia2005@gmail.com");
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

            scaffoldBackgroundColor: Colors.white,
            progressIndicatorTheme: const ProgressIndicatorThemeData(
              color: Color(0xFF2D3A8C),
            ),
          ),
          home: FutureBuilder<Widget>(
            future: _getInitialScreen(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Scaffold(
                  body: const Center(
                    child: CircularProgressIndicator(color: Color(0xFF2D3A8C)),
                  ),
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
