import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:pm_app/core/const/firebase_const.dart';
import 'package:pm_app/core/network/dio_client.dart';
import 'package:pm_app/core/service/local_noti_service.dart';
import 'package:get_it/get_it.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;

class FirebaseNotificationService {
  
  final LocalNotificationService localNotificationService;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  FirebaseNotificationService({required this.localNotificationService});

  String? _cachedAccessToken;

  /// Request Firebase FCM permissions
  Future<void> requestPermission() async {
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      debugPrint('User granted provisional permission');
    } else {
      debugPrint('User declined or has not accepted permission');
    }
  }

  /// Get Firebase device token
  Future<String> getToken() async {
    final token = await _firebaseMessaging.getToken();
    return token ?? '';
  }

  /// Initialize Firebase notifications
  Future<void> initialize(BuildContext context) async {
    await localNotificationService.initializeLocalNotification();

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint("=> Message opened: ${message.notification?.title}");
      // Handle navigation or other logic here
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      debugPrint("=> Message received: ${message.data}");
      await localNotificationService.showNotification(
        title: message.notification?.title ?? '',
        body: message.notification?.body ?? '',
        payload: message.data,
      );
    });

    await handleInitialMessage();
  }

  /// Handle initial message when the app is launched from a notification
  Future<void> handleInitialMessage() async {
    final RemoteMessage? message = await _firebaseMessaging.getInitialMessage();
    if (message != null) {
      // Handle the initial message
    }
  }

  /// Get access token for Firebase Cloud Messaging
  Future<String> _getAccessToken() async {
    if (_cachedAccessToken != null) return _cachedAccessToken!;

    const serviceAccountJson = FirebaseConst.serviceJson;

    const scopes = ["https://www.googleapis.com/auth/firebase.messaging"];

    try {
      final client = await auth.clientViaServiceAccount(
        auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
        scopes,
      );

      final credentials = await auth.obtainAccessCredentialsViaServiceAccount(
        auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
        scopes,
        client,
      );

      client.close();
      _cachedAccessToken = credentials.accessToken.data;
      return _cachedAccessToken!;
    } catch (e) {
      debugPrint('Error obtaining access token: $e');
      rethrow;
    }
  }

  /// Send notification to a specific device
  Future<void> sendNotification({
    required String deviceToken,
    required String title,
    required String body,
    required Map<String, dynamic> data,
  }) async {
    final DioClient dioClient = GetIt.instance<DioClient>();
    final serverAccessTokenKey = await _getAccessToken();

    debugPrint("Server access token key: $serverAccessTokenKey");

    const endpointFirebaseCloudMessaging =
        'https://fcm.googleapis.com/v1/projects/${FirebaseConst.projectName}/messages:send';

    final Map<String, dynamic> message = {
      "message": {
        "token": deviceToken,
        "notification": {
          "title": title,
          "body": body,
        },
        "data": data,
      },
    };

    final response = await dioClient.postRequestWithCustomHeader(
      apiUrl: endpointFirebaseCloudMessaging,
      requestBody: message,
      header: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $serverAccessTokenKey',
      },
    );

    if (response.statusCode != 200) {
      debugPrint('Failed to send notification');
    }
  }

  /// Get the FCM token from the device
  Future<String> getFcmToken() async {
    try {
      final token = await _firebaseMessaging.getToken();
      debugPrint("FCM Token: $token");
      return token ?? '';
    } catch (e) {
      debugPrint("Error getting FCM token: $e");
      return '';
    }
  }
}
