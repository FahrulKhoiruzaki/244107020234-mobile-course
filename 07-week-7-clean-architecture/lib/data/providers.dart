import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'local/note.dart';
import 'prefs.dart';
import 'repositories/note_repository.dart';
import 'sync.dart';

final prefsRepositoryProvider = Provider<PrefsRepository>((ref) => PrefsRepository());

final noteRepositoryProvider = Provider<NoteRepository>((ref) => NoteRepository());

final appOpenedProvider = FutureProvider<void>((ref) async {
  await ref.read(prefsRepositoryProvider).markOpenedNow();
});

final lastOpenedProvider = FutureProvider<String?>((ref) {
  return ref.read(prefsRepositoryProvider).getLastOpened();
});

final darkModeProvider =
    AsyncNotifierProvider<DarkModeNotifier, bool>(DarkModeNotifier.new);

class DarkModeNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() {
    return ref.watch(prefsRepositoryProvider).getDarkMode();
  }

  Future<void> toggle(bool value) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(prefsRepositoryProvider).setDarkMode(value);
      return value;
    });
  }
}

final notesProvider = FutureProvider<List<Note>>((ref) {
  return ref.watch(noteRepositoryProvider).fetchNotes();
});

final forceOfflineProvider = StateProvider<bool>((ref) => false);

final postsDioProvider = Provider<Dio>((ref) {
  return Dio(BaseOptions(
    baseUrl: 'https://jsonplaceholder.typicode.com',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));
});

final postsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) {
  return loadPostsCacheFirst(
    dio: ref.watch(postsDioProvider),
    forceOffline: ref.watch(forceOfflineProvider),
    onUpdated: () {},
  );
});

final dirtyCountProvider = FutureProvider<int>((ref) {
  return ref.watch(noteRepositoryProvider).countDirty();
});

final noteDetailProvider = FutureProvider.family<Note?, int>((ref, id) {
  return ref.watch(noteRepositoryProvider).fetchNoteById(id);
});

final notesControllerProvider =
    AsyncNotifierProvider<NotesController, void>(NotesController.new);

class NotesController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> addNote({required String title, String body = ''}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(noteRepositoryProvider).addNote(
            title: title,
            body: body,
          );
      ref.invalidate(notesProvider);
      ref.invalidate(dirtyCountProvider);
    });
  }

  Future<void> deleteNote(int id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(noteRepositoryProvider).deleteNote(id);
      ref.invalidate(notesProvider);
      ref.invalidate(dirtyCountProvider);
    });
  }

  Future<int> syncNotesNow({required bool forceOffline}) async {
    state = const AsyncLoading();
    var result = 0;
    state = await AsyncValue.guard(() async {
      result = await syncNotes(
        ref.read(noteRepositoryProvider),
        forceOffline: forceOffline,
      );
      ref.invalidate(notesProvider);
      ref.invalidate(dirtyCountProvider);
    });
    return result;
  }
}
