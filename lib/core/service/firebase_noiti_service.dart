import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:pm_app/core/service/local_noti_service.dart';

class FirebaseNotificationService {
  final LocalNotificationService localNotificationService;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  FirebaseNotificationService({required this.localNotificationService});

  /// Initialize notification service
  Future<void> init(String currentUid) async {
    // 1️⃣ Request permission
    await _requestPermission();

    // 2️⃣ Initialize local notifications
    await localNotificationService.initialize();

    // 3️⃣ Save/update device FCM token
    await _saveFcmToken(currentUid);

    // 4️⃣ Listen for token refresh
    _listenTokenRefresh(currentUid);

    // 5️⃣ Listen for notification requests targeted to this user
    _listenNotificationRequests(currentUid);
  }

  /// Request notification permission
  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint('Notification permission: ${settings.authorizationStatus}');
  }

  /// Save or update FCM token in Firestore
  Future<void> _saveFcmToken(String uid) async {
    final token = await _messaging.getToken();
    if (token != null) {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'fcmToken': token,
      }, SetOptions(merge: true));
      debugPrint('FCM token saved: $token');
    }
  }

  /// Listen for token refresh
  void _listenTokenRefresh(String uid) {
    _messaging.onTokenRefresh.listen((newToken) async {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'fcmToken': newToken,
      }, SetOptions(merge: true));
      debugPrint('FCM token refreshed: $newToken');
    });
  }

  /// Listen for notification requests targeted to this user
  void _listenNotificationRequests(String uid) {
  FirebaseFirestore.instance
      .collection('notificationRequests')
      .where('toUid', isEqualTo: uid)
      .snapshots()
      .listen((snapshot) {
    for (var docChange in snapshot.docChanges) {
      if (docChange.type == DocumentChangeType.added) {
        final data = docChange.doc.data();
        if (data != null) {
          // Show local notification
          localNotificationService.show(
            title: data['title'] ?? 'New Notification',
            body: data['body'] ?? '',
            payload: data['data'] ?? {},
          );

          // Delete request after handling
          try {
            FirebaseFirestore.instance
                .collection('notificationRequests')
                .doc(docChange.doc.id)
                .delete();
          } catch (e) {
            debugPrint('Could not delete notification: $e');
          }
        }
      }
    }
  });
}


  /// Send notification request (user-to-user)
  /// This is safe, uses Firestore to trigger notifications
  Future<void> sendNotification({
    required String fromUid,
    required String toUid,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    // Add notification request to Firestore
    await FirebaseFirestore.instance.collection('notificationRequests').add({
      'fromUid': fromUid,
      'toUid': toUid,
      'title': title,
      'body': body,
      'data': data ?? {},
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
