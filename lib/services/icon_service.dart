// import 'dart:convert';
// import 'package:flutter/services.dart';
// import 'package:flutter_mdi_icons/flutter_mdi_icons.dart';
//
// class IconService {
//   static List<String> _iconNames = [];
//   static bool _isInitialized = false;
//
//   static Future<void> initialize() async {
//     if (_isInitialized) return;
//
//     try {
//       final String jsonString = await rootBundle.loadString('assets/mdi_icons.json');
//       _iconNames = List<String>.from(json.decode(jsonString));
//       _isInitialized = true;
//     } catch (e) {
//       print('Error loading icons: $e');
//       _iconNames = [];
//     }
//   }
//
//   static IconData? getIcon(String? iconName) {
//     if (iconName == null || iconName.isEmpty) return null;
//
//     // Convert icon name to MDI format (replace hyphens with underscores)
//     final mdiName = iconName.replaceAll('-', '_');
//
//     try {
//       // Use reflection to get the icon from MdiIcons
//       return MdiIcons.__getattr__(mdiName);
//     } catch (e) {
//       print('Icon not found: $mdiName');
//       return null;
//     }
//   }
//
//   static IconData getDefaultIcon() => Mdi.questionMark;
//
//   static bool isValidIcon(String iconName) {
//     return _iconNames.contains(iconName);
//   }
// }