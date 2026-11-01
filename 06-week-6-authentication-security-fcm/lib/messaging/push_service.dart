
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class PushService {
  static final FirebaseMessaging _messaging =
      FirebaseMessaging.instance;

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

    _messaging.onTokenRefresh.listen(onToken);

    await _messaging.subscribeToTopic(
      'pengumuman-kampus',
    );
  }
}
