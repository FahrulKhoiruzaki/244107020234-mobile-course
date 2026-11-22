import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../widgets/note_tile.dart';
import '../../domain/entities/note.dart';
import '../providers/notes_providers.dart';

class NotesPage extends ConsumerWidget {
  const NotesPage({super.key});

  Future<void> _addNote(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => const AddNoteDialog(),
    );
    if (result == null) return;

    await ref
        .read(notesControllerProvider.notifier)
        .addNote(title: result['title']!, body: result['body']!);
    ref.invalidate(notesProvider);
  }

  Future<void> _deleteNote(WidgetRef ref, int id) async {
    await ref.read(notesControllerProvider.notifier).deleteNote(id);
    ref.invalidate(notesProvider);
  }

  Future<void> _syncNotes(BuildContext context, WidgetRef ref) async {
    final offline = ref.read(forceOfflineProvider);
    final processed = await ref
        .read(notesControllerProvider.notifier)
        .syncNotesNow(forceOffline: offline);
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          offline
              ? 'Force Offline aktif. Sinkronisasi tidak dijalankan.'
              : processed == 0
              ? 'Tidak ada catatan yang perlu disinkronkan.'
              : '$processed catatan berhasil disinkronkan (simulasi).',
        ),
      ),
    );
    ref.invalidate(notesProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref.watch(notesProvider);
    final dirty = ref.watch(dirtyCountProvider);
    final offline = ref.watch(forceOfflineProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Notes'),
        actions: [
          IconButton(
            onPressed: () => context.push('/announcements'),
            icon: const Icon(Icons.cloud_download_outlined),
            tooltip: 'Cached posts',
          ),
          IconButton(
            onPressed: () => context.push('/settings'),
            icon: const Icon(Icons.settings),
            tooltip: 'Pengaturan',
          ),
        ],
      ),
      body: Column(
        children: [
          SwitchListTile(
            title: const Text(
              'Force Offline',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              offline
                  ? 'Aktif — sinkronisasi dinonaktifkan'
                  : 'Nonaktif — sinkronisasi diizinkan',
            ),
            value: offline,
            onChanged: (value) =>
                ref.read(forceOfflineProvider.notifier).state = value,
          ),
          dirty.when(
            loading: () => const LinearProgressIndicator(minHeight: 2),
            error: (_, _) => const SizedBox(height: 2),
            data: (count) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Belum tersinkron: $count'),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _syncNotes(context, ref),
                icon: const Icon(Icons.sync),
                label: const Text('Sinkronkan Catatan'),
              ),
            ),
          ),
          Expanded(
            child: _NotesContent(notes: notes, onDelete: _deleteNote),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addNote(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Catatan'),
      ),
    );
  }
}

class _NotesContent extends ConsumerWidget {
  const _NotesContent({required this.notes, required this.onDelete});

  final AsyncValue<List<Note>> notes;
  final Future<void> Function(WidgetRef ref, int id) onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return notes.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Gagal memuat catatan: $error'),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: () => ref.invalidate(notesProvider),
              child: const Text('Coba lagi'),
            ),
          ],
        ),
      ),
      data: (items) {
        if (items.isEmpty) {
          return const Center(child: Text('Belum ada catatan'));
        }

        return RefreshIndicator(
          onRefresh: () => ref.refresh(notesProvider.future),
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final note = items[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                child: NoteTile(
                  note: note,
                  onTap: note.id == null
                      ? () {}
                      : () => context.push('/note/${note.id}'),
                  onDelete: note.id == null
                      ? () {}
                      : () => onDelete(ref, note.id!),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class AddNoteDialog extends StatefulWidget {
  const AddNoteDialog({super.key});

  @override
  State<AddNoteDialog> createState() => _AddNoteDialogState();
}

class _AddNoteDialogState extends State<AddNoteDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _bodyController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _save() {
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Judul catatan wajib diisi')),
      );
      return;
    }
    Navigator.of(context).pop({'title': title, 'body': body});
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tambah Catatan'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Judul',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _bodyController,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Isi catatan',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        FilledButton(onPressed: _save, child: const Text('Simpan')),
      ],
    );
  }
}
