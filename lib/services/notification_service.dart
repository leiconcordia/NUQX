import 'dart:async';
import 'dart:io';
import 'package:flutter_application_1/DBHelper/mongodb.dart';
import '../services/socket_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static String? _lastQueueStatus;
 // static int? _lastPeopleInWaiting;
  static String? _lastWindowNumber;
  static int? _lastPeopleInWaiting;

  static String? _lastNotificationId;
  static Timer? _timer;
  static String? _lastFetchedMongoNotifId; // For polling MongoDB
  static String? _lastGeneratedQueueNotifKey; // For queue status notifications
  late final SocketService socket;

  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  /// Initialize notifications and WebSocket
  static Future<void> init(String userName) async {
    if (_initialized) return;

    // Android & iOS initialization
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings();

    const InitializationSettings initSettings =
    InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (payload) {
        print('Notification clicked: $payload');
      },
    );

    // Request permissions
    if (Platform.isAndroid) {
      final androidImpl = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      await androidImpl?.requestNotificationsPermission();
    }

    if (Platform.isIOS) {
      final iosImpl = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      await iosImpl?.requestPermissions(alert: true, badge: true, sound: true);
    }

    print("🔔 NotificationService initialized");
    _initialized = true;

    // Connect to WebSocket
    final socket = SocketService();
    socket.connect();

    // 4️⃣ Join user-specific room
    socket.joinUser(userName);

    // Listen for WebSocket notifications
    socket.on("notification", (data) {
      print("📩 naka dawat received via WebSocket: $data");
      //showLocalNotification(data['title'] ?? "Notification", data['message'] ?? "");
    });
  }

  /// Show local notification with stacking/grouping support
  static Future<void> showLocalNotification(String title, String body) async {
    const String groupKey = 'com.example.queue.NOTIFICATION_GROUP'; // Unique group key
    const String groupChannelId = 'queue_channel_id';
    const String groupChannelName = 'Queue Updates';
    const String groupChannelDescription = 'Notifications for queue updates';

    // Individual notification
    final AndroidNotificationDetails individualNotification = AndroidNotificationDetails(
      groupChannelId,
      groupChannelName,
      channelDescription: groupChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      groupKey: groupKey, // 👈 This is critical for stacking
    );

    // Summary notification (appears as group header when multiple are shown)
    final AndroidNotificationDetails summaryNotification = AndroidNotificationDetails(
      groupChannelId,
      groupChannelName,
      channelDescription: groupChannelDescription,
      styleInformation: const InboxStyleInformation(
        [], // Dynamic content is auto-added by Android
        contentTitle: 'Queue Updates',
        summaryText: 'You have new notifications',
      ),
      groupKey: groupKey,
      setAsGroupSummary: true, // 👈 Required to show as the expandable group summary
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: individualNotification,
    );

    // Use a random ID so each notification is separate
    final int notificationId = DateTime.now().millisecondsSinceEpoch.remainder(100000);

    // Show individual notification
    await _flutterLocalNotificationsPlugin.show(notificationId, title, body, notificationDetails);

    // Show group summary (this creates the expand arrow UI)
    await _flutterLocalNotificationsPlugin.show(
      0, // Always ID 0 for summary
      'Queue Updates',
      'You have new notifications',
      NotificationDetails(android: summaryNotification),
    );

    print("📢 Local Notification Stacked: $title - $body");
  }


  /// Start polling MongoDB for queue updates
  static void startListening(String username) {
    _timer?.cancel();
    print("🔔 NotificationService started for $username");

    _timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      await checkNotifications(username);
     // Existing queue polling
     // await checkWebNotifications(username);  // for transfer notifications
    });

  }

  /// Stop polling
  static void stopListening() {
    _timer?.cancel();
    _timer = null;
    print("🛑 NotificationService stopped.");
  }

  static Future<void> checkNotifications(String username) async {
    try {
      final result = await MongoDatabase.getQueueWaitInfo(username);
      final statusResult = await MongoDatabase.getUserQueueStatus(username);

      print("📡 Mongo result: $result");
      print("📡 Mongo statusResult: $statusResult");

      if (result == null || statusResult == null) return;

      final queueStatus = statusResult['status'];
      final windowNumber = statusResult['windowNumber'];
      final int peopleInWaiting = int.tryParse(result['peopleInWaiting'].toString()) ?? 0;
      final approxWaitTime = result['approxWaitTime'];

      print("🔹 Parsed peopleInWaiting: $peopleInWaiting");

      // Skip if NOTHING has changed
      if (_lastQueueStatus == queueStatus &&
          _lastWindowNumber == windowNumber &&
          _lastPeopleInWaiting == peopleInWaiting) {
        print("⏩ No changes detected. Skipping notification.");
        return;
      }

      // Update last known state
      _lastQueueStatus = queueStatus;
      _lastWindowNumber = windowNumber;
      _lastPeopleInWaiting = peopleInWaiting;

      await _sendNotificationIfNeeded(
        username: username,
        queueStatus: queueStatus,
        peopleInWaiting: peopleInWaiting,
        approxWaitTime: approxWaitTime,
        windowNumber: windowNumber,
      );
    } catch (e) {
      print("❌ Error while checking notifications: $e");
    }
  }




  static Future<void> _sendNotificationIfNeeded({
    required String username,
    required String queueStatus,
    required int peopleInWaiting,
    required String approxWaitTime,
    required String windowNumber,
  }) async {
    print("🔹 Checking notification logic: "
        "status=$queueStatus, waiting=$peopleInWaiting, window=$windowNumber");

    String? title;
    String? message;

    if (queueStatus == 'Processing') {
      title = "It's your turn!";
      message = "Please proceed to counter $windowNumber.";
    } else if (peopleInWaiting == 15) {
      title = "Waiting in line";
      message = "$peopleInWaiting people ahead of you.";
    } else if (peopleInWaiting == 10) {
      title = "Waiting in line";
      message = "$peopleInWaiting people ahead of you.";
    } else if (peopleInWaiting == 5) {
      title = "Waiting in line";
      message = "$peopleInWaiting people ahead of you.";
    } else if (peopleInWaiting == 1) {
      title = "Up next!";
      message = "You're next! Please proceed soon.";
    }



    if (title != null && message != null) {
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000; // seconds
      final notificationId = "$queueStatus|$peopleInWaiting|$windowNumber|$now";

      print("🔹 Generated notificationId: $notificationId");

      if (_lastNotificationId == notificationId) {
        print("⏩ Skipping duplicate notification: $notificationId");
        return;
      }

      _lastNotificationId = notificationId;

      print("📢 Sending notification -> $title: $message");

      await MongoDatabase.pushNotification(user: username, title: title, message: message);

      await showLocalNotification(title, message);

      final socket = SocketService();
      socket.emitWhenConnected("notification", {
        "title": title,
        "message": message,
        "queueNumber": windowNumber,
        "user": username,
        "readAt": null,
        "date": DateTime.now().toIso8601String(),
      });


    } else {
      print("⚠️ No matching condition found. No notification will be sent.");
    }
  }



  /// Reset state on logout
  static void resetState() {
    _lastQueueStatus = null;
    //_lastPeopleInWaiting = null;
    _lastWindowNumber = null;
    _lastNotificationId = null; // reset this too
    print("♻️ NotificationService state reset.");
  }

}
