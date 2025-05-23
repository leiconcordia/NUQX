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


}