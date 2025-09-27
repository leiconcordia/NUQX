import 'dart:developer';
import 'dart:io';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:flutter_application_1/DBHelper/constant.dart';

class MongoDatabase {
  static late Db db;
  static late DbCollection userCollection;
  static late DbCollection queueNumbersCollection;
  static late DbCollection transactionCollection;
  static late DbCollection countersCollection;
  static late DbCollection notificationCollection;




  static Future<void> connect() async {
    try {


      db = await Db.create(MONGO_CONN_URL);
      await db.open();
      inspect(db);
      userCollection = db.collection(USER_COLLECTION);
      queueNumbersCollection = db.collection(QUEUE_NUMBERS);
      transactionCollection = db.collection(TRANSACTIONS);
      countersCollection = db.collection(COUNTERS);
      notificationCollection = db.collection(NOTIFICATION);
      print('✅ Connected to MongoDB');
      print('🟡 DB state: ${db.state}');
      print('🟡 Connected: ${db.isConnected}');

      userCollection = db.collection(USER_COLLECTION);


    } catch (e) {
      print("❌ Error connecting to MongoDB: $e");
    }
  }




//signin
  static Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    try {
      if (!db.isConnected) {
        print("🔄 Reconnecting to MongoDB...");
        await db.open(); // Reopen if disconnected
      }
      final user = await userCollection.findOne({'email': email});

      if (user != null) {
        print("✅ User found: $user");
      } else {
        print("❌ User not found");
      }
      return user;
    } catch (e) {
      print("❌ Error fetching user: $e");
      return null;
    }
  }

//Signup
  static Future<void> insertUser(Map<String, dynamic> userData) async {
    try {
      if (!db.isConnected) {
        print("🔄 Reconnecting to MongoDB...");
        await db.open(); // Reopen if disconnected
      }

      print("🟡 DB state: ${db.state}");
      print("🟡 Connected: ${db.isConnected}");
      print("🟡 Inserting: $userData");

      await userCollection.insertOne(userData);
      print("✅ User inserted successfully");
    } catch (e) {
      print("❌ Failed to insert user: $e");
    }
  }


//ID VALIDATION DURING SIGNUP
  static Future<dynamic> getUserByStudentID(String studentID) async {

    final user = await userCollection.findOne({"studentID": studentID});
    return user;
  }

//FOR VALIDATION
  static Future<dynamic> getUserById(String id) async {
    final user = await userCollection.findOne({"_id": ObjectId.parse(id)});
    return user;
  }

//FOR UPDATE USER INFO
  static Future<void> updateUserByEmail(String email, String firstName,
      String middleName, String lastName, String program,
      String yearLevel) async {
    final result = await userCollection.updateOne(
      where.eq("email", email),
      modify
          .set("firstName", firstName)
          .set("middleName", middleName)
          .set("lastName", lastName)
          .set("program", program) // ✅ Fixed
          .set("yearLevel", yearLevel),
    );

    if (!result.isSuccess) {
      print('❌ Update failed');
    } else {
      print('✅ Update successful');
    }
  }

  static Future<void> verifyAccountByEmail(String email) async {
    await userCollection.updateOne(
      where.eq("email", email),
      modify.set("AccountStatus", "verified"),
    );
  }



  static Future<List<Map<String, dynamic>>> getTransactionsByDepartment(String department) async {
    final transactions = await transactionCollection
        .find({
      'department': department.toLowerCase(),
      'isHidden': false,
    })
        .toList();
    return transactions;
  }




  static Future<int> _getNextSequence(String department) async {
    if (!db.isConnected) {
      await db.open();
    }

    // Build the new ID format
    final counterId = "queueNumbers:$department";

    // Atomically increment the seq field and return the new value
    final result = await countersCollection.findAndModify(
      query: where.eq('_id', counterId),
      update: modify.inc('seq', 1),
      upsert: true,     // Create document if not found
      returnNew: true,  // Return updated document
    );

    return (result?['seq'] as int?) ?? 1;
  }





// Generate and insert queue document
  static Future<Map<String, dynamic>?> generateAndInsertQueueNumber(
      String transactionID,
      String transactionName,
      Map<String, dynamic> queueData) async {
    try {
      // 1. Find transaction
      final tx = await transactionCollection.findOne(
        where.eq('name', transactionName),
      );

      if (tx == null) throw Exception("Transaction not found.");
      final department = tx['department'] as String? ?? 'DEFAULT';

      // 2. Get the next sequence number
      final seq = await _getNextSequence(department);

      // 3. Build queue number
      final padded = seq.toString().padLeft(3, '0');
      final queueNumber = '$transactionID$padded -CS';

      // 4. Insert queue record
      queueData['generatedQueuenumber'] = queueNumber;
      queueData['department'] = department;
      queueData['createdAt'] = DateTime.now().toUtc();

      final result = await queueNumbersCollection.insertOne(queueData);

      if (result.isSuccess) {
        return {...queueData, '_id': result.id};
      } else {
        return null;
      }
    } catch (e) {
      print("❌ Failed to generate/insert queue: $e");
      return null;
    }
  }






  // static Future<String> generateQueueNumber(String transactionID, String transactionName) async {
  //   try {
  //     if (!db.isConnected) {
  //       print("🔄 Reconnecting to MongoDB...");
  //       await db.open();
  //     }
  //
  //     // Step 1: Check if IDReset is true
  //     final transaction = await transactionCollection.findOne(
  //       where.eq('name', transactionName),
  //     );
  //
  //     if (transaction == null) {
  //       print("❌ Transaction not found.");
  //       return '${transactionID}001';
  //     }
  //
  //     if (transaction['isIDReset'] == true) {
  //       await transactionCollection.update(
  //         where.eq('name', transactionName),
  //         modify.set('isIDReset', false),
  //       );
  //       print("🔁 Resetting queue to ${transactionID}001");
  //       return '${transactionID}001';
  //     }
  //
  //     // Step 2: Get latest queue with same transactionName, ordered by createdAt
  //     final cursor = queueNumbersCollection.find(
  //       where.eq('transactionName', transactionName).sortBy('createdAt', descending: true),
  //     );
  //     final latestQueueList = await cursor.toList();
  //
  //     if (latestQueueList.isEmpty) {
  //       print("📭 No previous queues found. Returning ${transactionID}001");
  //       return '${transactionID}001';
  //     }
  //
  //     final latestQueue = latestQueueList.first;
  //     final latestGenerated = latestQueue['generatedQueuenumber'] as String;
  //
  //     // Debug print to confirm we're extracting correctly
  //     print("🔢 Latest generated queue: $latestGenerated");
  //
  //     // Step 3: Remove prefix and convert numeric part
  //     final numericPart = latestGenerated
  //         .replaceFirst(transactionID, '')          // Remove prefix
  //         .replaceAll(RegExp(r'[^\d]'), '');        // Keep digits only
  //
  //     final latestNumber = int.tryParse(numericPart) ?? 0;
  //
  //
  //     final newNumber = latestNumber + 1;
  //     final paddedNumber = newNumber.toString().padLeft(3, '0');
  //
  //     final newQueueNumber = '$transactionID$paddedNumber -CS';
  //     print("✅ New queue number generated: $newQueueNumber");
  //
  //     return newQueueNumber;
  //   } catch (e) {
  //     print("❌ Failed to generate queue number: $e");
  //     return '${transactionID}001';
  //   }
  // }





  static Future<Map<String, dynamic>?> getQueueInfoByEmail(String email) async {
    try {
      if (!db.isConnected) {
        print("🔄 Reconnecting to MongoDB...");
        await db.open(); // Reopen if disconnected
      }
      final result = await queueNumbersCollection.findOne(
        where
            .eq('user', email)
            .eq('status', 'Waiting')
            .sortBy('createdAt', descending: true),
      );

      if (result != null) {
        print("✅ Waiting queue found for $email");
      } else {
        print("❌ No waiting queue found for $email");
      }

      return result;
    } catch (e) {
      print("❌ Error fetching waiting queue info: $e");
      return null;
    }
  }



  static Future<bool> hasActiveQueue(String email) async {
    try {
      if (!db.isConnected) {
        print("🔄 Reconnecting to MongoDB...");
        await db.open(); // Reopen if disconnected
      }
      final activeQueue = await queueNumbersCollection.findOne({
        'user': email,
        'status': {'\$in': ['Waiting', 'Processing']},
      });

      return activeQueue != null; // true if active queue exists
    } catch (e) {
      print('❌ Error checking active queue: $e');
      return false; // assume no active queue on error
    }
  }






  static Future<String?> getNowServingForUser(String userName) async {
    try {
      // 1. Find user's waiting queue
      final userQueue = await queueNumbersCollection.findOne(
        where.eq('user', userName).eq('status', 'Waiting'),
      );

      if (userQueue == null) {
        print("❌ No waiting queue found for user: $userName");
        return null;
      }

      final String transactionName = userQueue['transactionName'];
      final String department = userQueue['department'];

      // 2. Find latest processing queue in the same department (by updatedAt)
      final cursor = queueNumbersCollection.find(
        where.eq('department', department).eq('status', 'Processing').sortBy('updatedAt', descending: true),
      );

      final processingList = await cursor.toList();
      final latestProcessing = processingList.isNotEmpty ? processingList.first : null;

      if (latestProcessing != null) {
        final queueNum = latestProcessing['generatedQueuenumber'];
        print("✅ Now serving for $transactionName in $department: $queueNum");
        return queueNum;
      } else {
        print("ℹ️ No processing queue found for $transactionName in $department");
        return null;
      }
    } catch (e) {
      print("❌ Error in getNowServingForUser: $e");
      return null;
    }
  }


  // static Future<List<String>> getAllNowServingForUser(String userName) async {
  //   try {
  //     if (!db.isConnected) {
  //       print("🔄 Reconnecting to MongoDB...");
  //       await db.open(); // Reopen if disconnected
  //     }
  //     // 1. Find user's waiting queue
  //     final userQueue = await queueNumbersCollection.findOne(
  //       where.eq('user', userName).eq('status', 'Waiting'),
  //     );
  //
  //     if (userQueue == null) {
  //       print("❌ No waiting queue found for user: $userName");
  //       return [];
  //     }
  //
  //
  //     final String department = userQueue['department'];
  //
  //     // 2. Find all processing queues for the same department
  //     final processingQueues = await queueNumbersCollection.find(
  //       where
  //           .eq('department', department)
  //           .eq('status', 'Processing'),
  //     ).toList();
  //
  //     if (processingQueues.isNotEmpty) {
  //       final queueNumbers = processingQueues
  //           .map((q) => q['generatedQueuenumber'].toString())
  //           .toList();
  //
  //       print("✅ Now serving in $department: $queueNumbers");
  //       return queueNumbers;
  //     } else {
  //       print("ℹ️ No processing queues found in $department");
  //       return [];
  //     }
  //   } catch (e) {
  //     print("❌ Error in getAllNowServingForUser: $e");
  //     return [];
  //   }
  // }



  static Future<Map<String, dynamic>> getQueueWaitInfo(String email) async {
    try {
      if (!db.isConnected) {
        print("🔄 Reconnecting to MongoDB...");
        await db.open(); // Reopen if disconnected
      }

      // Step 1: Get user's active waiting queue
      final userQueue = await queueNumbersCollection.findOne(
        where.eq('user', email).eq('status', 'Waiting'),
      );

      if (userQueue == null) {
        print("❌ No active waiting queue found for this user.");
        return {
          "peopleInWaiting": 0,
          "approxWaitTime": "0 min",
        };
      }

      // ✅ Extract values
      final String transactionName = userQueue['transactionName'];
      final String department = userQueue['department'];

      // Step 2: Get completed queues filtered by transactionName
      final completedQueues = await queueNumbersCollection.find({
        'status': 'Completed',
        'transactionName': transactionName, // 👈 filter only here
        'processingTime': {'\$exists': true}
      }).toList();

      // Step 3: Calculate average processing time (in seconds)
      double averageProcessingSeconds = 300; // default = 5 mins
      if (completedQueues.isNotEmpty) {
        final totalSeconds = completedQueues
            .map((e) => (e['processingTime'] as num?) ?? 0)
            .reduce((a, b) => a + b);
        averageProcessingSeconds = totalSeconds / completedQueues.length;
      }

      // Step 4: Get waiting users in the same department (no transaction filter)
      final departmentWaiting = await queueNumbersCollection
          .find(where
          .eq('status', 'Waiting')
          .eq('department', department)
          .sortBy('createdAt'))
          .toList();

      final userIndex =
      departmentWaiting.indexWhere((doc) => doc['_id'] == userQueue['_id']);
      final othersWaitingAhead = userIndex == -1 ? 0 : userIndex;

      // Step 5: Calculate estimated wait time
      final totalWaitSeconds = othersWaitingAhead * averageProcessingSeconds;
      final hours = totalWaitSeconds ~/ 3600;
      final minutes = (totalWaitSeconds % 3600) ~/ 60;

      String waitTimeFormatted = hours > 0
          ? "$hours hr${hours > 1 ? 's' : ''} ${minutes} min"
          : "$minutes min";

      return {
        "peopleInWaiting": othersWaitingAhead,
        "approxWaitTime": waitTimeFormatted,
      };
    } catch (e) {
      print("❌ Error calculating queue wait info: $e");
      return {
        "peopleInWaiting": 0,
        "approxWaitTime": "5 min", // fallback
      };
    }
  }



  static Future<Map<String, dynamic>> getUserQueueStatus(String email) async {
    try {
      if (!db.isConnected) {
        print("🔄 Reconnecting to MongoDB...");
        await db.open(); // Reopen if disconnected
      }
      final userQueue = await queueNumbersCollection.findOne(
          where.eq('user', email).sortBy('createdAt', descending: true));


      if (userQueue != null && userQueue['status'] != null) {
        return {
          'status': userQueue['status'],
          'windowNumber': userQueue['windowNumber'] ?? '',
          'generatedQueuenumber' : userQueue['generatedQueuenumber'] ?? '',
          'queueNumber': userQueue['generatedQueuenumber'] ?? '',
        };
      } else {
        return {
          'status': ''
              ' found',
          'windowNumber': '',
        };
      }
    } catch (e) {
      print("❌ Error fetching user queue status: $e");
      return {
        'status': 'error',
        'windowNumber': '',
      };
    }
  }

  // Save base64 profile image to the user's document
  static Future<void> setProfileImage(String email, String base64Image) async {
    final collection = db.collection('users');
    await collection.updateOne(
      where.eq('email', email),
      modify.set('profileImage', base64Image),
    );
  }

  static Future<void> deleteAllNotificationsForUser(String username) async {
    try {
      final result = await notificationCollection.deleteMany({
        'user': username, // Delete all notifications for this user
      });

    } catch (e) {
      print("❌ Error deleting notifications for $username: $e");
    }
  }


  static Future<List<Map<String, dynamic>>> getUserNotifications(String username) async {
    try {
      final notifications = await notificationCollection
          .find(
        where
            .eq('user', username)
            .sortBy('createdAt', descending: true), // ✅ Sort newest first
      )
          .toList(); // Convert stream to list

      print("✅ Found ${notifications.length} notifications for $username");

      return notifications.cast<Map<String, dynamic>>();
    } catch (e) {
      print("❌ Error fetching notifications: $e");
      return [];
    }
  }

  static Future<void> markAsRead(String id) async {
    try {
      await notificationCollection.updateOne(
        where.id(ObjectId.parse(id)),
        modify.set('readAt', DateTime.now().toUtc()),
      );
      print("✅ Notification $id marked as read");
    } catch (e) {
      print("❌ Error marking as read: $e");
    }
  }




  static Future<void> pushNotification({
    required String user,
    required String title,
    required String message,
  }) async {
    try {
      final doc = {
        'user': user,
        'title': title,
        'message': message,
        'type': 'userNotification',
        'createdAt': DateTime.now().toUtc(),
        'readAt' : null,
      };

      // Use insertOne to insert exactly one document
      final result = await notificationCollection.insertOne(doc);

      if (result.isSuccess) {
        print("✅ Notification saved successfully for $user");
      } else {
        print("❌ Failed to insert notification for $user");
      }
    } catch (e) {
      print("❌ Error pushing notification: $e");
    }
  }

  // Get the number of unread notifications for a user
  static Future<int> getUnreadNotificationCount(String user) async {
    try {
      final col = notificationCollection; // your notifications collection
      final count = await col.count({
        "user": user,
        "readAt": null,
      });
      return count;
    } catch (e) {
      print("❌ Error counting unread notifications: $e");
      return 0;
    }
  }

  // Mark all unread notifications as read for a specific user
  static Future<void> markNotificationsAsRead(String user) async {
    try {
      final col = notificationCollection;

      final now = DateTime.now().toUtc();

      final result = await col.updateMany(
        {'user': user, 'readAt': null},
        {
          '\$set': {'readAt': now},
        },
      );


    } catch (e) {
      print('❌ Error marking notifications as read: $e');
    }
  }


  static Future<Map<String, dynamic>?> getLatestTransferRecord(String queueNumber) async {
    try {
      final results = await queueNumbersCollection.find({
        "generatedQueuenumber": queueNumber,
        "isTransferred": true,
      }).toList();

      if (results.isEmpty) {
        return null; // No transfer found
      }

      // Sort by createdAt DESC
      results.sort((a, b) {
        final aTime = DateTime.parse(a['createdAt'].toString());
        final bTime = DateTime.parse(b['createdAt'].toString());
        return bTime.compareTo(aTime);
      });

      return results.first; // Latest transfer record
    } catch (e) {
      print("❌ Error fetching latest transfer record: $e");
      return null;
    }
  }


  static Future<String?> getLatestTransferNotification(String queueNumber) async {
    try {
      final results = await notificationCollection.find({
        "queueNumber": queueNumber,
        "type": "transfer",
      }).toList();

      if (results.isEmpty) {
        print("ℹ️ No transfer notifications for $queueNumber");
        return null;
      }

      // Sort by createdAt DESC
      results.sort((a, b) {
        final aTime = DateTime.parse(a['createdAt'].toString());
        final bTime = DateTime.parse(b['createdAt'].toString());
        return bTime.compareTo(aTime);
      });

      return results.first['message'] ?? "Transferred";
    } catch (e) {
      print("❌ Error fetching transfer notification: $e");
      return null;
    }
  }







}











