import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_client.dart';
import 'models/comment.dart';
import 'models/post.dart';
import 'repositories/comment_repository.dart';
import 'repositories/post_repository.dart';

final dioProvider = Provider<Dio>((ref) => createDio());

final postRepositoryProvider = Provider<PostRepository>(
  (ref) => PostRepository(ref.watch(dioProvider)),
);

final commentRepositoryProvider = Provider<CommentRepository>(
  (ref) => CommentRepository(ref.watch(dioProvider)),
);

class PostListNotifier extends AsyncNotifier<List<Post>> {
  @override
  Future<List<Post>> build() async {
    final repository = ref.watch(postRepositoryProvider);
    return repository.fetchPosts();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();

    try {
      final repository = ref.read(postRepositoryProvider);
      state = AsyncData(await repository.fetchPosts());
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }
}

final postListProvider = AsyncNotifierProvider<PostListNotifier, List<Post>>(
  PostListNotifier.new,
  retry: (retryCount, error) => null,
);

/// Helper untuk membaca hasil provider pertama yang bukan loading.
Future<List<Post>> readPostsOnce(ProviderContainer container) {
  final completer = Completer<List<Post>>();

  final sub = container.listen<AsyncValue<List<Post>>>(postListProvider, (
    previous,
    next,
  ) {
    if (next.isLoading || completer.isCompleted) return;

    next.whenData(completer.complete);

    if (next.hasError) {
      completer.completeError(
        next.error ?? StateError('unknown error'),
        next.stackTrace ?? StackTrace.empty,
      );
    }
  }, fireImmediately: true);

  return completer.future.whenComplete(sub.close);
}

/// Helper untuk membaca error provider pertama yang bukan loading.
Future<Object?> readPostsErrorOnce(ProviderContainer container) {
  final completer = Completer<Object?>();

  final sub = container.listen<AsyncValue<List<Post>>>(postListProvider, (
    previous,
    next,
  ) {
    if (next.isLoading || completer.isCompleted) return;

    completer.complete(next.error);
  }, fireImmediately: true);

  return completer.future.whenComplete(sub.close);
}

class CommentListNotifier extends AsyncNotifier<List<Comment>> {
  @override
  Future<List<Comment>> build() async {
    return <Comment>[];
  }

  Future<void> fetchComments(int postId) async {
    state = const AsyncLoading();

    try {
      final comments = await ref
          .read(commentRepositoryProvider)
          .fetchComments(postId);

      state = AsyncData(comments);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }
}

final commentListProvider =
    AsyncNotifierProvider<CommentListNotifier, List<Comment>>(
      CommentListNotifier.new,
    );
