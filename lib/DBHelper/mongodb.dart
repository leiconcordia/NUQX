import 'dart:developer';

import 'package:mongo_dart/mongo_dart.dart';
import 'package:flutter_application_1/DBHelper/constant.dart';

class MongoDatabase {
  static late Db db;
  static late DbCollection userCollection;
  static late DbCollection queueNumbersCollection;
  static late DbCollection transactionCollection;




  static Future<void> connect() async {
    try {
      db = await Db.create(MONGO_CONN_URL);
      await db.open();
      inspect(db);
      userCollection = db.collection(USER_COLLECTION);
      queueNumbersCollection = db.collection(QUEUE_NUMBERS);
      transactionCollection = db.collection(TRANSACTIONS);
      userCollection = db.collection(USER_COLLECTION);

      print("✅ MongoDB connected!");
    } catch (e) {
      print("❌ Error connecting to MongoDB: $e");
    }
  }

//signin
  static Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    try {
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
        .find({'department': department.toLowerCase()})
        .toList();
    return transactions;
  }


  //Insert Queue in
  static Future<void> insertQueueNumber(Map<String, dynamic> QueueData) async {
    try {
      await   queueNumbersCollection.insertOne(QueueData);
      print("✅ Queue inserted successfully");
    } catch (e) {
      print("❌ Failed to insert Queue: $e");
    }
  }

  static Future<String> generateQueueNumber(String transactionID, String transactionName) async {
    try {
      final count = await queueNumbersCollection.count(
        where.eq('transactionName', transactionName),
      );

      final newNumber = count + 1;
      final paddedNumber = newNumber.toString().padLeft(3, '0'); // 001, 002, etc.
      return '$transactionID$paddedNumber'; // ENR006
    } catch (e) {
      print("❌ Failed to generate queue number: $e");
      return '${transactionID}001';

    }
  }

  static Future<Map<String, dynamic>?> getQueueInfoByEmail(String email) async {
    try {
      final result = await queueNumbersCollection.findOne(
        where
            .eq('user', email)
            .eq('status', 'waiting')
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
      final activeQueue = await queueNumbersCollection.findOne({
        'user': email,
        'status': {'\$in': ['waiting', 'processing']},
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
        where.eq('user', userName).eq('status', 'waiting'),
      );

      if (userQueue == null) {
        print("❌ No waiting queue found for user: $userName");
        return null;
      }

      final String transactionName = userQueue['transactionName'];
      final String department = userQueue['department'];

      // 2. Find processing queue for same transaction and department
      final processingQueue = await queueNumbersCollection.findOne(
        where
            .eq('transactionName', transactionName)
            .eq('department', department)
            .eq('status', 'processing'),
      );

      if (processingQueue != null) {
        final queueNum = processingQueue['generatedQueuenumber'];
        print("✅ Now serving for $transactionName: $queueNum");
        return queueNum;
      } else {
        print("ℹ️ No processing queue for $transactionName in $department");
        return null;
      }
    } catch (e) {
      print("❌ Error in getNowServingForUser: $e");
      return null;
    }
  }

  static Future<Map<String, dynamic>> getQueueWaitInfo(String email) async {
    try {
      // Step 1: Get user's queue with status "waiting"
      final userQueue = await queueNumbersCollection.findOne(
        where.eq('user', email).eq('status', 'waiting'),
      );

      if (userQueue == null || userQueue['transactionName'] == null) {
        print("❌ No active waiting queue found for this user.");
        return {
          "peopleInWaiting": 0,
          "approxWaitTime": "0 min",
        };
      }

      final transactionName = userQueue['transactionName'];

      // Step 2: Count all waiting queues with the same transactionName
      final totalWaiting = await queueNumbersCollection.count({
        'transactionName': transactionName,
        'status': 'waiting',
      });

      // Step 3: Subtract current user's queue from total
      final othersWaiting = (totalWaiting > 0) ? totalWaiting - 1 : 0;

      // Step 4: Calculate approx wait time in minutes
      final totalMinutes = othersWaiting * 5;

      // Step 5: Format time string
      final hours = totalMinutes ~/ 60;
      final minutes = totalMinutes % 60;
      String waitTimeFormatted = hours > 0
          ? "$hours hr${hours > 1 ? 's' : ''} ${minutes} min"
          : "$minutes min";

      return {
        "peopleInWaiting": othersWaiting,
        "approxWaitTime": waitTimeFormatted,
      };
    } catch (e) {
      print("❌ Error calculating queue wait info: $e");
      return {
        "peopleInWaiting": 0,
        "approxWaitTime": "0 min",
      };
    }
  }







}