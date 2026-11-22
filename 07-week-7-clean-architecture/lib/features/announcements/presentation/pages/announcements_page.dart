import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/format.dart';
import '../../domain/entities/announcement.dart';
import '../providers/announcements_providers.dart';

class AnnouncementsPage extends ConsumerWidget {
  const AnnouncementsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final announcements = ref.watch(announcementsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Pengumuman Tersimpan')),
      body: announcements.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(announcementErrorMessage(error)),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: () => ref.invalidate(announcementsProvider),
                child: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
        data: (items) {
          if (items.isEmpty) {
            return const Center(
              child: Text(
                'Belum ada pengumuman tersimpan. Muat saat online terlebih dahulu.',
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () => ref.refresh(announcementsProvider.future),
            child: ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) =>
                  _AnnouncementTile(announcement: items[index]),
            ),
          );
        },
      ),
    );
  }
}

class _AnnouncementTile extends StatelessWidget {
  const _AnnouncementTile({required this.announcement});

  final Announcement announcement;

  @override
  Widget build(BuildContext context) {
    final date = announcement.publishedAt;
    return ListTile(
      title: Text(announcement.title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(announcement.body),
          if (date != null)
            Text(
              formatDate(date),
              style: Theme.of(context).textTheme.bodySmall,
            ),
        ],
      ),
    );
  }
}
