import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StatsNotifier extends AsyncNotifier<List<String>> {
  final Random _random = Random();

  @override
  Future<List<String>> build() async {
    return _fetchStats();
  }

  Future<List<String>> _fetchStats() async {
    await Future.delayed(const Duration(seconds: 2));

    if (_random.nextDouble() < 0.3) {
      throw Exception('Gagal mengambil data statistik');
    }

    return [ 'Total Pengguna: 120', 'Pesanan Hari Ini: 45', 'Pendapatan: Rp2.500.000', ];
  }

  Future<void> retry() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchStats);
  }
}

final statsProvider =
    AsyncNotifierProvider<StatsNotifier, List<String>>(
  StatsNotifier.new,
);