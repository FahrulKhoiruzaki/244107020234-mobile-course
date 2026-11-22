import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/providers.dart';

class PostsPage extends ConsumerWidget {
  const PostsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posts = ref.watch(postsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Cached Posts')),
      body: posts.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Gagal memuat posts: $error')),
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text(
              'Belum ada cache posts. Muat saat online terlebih dahulu.',
            ));
          }
          return RefreshIndicator(
            onRefresh: () => ref.refresh(postsProvider.future),
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final post = items[index];
                return ListTile(
                  title: Text(post['title']?.toString() ?? ''),
                  subtitle: Text(post['body']?.toString() ?? ''),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
