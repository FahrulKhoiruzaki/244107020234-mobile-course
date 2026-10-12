
import 'package:flutter/material.dart';

import '../data/prefs.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    super.key,
    required this.darkMode,
    required this.onThemeChanged,
  });

  final bool darkMode;
  final ValueChanged<bool> onThemeChanged;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  DateTime? _lastOpened;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadLastOpened();
  }

  Future<void> _loadLastOpened() async {
    final value = await AppPrefs.getLastOpened();

    if (!mounted) return;

    setState(() {
      _lastOpened = value;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Mode Gelap'),
            subtitle: const Text(
              'Simpan preferensi tema aplikasi',
            ),
            value: widget.darkMode,
            onChanged: widget.onThemeChanged,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.access_time),
            title: const Text('Terakhir Dibuka'),
            subtitle: Text(
              _loading
                  ? 'Memuat...'
                  : _lastOpened?.toLocal().toString() ??
                      'Belum ada data',
            ),
          ),
        ],
      ),
    );
  }
}