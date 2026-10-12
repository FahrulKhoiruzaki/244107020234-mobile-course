
import 'package:flutter_test/flutter_test.dart';
import 'package:week5_offline_notes/data/local/note.dart';

void main() {
  group('Note model', () {
    test('Note dapat dikonversi ke Map dan kembali', () {
      final note = Note(
        id: 1,
        title: 'Tes Offline',
        body: 'Pengujian SQLite',
        updatedAt: DateTime.parse('2026-10-12T10:00:00Z'),
        dirty: true,
      );

      final result = Note.fromMap(note.toMap());

      expect(result.id, 1);
      expect(result.title, 'Tes Offline');
      expect(result.body, 'Pengujian SQLite');
      expect(result.dirty, true);
      expect(result.updatedAt, note.updatedAt);
    });

    test('Nilai default digunakan jika data tidak lengkap', () {
      final note = Note.fromMap({
        'id': 2,
        'title': 'Catatan',
        'updated_at': '2026-10-12T10:00:00Z',
        'dirty': 0,
      });

      expect(note.title, 'Catatan');
      expect(note.body, '');
      expect(note.dirty, false);
    });
  });
}