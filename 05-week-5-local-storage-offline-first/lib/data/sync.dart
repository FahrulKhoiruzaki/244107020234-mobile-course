
import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import 'local/db.dart';
import 'repositories/note_repository.dart';

/// Membaca post yang sudah tersimpan di tabel cached_posts.
Future<List<Map<String, dynamic>>> readCachedPosts({
  Future<Database> Function()? openDb,
}) async {
  final db = await (openDb ?? openNotesDb)();

  final rows = await db.query(
    'cached_posts',
    orderBy: 'id ASC',
  );

  return rows.map((row) {
    final payload = row['payload'] as String;
    return Map<String, dynamic>.from(
      jsonDecode(payload) as Map,
    );
  }).toList();
}

/// Mengambil post terbaru dari API dan menyimpannya ke SQLite.
Future<void> refreshPostsInBackground({
  required Dio dio,
  required VoidCallback onUpdated,
  Future<Database> Function()? openDb,
  bool forceOffline = false,
}) async {
  if (forceOffline) return;

  try {
    final response = await dio.get<List<dynamic>>('/posts');
    final posts = response.data;

    if (posts == null) return;

    final db = await (openDb ?? openNotesDb)();
    final batch = db.batch();
    final cachedAt = DateTime.now().toIso8601String();

    for (final item in posts) {
      final post = Map<String, dynamic>.from(item as Map);

      batch.insert(
        'cached_posts',
        {
          'id': post['id'],
          'payload': jsonEncode(post),
          'cached_at': cachedAt,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);

    onUpdated();
  } on DioException catch (error) {
    debugPrint('Gagal memperbarui cache post: ${error.message}');
  } catch (error) {
    debugPrint('Gagal menyimpan cache post: $error');
  }
}

/// Mengembalikan cache terlebih dahulu, lalu memperbaruinya di background.
Future<List<Map<String, dynamic>>> loadPostsCacheFirst({
  required Dio dio,
  required VoidCallback onUpdated,
  Future<Database> Function()? openDb,
  bool forceOffline = false,
}) async {
  final cached = await readCachedPosts(openDb: openDb);

  if (!forceOffline) {
    unawaited(
      refreshPostsInBackground(
        dio: dio,
        onUpdated: onUpdated,
        openDb: openDb,
        forceOffline: forceOffline,
      ),
    );
  }

  return cached;
}

/// Simulasi sinkronisasi catatan yang berstatus dirty.
Future<int> syncNotes(
  NoteRepository repo, {
  bool forceOffline = false,
}) async {
  if (forceOffline) return 0;

  final dirtyCount = await repo.countDirty();

  if (dirtyCount == 0) return 0;

  // Simulasi upload, bukan pengiriman ke server sungguhan.
  await Future.delayed(const Duration(seconds: 1));

  await repo.markAllSynced();

  return dirtyCount;
}