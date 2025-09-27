// import 'dart:async';
// import 'dart:io';
// import 'dart:ui';
// import 'package:flutter_background_service/flutter_background_service.dart';
// import 'package:flutter_background_service_android/flutter_background_service_android.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter_application_1/services/socket_service.dart';
// import 'package:flutter_application_1/services/notification_service.dart';
//
// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
// FlutterLocalNotificationsPlugin();
//
// class BackgroundService {
//   /// Initialize background service
//   Future<void> initializeService() async {
//     final service = FlutterBackgroundService();
//
//     await service.configure(
//       androidConfiguration: AndroidConfiguration(
//         onStart: onStart, // Must be annotated for AOT
//         autoStart: true,
//         autoStartOnBoot: true,
//         isForegroundMode: true,
//       ),
//       iosConfiguration: IosConfiguration(
//         autoStart: true,
//         onForeground: onStart,
//         onBackground: onIosBackground,
//       ),
//     );
//   }
//
//   /// iOS background support
//   @pragma('vm:entry-point')
//   static bool onIosBackground(ServiceInstance service) {
//     print("🔹 iOS background fetch triggered");
//     return true;
//   }
//
//   /// Main entry point for background service
//   @pragma('vm:entry-point')
//   static Future<void> onStart(ServiceInstance service) async {
//     // Required to initialize plugins in background isolate
//     DartPluginRegistrant.ensureInitialized();
//
//     /// 🔹 Step 1: Immediately start foreground notification
//     if (service is AndroidServiceInstance) {
//       await service.setForegroundNotificationInfo(
//         title: "NUQX Background Service",
//         content: "Listening for notifications...",
//       );
//       // This prevents Android from killing the service for not starting foreground
//     }
//
//     /// 🔹 Step 2: Initialize notifications once (singleton)
//     const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
//     const iosSettings = DarwinInitializationSettings();
//     const initSettings = InitializationSettings(android: androidSettings, iOS: iosSettings);
//     await flutterLocalNotificationsPlugin.initialize(initSettings);
//
//     /// 🔹 Step 3: Load logged-in username
//     final prefs = await SharedPreferences.getInstance();
//     final userName = prefs.getString('userName') ?? '';
//
//     if (userName.isEmpty) {
//       print("❌ No logged-in user found, stopping service.");
//       service.stopSelf();
//       return;
//     }
//
//     print("Background service started for user: $userName");
//
//     /// 🔹 Step 4: Connect to WebSocket (singleton)
//     final socketService = SocketService();
//     socketService.connect();
//     socketService.joinUser(userName);
//
//     /// 🔹 Step 5: Listen for server notifications
//     socketService.on("notification", (data) async {
//       print("📩 Background WebSocket notification: $data");
//       await NotificationService.showLocalNotification(
//           data['title'] ?? "Notification",
//           data['message'] ?? ""
//       );
//
//       /// 🔹 Step 6: Emit updates if needed
//       final notification = {
//         "title": data['title'] ?? "Notification",
//         "message": data['message'] ?? "",
//         "user": userName,
//         "readAt": null,
//         "date": DateTime.now().toIso8601String(),
//       };
//       socketService.emitWhenConnected("notification", notification);
//     });
//
//     /// 🔹 Step 7: Keep service alive with periodic heartbeat
//     Timer.periodic(const Duration(minutes: 1), (timer) {
//       print("⏳ Background service heartbeat at ${DateTime.now()}");
//     });
//   }
// }
