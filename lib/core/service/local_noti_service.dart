import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {

  // Singleton instance
  static final LocalNotificationService _instance = LocalNotificationService._internal();

  // Private constructor
  LocalNotificationService._internal();

  // Factory constructor to return the singleton instance
  factory LocalNotificationService() => _instance;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  /// Initialize local notifications
  Future<void> initializeLocalNotification() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestCriticalPermission: true,
      requestSoundPermission: true,
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (response) {
        debugPrint("Notification payload: ${response.payload}");
      },
    );
  }

  /// Show local notification
  Future<void> showNotification({
    required String title,
    required String body,
    required Map<String, dynamic> payload,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'com.example.chat_app.urgent',
      'mychannelid',
      importance: Importance.max,
      priority: Priority.max,
      styleInformation: BigTextStyleInformation(
        body,
        htmlFormatBigText: true,
        contentTitle: title,
        htmlFormatTitle: true,
      ),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      notificationDetails,
      payload: jsonEncode(payload),
    );
  }
}