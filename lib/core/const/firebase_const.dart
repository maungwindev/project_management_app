import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

@immutable
class FirebaseConst {
  /// Firebase Project name
  static const projectName = "appdistributiontest-77e17";

  /// Firebase service json name
  static const serviceJson = {};

  static const String calls = "calls";

  // Example from Firebase console
  static const FirebaseOptions firebaseConfig = FirebaseOptions(
    apiKey: "AIzaSyXXXXXXX...",
    authDomain: "project-id.firebaseapp.com",
    projectId: "project-id",
    storageBucket: "project-id.appspot.com",
    messagingSenderId: "1234567890",
    appId: "1:1234567890:web:abcdef123456",
  );
}
