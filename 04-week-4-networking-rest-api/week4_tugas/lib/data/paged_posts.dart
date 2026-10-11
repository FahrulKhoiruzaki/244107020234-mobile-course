import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models/post.dart';
import 'providers.dart';

class PagedPostsState {
  const PagedPostsState({
    this.items = const [],
    this.page = 0,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.error,
  });

  final List<Post> items;
  final int page;
  final bool isLoadingMore;
  final bool hasMore;
  final Object? error;
}

class PagedPostsNotifier extends Notifier<PagedPostsState> {
  @override
  PagedPostsState build() {
    Future.microtask(loadFirstPage);
    return const PagedPostsState();
  }

  Future<void> loadFirstPage() async {
    state = const PagedPostsState();
    try {
      final items = await ref
          .read(postRepositoryProvider)
          .fetchPostsPage(page: 1, limit: 10);
      state = PagedPostsState(
        items: items,
        page: 1,
        hasMore: items.length == 10,
      );
    } catch (error) {
      state = PagedPostsState(error: error, hasMore: false);
    }
  }

  Future<void> loadNextPage() async {
    if (state.isLoadingMore || !state.hasMore || state.page == 0) return;

    final currentItems = state.items;
    final currentPage = state.page;

    state = PagedPostsState(
      items: currentItems,
      page: currentPage,
      isLoadingMore: true,
      hasMore: state.hasMore,
    );

    try {
      final nextPage = currentPage + 1;
      final nextItems = await ref
          .read(postRepositoryProvider)
          .fetchPostsPage(page: nextPage, limit: 10);

      state = PagedPostsState(
        items: [...currentItems, ...nextItems],
        page: nextPage,
        hasMore: nextItems.length == 10,
      );
    } catch (error) {
      state = PagedPostsState(
        items: currentItems,
        page: currentPage,
        hasMore: true,
        error: error,
      );
    }
  }
}

final pagedPostsProvider =
    NotifierProvider<PagedPostsNotifier, PagedPostsState>(
  PagedPostsNotifier.new,
);
