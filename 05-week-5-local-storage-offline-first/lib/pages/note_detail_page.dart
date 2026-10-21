import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/providers.dart';

class NoteDetailPage extends ConsumerWidget {
  const NoteDetailPage({super.key, required this.noteId});
  final int noteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final note = ref.watch(noteDetailProvider(noteId));
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Catatan')),
      body: note.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Gagal memuat catatan: $error')),
        data: (value) {
          if (value == null) {
            return const Center(child: Text('Catatan tidak ditemukan.'));
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(value.title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 12),
              Text(value.body.isEmpty ? 'Tidak ada isi catatan.' : value.body),
              const SizedBox(height: 16),
              Text('Diperbarui: ${value.updatedAt.toLocal()}'),
              const SizedBox(height: 8),
              Text(value.dirty
                  ? 'Status: Belum tersinkron'
                  : 'Status: Tersinkron (simulasi)'),
            ],
          );
        },
      ),
    );
  }
}
