import 'dart:developer';

import 'package:mongo_dart/mongo_dart.dart';
import 'package:flutter_application_1/DBHelper/constant.dart';

class MongoDatabase {
  static late Db db;
  static late DbCollection userCollection;

  static Future<void> connect() async {
    try {
      db = await Db.create(MONGO_CONN_URL);
      await db.open();
      inspect(db);
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





}
