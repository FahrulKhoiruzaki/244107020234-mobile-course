import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/local/db.dart';
import '../../../../data/providers.dart' as legacy;
import '../../data/repositories/note_repository_impl.dart';
import '../../domain/entities/note.dart';
import '../../domain/repositories/note_repository.dart';
import '../../domain/usecases/get_notes.dart';

final noteRepositoryProvider = Provider<NoteRepository>((ref) {
  return NoteRepositoryImpl(openDb: openNotesDb);
});

final getNotesProvider = Provider<GetNotes>((ref) {
  return GetNotes(ref.watch(noteRepositoryProvider));
});

final notesProvider = FutureProvider<List<Note>>((ref) async {
  final result = await ref.watch(getNotesProvider).call();

  final failure = result.failure;
  if (failure != null) {
    throw Exception(failure.message);
  }

  return result.notes;
});

// Existing app flows remain behind this presentation boundary until their
// own feature contracts are migrated in a later stage.
final appOpenedProvider = legacy.appOpenedProvider;
final darkModeProvider = legacy.darkModeProvider;
final lastOpenedProvider = legacy.lastOpenedProvider;
final notesControllerProvider = legacy.notesControllerProvider;
final dirtyCountProvider = legacy.dirtyCountProvider;
final forceOfflineProvider = legacy.forceOfflineProvider;
final noteDetailProvider = legacy.noteDetailProvider;
