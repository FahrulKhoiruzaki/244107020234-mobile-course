
import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(
  RemoteMessage message,
) async {
  debugPrint('Pesan FCM diterima saat background');
  debugPrint('Message ID: ${message.messageId}');
}

class PushService {
  static final FirebaseMessaging _messaging =
      FirebaseMessaging.instance;

  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static StreamSubscription<String>? _tokenSubscription;

  static const AndroidNotificationChannel _channel =
      AndroidNotificationChannel(
    'campus_notify_channel',
    'Campus Notify',
    description: 'Notifikasi pengumuman kampus',
    importance: Importance.high,
  );

  static Future<bool> requestNotificationPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    return settings.authorizationStatus ==
            AuthorizationStatus.authorized ||
        settings.authorizationStatus ==
            AuthorizationStatus.provisional;
  }

  static Future<void> initializeLocalNotifications() async {
    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );

    await _localNotifications.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (response) {
        debugPrint('Notifikasi diklik: ${response.payload}');
      },
    );

    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(_channel);
  }

  static Future<void> showNotification(RemoteMessage message) async {
    final notification = message.notification;

    if (notification == null) return;

    await _localNotifications.show(
      id: message.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      payload: message.data.toString(),
    );
  }

  static Future<void> initMessageHandlers() async {
    FirebaseMessaging.onMessage.listen((message) async {
      debugPrint('FCM diterima saat foreground');
      await showNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint('Notifikasi dibuka dari background');
      debugPrint('Data: ${message.data}');
    });

    final initialMessage =
        await _messaging.getInitialMessage();

    if (initialMessage != null) {
      debugPrint('Aplikasi dibuka dari notifikasi terminated');
      debugPrint('Data: ${initialMessage.data}');
    }
  }

  static Future<void> initFcmToken({
    required Future<void> Function(String token) onToken,
  }) async {
    final token = await _messaging.getToken();

    if (token != null) {
      debugPrint(
        'FCM Token: ${token.substring(0, 12)}...',
      );

      await onToken(token);
    }

    _tokenSubscription ??=
        _messaging.onTokenRefresh.listen((newToken) async {
      debugPrint(
        'FCM Token diperbarui: ${newToken.substring(0, 12)}...',
      );

      await onToken(newToken);
    });

    await _messaging.subscribeToTopic('pengumuman-kampus');

    debugPrint('Subscribe topic pengumuman-kampus berhasil');
  }
}
