import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:pm_app/core/service/local_noti_service.dart';

class FirebaseNotificationService {
  final LocalNotificationService localNotificationService;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  FirebaseNotificationService({required this.localNotificationService});

  /// Initialize notification service
  Future<void> init(String currentUid) async {
    await _requestPermission();
    await localNotificationService.initialize();
    await _saveFcmToken(currentUid);
    _listenTokenRefresh(currentUid);
    _listenNotificationRequests(currentUid);

    // Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final data = message.data;
      localNotificationService.show(
        title: message.notification?.title ?? 'New Notification',
        body: message.notification?.body ?? '',
        payload: data.isNotEmpty ? data : null,
      );
    });

    // App opened from background notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final data = message.data;
      if (data.isNotEmpty) {
        _handleTap(data);
      }
    });

    // App opened from terminated state
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null && initialMessage.data.isNotEmpty) {
      _handleTap(initialMessage.data);
    }
  }

  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint('Notification permission: ${settings.authorizationStatus}');
  }

  Future<void> _saveFcmToken(String uid) async {
    final token = await _messaging.getToken();
    if (token != null) {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'fcmToken': token,
      }, SetOptions(merge: true));
      debugPrint('FCM token saved: $token');
    }
  }

  void _listenTokenRefresh(String uid) {
    _messaging.onTokenRefresh.listen((newToken) async {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'fcmToken': newToken,
      }, SetOptions(merge: true));
      debugPrint('FCM token refreshed: $newToken');
    });
  }

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
            localNotificationService.show(
              title: data['title'] ?? 'New Notification',
              body: data['body'] ?? '',
              payload: data['data'] != null ? data['data'] : null,
            );
            // Delete after showing
            FirebaseFirestore.instance
                .collection('notificationRequests')
                .doc(docChange.doc.id)
                .delete();
          }
        }
      }
    });
  }

  Future<void> sendNotification({
    required String fromUid,
    required String toUid,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    await FirebaseFirestore.instance.collection('notificationRequests').add({
      'fromUid': fromUid,
      'toUid': toUid,
      'title': title,
      'body': body,
      'data': data ?? {},
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  void _handleTap(Map<String, dynamic> data) {
    if (data['type'] == 'task') {
      Get.toNamed('/task-detail', arguments: {
        'projectId': data['projectId'],
        'taskId': data['taskId'],
      });
    }
  }
}
