import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/providers.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final darkMode = ref.watch(darkModeProvider);
    final lastOpened = ref.watch(lastOpenedProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: darkMode.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Gagal memuat tema: $error')),
        data: (value) => ListView(
          children: [
            SwitchListTile(
              title: const Text('Mode Gelap'),
              subtitle: const Text('Simpan preferensi tema aplikasi'),
              value: value,
              onChanged: (next) => ref.read(darkModeProvider.notifier).toggle(next),
            ),
            const Divider(),
            lastOpened.when(
              loading: () => const ListTile(
                leading: Icon(Icons.access_time),
                title: Text('Terakhir Dibuka'),
                subtitle: Text('Memuat...'),
              ),
              error: (error, _) => ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text('Terakhir Dibuka'),
                subtitle: Text('Gagal memuat: $error'),
              ),
              data: (value) => ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text('Terakhir Dibuka'),
                subtitle: Text(value ?? 'Belum ada data'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
