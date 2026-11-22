
import 'package:flutter/material.dart';

import '../data/local/note.dart';

class NoteTile extends StatelessWidget {
  const NoteTile({
    super.key,
    required this.note,
    required this.onTap,
    required this.onDelete,
  });

  final Note note;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(note.title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(note.body.isEmpty ? 'Tidak ada isi catatan' : note.body),
          if (note.dirty)
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Chip(
                avatar: Icon(Icons.sync_problem, size: 16),
                label: Text('Belum tersinkron'),
                visualDensity: VisualDensity.compact,
              ),
            ),
        ],
      ),
      onTap: onTap,
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline),
        tooltip: 'Hapus catatan',
        onPressed: onDelete,
      ),
    );
  }
}
