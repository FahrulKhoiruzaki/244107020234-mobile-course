
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../messaging/push_service.dart';
import '../providers/auth_provider.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _testBackendConnection();
      await _initializeFcm();
    });
  }

  Future<void> _testBackendConnection() async {
    try {
      final dio = Dio(
        BaseOptions(
          baseUrl: 'http://192.168.194.245:8081',
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      final response = await dio.get('/');

      debugPrint('TES BACKEND BERHASIL: ${response.data}');
    } catch (e) {
      debugPrint('TES BACKEND GAGAL: $e');
    }
  }

  Future<void> _initializeFcm() async {
    try {
      final permission =
          await PushService.requestNotificationPermission();

      if (!permission) {
        debugPrint('Izin notifikasi tidak diberikan');
        return;
      }

      await PushService.initFcmToken(
        onToken: (token) async {
          final platform =
              Theme.of(context).platform == TargetPlatform.iOS
                  ? 'ios'
                  : 'android';

          await ref.read(apiClientProvider).post(
            '/devices',
            data: {
              'fcm_token': token,
              'platform': platform,
            },
          );

          debugPrint('Registrasi perangkat berhasil');
        },
      );

    } catch (e) {
      debugPrint('FCM initialization error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Notify'),
        actions: [
          IconButton(
            onPressed: () async {
              await ref
                  .read(authStateProvider.notifier)
                  .logout();
            },
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.school, size: 72),
              const SizedBox(height: 16),
              const Text(
                'Selamat Datang!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Anda berhasil login ke Campus Notify.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  context.push('/pengumuman/3');
                },
                child: const Text('Lihat Pengumuman'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
