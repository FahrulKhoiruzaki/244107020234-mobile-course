import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/network_errors.dart';
import '../data/paged_posts.dart';

class PagedPostPage extends ConsumerStatefulWidget {
  const PagedPostPage({super.key});

  @override
  ConsumerState<PagedPostPage> createState() => _PagedPostPageState();
}

class _PagedPostPageState extends ConsumerState<PagedPostPage> {
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_controller.hasClients) return;
    if (_controller.position.pixels >=
        _controller.position.maxScrollExtent - 200) {
      ref.read(pagedPostsProvider.notifier).loadNextPage();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onScroll);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pageState = ref.watch(pagedPostsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Posts Pagination'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        actions: [
          IconButton(
            tooltip: 'Muat ulang',
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(pagedPostsProvider.notifier).loadFirstPage(),
          ),
        ],
      ),
      body: pageState.error != null && pageState.items.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      friendlyErrorMessage(pageState.error!),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () => ref
                          .read(pagedPostsProvider.notifier)
                          .loadFirstPage(),
                      child: const Text('Coba lagi'),
                    ),
                  ],
                ),
              ),
            )
          : pageState.items.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: () => ref
                      .read(pagedPostsProvider.notifier)
                      .loadFirstPage(),
                  child: ListView.builder(
                    controller: _controller,
                    itemCount: pageState.items.length + 1,
                    itemBuilder: (context, index) {
                      if (index == pageState.items.length) {
                        if (!pageState.hasMore) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(
                              child: Text('Semua data termuat.'),
                            ),
                          );
                        }
                        if (pageState.error != null) {
                          return Padding(
                            padding: const EdgeInsets.all(16),
                            child: Center(
                              child: Column(
                                children: [
                                  Text(
                                    friendlyErrorMessage(pageState.error!),
                                  ),
                                  TextButton(
                                    onPressed: () => ref
                                        .read(pagedPostsProvider.notifier)
                                        .loadNextPage(),
                                    child: const Text('Coba lagi'),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      final post = pageState.items[index];
                      return ListTile(
                        leading: CircleAvatar(child: Text('${post.id}')),
                        title: Text(
                          post.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          post.body,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () => context.go(
                          '/post/${post.id}',
                          extra: post,
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
