import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/announcements/presentation/pages/announcements_page.dart';

/// Compatibility route for existing `/posts` links.
class PostsPage extends ConsumerWidget {
  const PostsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const AnnouncementsPage();
  }
}
