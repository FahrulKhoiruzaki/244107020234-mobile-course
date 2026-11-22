import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'features/notes/presentation/pages/notes_page.dart';
import 'features/notes/presentation/providers/notes_providers.dart'
    as notes_feature;
import 'features/announcements/presentation/pages/announcements_page.dart';
import 'core/format.dart';
import 'pages/note_detail_page.dart';
import 'pages/posts_page.dart';
import 'pages/settings_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: NotesApp()));
}

class NotesApp extends ConsumerStatefulWidget {
  const NotesApp({super.key});

  @override
  ConsumerState<NotesApp> createState() => _NotesAppState();
}

class _NotesAppState extends ConsumerState<NotesApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (context, state) => const NotesPage()),
        GoRoute(
          path: '/note/:id',
          builder: (context, state) {
            final id = parseRouteId(state.pathParameters['id']);
            if (id == null) {
              return const Scaffold(
                body: Center(child: Text('ID catatan tidak valid.')),
              );
            }
            return NoteDetailPage(noteId: id);
          },
        ),
        GoRoute(
          path: '/announcements',
          builder: (context, state) => const AnnouncementsPage(),
        ),
        GoRoute(path: '/posts', builder: (context, state) => const PostsPage()),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsPage(),
        ),
      ],
    );
    Future.microtask(() {
      ref.read(notes_feature.appOpenedProvider);
    });
  }

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final darkMode = ref.watch(notes_feature.darkModeProvider);
    ref.watch(notes_feature.appOpenedProvider);

    return darkMode.when(
      loading: () => const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      error: (error, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(body: Center(child: Text('Gagal memuat tema: $error'))),
      ),
      data: (value) => MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Offline Notes',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.indigo,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        themeMode: value ? ThemeMode.dark : ThemeMode.light,
        routerConfig: _router,
      ),
    );
  }
}
