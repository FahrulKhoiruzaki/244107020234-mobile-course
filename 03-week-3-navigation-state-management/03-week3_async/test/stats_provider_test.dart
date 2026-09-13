import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:week3_async/providers/stats_provider.dart';

void main() {
  test(
    'StatsNotifier mengembalikan 3 data statistik ketika berhasil',
    () async {
      final container = ProviderContainer();

      addTearDown(container.dispose);

      final result = await container.read(statsProvider.future);

      expect(result.length, 3);
      expect(result[0], 'Total Pengguna: 120');
      expect(result[1], 'Pesanan Hari Ini: 45');
      expect(result[2], 'Pendapatan: Rp2.500.000');
    },
  );
}