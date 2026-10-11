import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/post.dart';
import '../data/network_errors.dart';
import '../data/providers.dart';

final postByIdProvider = FutureProvider.family<Post, int>((ref, id) {
  return ref.read(postRepositoryProvider).fetchPost(id);
});

class PostDetailPage extends ConsumerWidget {
  const PostDetailPage({super.key, required this.postId, this.initialPost});

  final int postId;
  final Post? initialPost;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = initialPost;

    if (post != null) {
      return _buildDetail(post);
    }

    return ref
        .watch(postByIdProvider(postId))
        .when(
          loading: () => Scaffold(
            appBar: AppBar(title: const Text('Detail Post')),
            body: const Center(child: CircularProgressIndicator()),
          ),
          error: (error, stackTrace) => Scaffold(
            appBar: AppBar(title: const Text('Detail Post')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(friendlyErrorMessage(error)),
              ),
            ),
          ),
          data: (post) => _buildDetail(post),
        );
  }

  Widget _buildDetail(Post post) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Post')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              post.title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(post.body),
          ],
        ),
      ),
    );
  }
}
