import 'package:sqflite/sqflite.dart';

import '../../../../core/failures.dart';
import '../../domain/entities/note.dart';
import '../../domain/repositories/note_repository.dart';
import '../models/note_model.dart';

class NoteRepositoryImpl implements NoteRepository {
  NoteRepositoryImpl({required Future<Database> Function() openDb})
    : _openDb = openDb;

  final Future<Database> Function() _openDb;

  @override
  Future<({List<Note> notes, Failure? failure})> fetchNotes() async {
    try {
      final db = await _openDb();
      final rows = await db.query('notes', orderBy: 'updated_at DESC');
      final notes = rows
          .map(NoteModel.fromMap)
          .map((model) => model.toEntity())
          .toList();

      return (notes: notes, failure: null);
    } catch (_) {
      return (
        notes: <Note>[],
        failure: const LocalFailure(
          'Gagal memuat catatan dari penyimpanan lokal.',
        ),
      );
    }
  }

  @override
  Future<({Note? note, Failure? failure})> addNote({
    required String title,
    String body = '',
  }) async {
    final model = NoteModel(
      title: title,
      body: body,
      updatedAt: DateTime.now(),
      dirty: true,
    );

    try {
      final db = await _openDb();
      final id = await db.insert('notes', model.toMap());
      final savedModel = NoteModel(
        id: id,
        title: model.title,
        body: model.body,
        updatedAt: model.updatedAt,
        dirty: true,
      );

      return (note: savedModel.toEntity(), failure: null);
    } catch (_) {
      return (
        note: null,
        failure: const LocalFailure(
          'Gagal menambahkan catatan ke penyimpanan lokal.',
        ),
      );
    }
  }
}
