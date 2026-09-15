import 'package:flutter/material.dart';

/// Halaman statistik sederhana aplikasi Todo.
class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistik'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart,
              size: 64,
            ),
            SizedBox(height: 16),
            Text(
              'Statistik Todo',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text('Lihat perkembangan tugas kamu di sini.'),
          ],
        ),
      ),
    );
  }
}