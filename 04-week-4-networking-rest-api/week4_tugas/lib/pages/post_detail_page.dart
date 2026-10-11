import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/models/post.dart';
import '../data/network_errors.dart';
import '../data/providers.dart';

final postByIdProvider = FutureProvider.family<Post, int>((ref, id) {
  return ref.read(postRepositoryProvider).fetchPost(id);
});

class PostDetailPage extends ConsumerWidget {
  const PostDetailPage({
    super.key,
    required this.postId,
    this.initialPost,
  });

  final int postId;
  final Post? initialPost;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = initialPost;

    if (post != null) {
      return _detailScaffold(context, post);
    }

    final postAsync = ref.watch(postByIdProvider(postId));
    return postAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Detail Post')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Scaffold(
        appBar: AppBar(title: const Text('Detail Post')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  friendlyErrorMessage(error),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => ref.invalidate(postByIdProvider(postId)),
                  child: const Text('Coba lagi'),
                ),
              ],
            ),
          ),
        ),
      ),
      data: (post) => _detailScaffold(context, post),
    );
  }

  Widget _detailScaffold(BuildContext context, Post post) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Post'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            post.title,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Text(post.body),
        ],
      ),
    );
  }
}
