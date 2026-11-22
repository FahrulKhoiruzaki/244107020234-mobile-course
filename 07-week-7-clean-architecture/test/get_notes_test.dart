import 'package:flutter_test/flutter_test.dart';

import 'package:week5_offline_notes/core/failures.dart';
import 'package:week5_offline_notes/features/notes/domain/entities/note.dart';
import 'package:week5_offline_notes/features/notes/domain/repositories/note_repository.dart';
import 'package:week5_offline_notes/features/notes/domain/usecases/get_notes.dart';

class FakeNoteRepository implements NoteRepository {
  FakeNoteRepository({this.items = const [], this.fail = false});

  final List<Note> items;
  final bool fail;

  @override
  Future<({List<Note> notes, Failure? failure})> fetchNotes() async {
    if (fail) {
      return (
        notes: const <Note>[],
        failure: const LocalFailure('db locked (simulasi)'),
      );
    }

    return (notes: items, failure: null);
  }

  @override
  Future<({Note? note, Failure? failure})> addNote({
    required String title,
    String body = '',
  }) {
    throw UnimplementedError();
  }
}

void main() {
  final updatedAt = DateTime(2026, 11, 22);

  test('GetNotes mengembalikan catatan dari repository fake', () async {
    final repo = FakeNoteRepository(
      items: [Note(title: 'Belanja', updatedAt: updatedAt)],
    );

    final result = await GetNotes(repo).call();

    expect(result.failure, isNull);
    expect(result.notes, hasLength(1));
    expect(result.notes.single.title, 'Belanja');
  });

  test(
    'GetNotes mengembalikan LocalFailure tanpa melempar exception',
    () async {
      final result = await GetNotes(FakeNoteRepository(fail: true)).call();

      expect(result.failure, isA<LocalFailure>());
      expect(result.failure!.message, 'db locked (simulasi)');
      expect(result.notes, isEmpty);
    },
  );
}
