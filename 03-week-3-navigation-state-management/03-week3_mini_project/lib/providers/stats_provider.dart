import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'todo_provider.dart';

class StatsNotifier extends AsyncNotifier<List<String>> {
  @override
  Future<List<String>> build() {
    final todos = ref.watch(todoListProvider);
    return _fetchStats(todos);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    final todos = ref.read(todoListProvider);
    state = await AsyncValue.guard(() => _fetchStats(todos));
  }

  Future<List<String>> _fetchStats(List<Todo> todos) async {
    await Future.delayed(const Duration(seconds: 2));

    final gagal = Random().nextDouble() < 0.3;
    if (gagal) {
      throw Exception('Gagal terhubung ke server statistik');
    }

    final selesai = todos.where((t) => t.done).length;
    final aktif = todos.length - selesai;

    return [
      'Total tugas: ${todos.length}',
      'Tugas selesai: $selesai',
      'Tugas aktif: $aktif',
    ];
  }
}

final statsProvider =
    AsyncNotifierProvider<StatsNotifier, List<String>>(StatsNotifier.new);
