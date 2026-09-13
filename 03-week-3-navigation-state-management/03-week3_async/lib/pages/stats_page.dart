import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/stats_provider.dart';

class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
      ),
      body: statsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(),),

        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text( 'Gagal memuat data:\n$error', textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton( 
                onPressed: () { ref.read(statsProvider.notifier).retry();}, child: const Text('Coba lagi'),
              ),
            ],
          ),
        ),

        // Kondisi success.
        data: (stats) => ListView.builder(
          itemCount: stats.length,
          itemBuilder: (context, index) {
            return ListTile( leading: const Icon(Icons.analytics), title: Text(stats[index]),);
          },
        ),
      ),
    );
  }
}