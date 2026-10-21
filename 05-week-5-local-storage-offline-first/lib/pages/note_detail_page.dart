
import 'package:flutter/material.dart';

import '../data/repositories/note_repository.dart';

class NoteDetailPage extends StatelessWidget {
  const NoteDetailPage({
    super.key,
    required this.noteId,
    required this.repository,
  });

  final int noteId;
  final NoteRepository repository;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Catatan')),
      body: FutureBuilder(
        future: repository.fetchNoteById(noteId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text('Gagal memuat catatan.'),
            );
          }

          final note = snapshot.data;

          if (note == null) {
            return const Center(
              child: Text('Catatan tidak ditemukan.'),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                note.title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              Text(
                note.body.isEmpty ? 'Tidak ada isi catatan.' : note.body,
              ),
              const SizedBox(height: 16),
              Text('Diperbarui: ${note.updatedAt.toLocal()}'),
              const SizedBox(height: 8),
              Text(
                note.dirty
                    ? 'Status: Belum tersinkron'
                    : 'Status: Tersinkron (simulasi)',
              ),
            ],
          );
        },
      ),
    );
  }
}
