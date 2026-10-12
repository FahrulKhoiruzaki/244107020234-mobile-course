import 'package:sqflite/sqflite.dart';
import '../data/local/db.dart';

class NoteRepository {
  NoteRepository({Future<Database> Function()? openDb})
      : _openDb = openDb ?? openNotesDb;

  final Future<Database> Function() _openDb;

  // [READ] Mengambil semua catatan
  Future<List<Map<String, dynamic>>> fetchNotes() async {
    final db = await _openDb();
    
    return db.query(
      'notes',
      orderBy: 'updated_at DESC',
    );
  }

  // [CREATE] Menambahkan catatan baru
  Future<int> addNote({
    required String title,
    String body = '',
  }) async {
    final db = await _openDb();
    
    return db.insert(
      'notes',
      {
        'title': title,
        'body': body,
        'updated_at': DateTime.now().toIso8601String(),
        'dirty': 1,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // [UPDATE] Memperbarui catatan yang sudah ada
  Future<int> updateNote({
    required int id,
    required String title,
    String body = '',
  }) async {
    final db = await _openDb();
    
    return db.update(
      'notes',
      {
        'title': title,
        'body': body,
        'updated_at': DateTime.now().toIso8601String(),
        'dirty': 1, // Tandai sebagai dirty agar disinkronisasi ke server nantinya
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // [DELETE] Menghapus catatan
  Future<int> deleteNote(int id) async {
    final db = await _openDb();
    
    return db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Menghitung catatan yang belum tersinkronisasi
  Future<int> countDirty() async {
    final db = await _openDb();
    
    final result = await db.rawQuery(
      'SELECT COUNT(*) AS total FROM notes WHERE dirty = 1',
    );
    
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Menandai semua catatan sebagai tersinkronisasi
  Future<int> markAllSynced() async {
    final db = await _openDb();
    
    return db.update(
      'notes',
      {'dirty': 0},
      where: 'dirty = ?',
      whereArgs: [1],
    );
  }
}