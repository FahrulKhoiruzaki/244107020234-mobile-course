import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'route_parser.dart';

import '../routes.dart';

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

  static void Function(String route)? _onNavigate;

  static const String _topic = 'pengumuman-kampus';

  static const AndroidNotificationChannel _channel =
      AndroidNotificationChannel(
    'campus_notify_channel',
    'Campus Notify',
    description: 'Notifikasi pengumuman kampus',
    importance: Importance.high,
  );

  // Meminta izin notifikasi.
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

  // Inisialisasi local notification.
  static Future<void> initializeLocalNotifications() async {
    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );

    await _localNotifications.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (response) {
        final route = response.payload ?? AppRoutes.home;

        debugPrint('Notifikasi diklik: $route');
        _onNavigate?.call(route);
      },
    );

    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(_channel);
  }

  // Menampilkan notifikasi manual saat foreground.
  static Future<void> showNotification(
    RemoteMessage message,
  ) async {
    final notification = message.notification;

    if (notification == null) return;

    final route = routeFromMessage(message.data);

    await _localNotifications.show(
      id: message.hashCode,
      title: notification.title ?? 'Pengumuman',
      body: notification.body ?? '',
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
      payload: route,
    );
  }

  // Menangani klik notifikasi foreground, background,
  // dan terminated.
  static Future<void> initMessageHandlers({
    required void Function(String route) go,
  }) async {
    _onNavigate = go;

    // Foreground.
    FirebaseMessaging.onMessage.listen((message) async {
      debugPrint('FCM diterima saat foreground');
      await showNotification(message);
    });

    // Background -> notifikasi diklik.
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      final route = routeFromMessage(message.data);

      debugPrint('Notifikasi dibuka dari background: $route');
      go(route);
    });

    // Terminated -> aplikasi dibuka melalui notifikasi.
    final initialMessage =
        await _messaging.getInitialMessage();

    if (initialMessage != null) {
      final route = routeFromMessage(initialMessage.data);

      debugPrint('Aplikasi dibuka dari terminated: $route');
      go(route);
    }
  }

  // Mengambil token dan mengirimkannya ke backend.
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

    // Mengirim token baru ke backend saat diperbarui.
    _tokenSubscription ??=
        _messaging.onTokenRefresh.listen((newToken) async {
      debugPrint(
        'FCM Token diperbarui: ${newToken.substring(0, 12)}...',
      );

      await onToken(newToken);
    });

    await subscribeToTopic();
  }

  // Berlangganan topic pengumuman kampus.
  static Future<void> subscribeToTopic() async {
    await _messaging.subscribeToTopic(_topic);

    debugPrint('Subscribe topic $_topic berhasil');
  }

  // Berhenti berlangganan topic pengumuman kampus.
  static Future<void> unsubscribeFromTopic() async {
    await _messaging.unsubscribeFromTopic(_topic);

    debugPrint('Unsubscribe topic $_topic berhasil');
  }
}
