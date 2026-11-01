
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'pages/announcement_page.dart';
import 'providers/auth_provider.dart';

GoRouter createRouter(ProviderContainer container) {
  final router = GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final loggedIn =
          container.read(authStateProvider).value ?? false;

      final goingLogin = state.matchedLocation == '/login';

      if (!loggedIn && !goingLogin) return '/login';
      if (loggedIn && goingLogin) return '/';

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/pengumuman/:id',
        builder: (context, state) => AnnouncementPage(
          id: state.pathParameters['id'] ?? '',
        ),
      ),
    ],
  );

  container.listen(authStateProvider, (previous, next) {
    router.refresh();
  });

  return router;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final container = ProviderContainer();
  final router = createRouter(container);

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: CampusNotifyApp(router: router),
    ),
  );
}

class CampusNotifyApp extends StatelessWidget {
  const CampusNotifyApp({
    super.key,
    required this.router,
  });

  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Campus Notify',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
