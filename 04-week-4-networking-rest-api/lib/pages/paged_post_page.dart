import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/network_errors.dart';
import '../data/paged_posts.dart';

class PagedPostPage extends ConsumerStatefulWidget {
  const PagedPostPage({super.key});

  @override
  ConsumerState<PagedPostPage> createState() => _PagedPostPageState();
}

class _PagedPostPageState extends ConsumerState<PagedPostPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(pagedPostsProvider.notifier).loadNextPage();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pagedState = ref.watch(pagedPostsProvider);

    if (pagedState.error != null && pagedState.items.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Posts Pagination')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  friendlyErrorMessage(pagedState.error!),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () {
                    ref.read(pagedPostsProvider.notifier).loadFirstPage();
                  },
                  child: const Text('Coba lagi'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (pagedState.items.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Posts Pagination')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Posts Pagination')),
      body: RefreshIndicator(
        onRefresh: () => ref.read(pagedPostsProvider.notifier).loadFirstPage(),
        child: ListView.builder(
          controller: _scrollController,
          itemCount: pagedState.items.length + 1,
          itemBuilder: (context, index) {
            if (index == pagedState.items.length) {
              if (!pagedState.hasMore) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: Text('Semua data termuat.')),
                );
              }

              if (pagedState.error != null) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: Column(
                      children: [
                        Text(friendlyErrorMessage(pagedState.error!)),
                        TextButton(
                          onPressed: () {
                            ref
                                .read(pagedPostsProvider.notifier)
                                .loadNextPage();
                          },
                          child: const Text('Coba lagi'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final post = pagedState.items[index];

            return ListTile(
              leading: CircleAvatar(child: Text(post.id.toString())),
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
            );
          },
        ),
      ),
    );
  }
}
