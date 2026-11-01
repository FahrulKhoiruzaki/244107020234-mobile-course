import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';

import 'firebase_options.dart';
import 'routes.dart';

import 'providers/auth_provider.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'pages/announcement_page.dart';

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
      child: MyApp(router: router),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.router,
  });

  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Campus Notify',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}

GoRouter createRouter(ProviderContainer container) {
  final router = GoRouter(
    initialLocation: AppRoutes.home,
    redirect: (context, state) {
      final loggedIn =
          container.read(authStateProvider).value ?? false;

      final goingLogin =
          state.matchedLocation == AppRoutes.login;

      if (!loggedIn && !goingLogin) {
        return AppRoutes.login;
      }

      if (loggedIn && goingLogin) {
        return AppRoutes.home;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: AppRoutes.announcement,
        builder: (context, state) {
          return AnnouncementPage(
            id: state.pathParameters['id'] ?? '',
          );
        },
      ),
    ],
  );

  container.listen(authStateProvider, (previous, next) {
    router.refresh();
  });

  return router;
}