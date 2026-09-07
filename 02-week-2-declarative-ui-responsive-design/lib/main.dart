import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

void main() => runApp(const AcademicOverviewApp());

class AcademicOverviewApp extends StatefulWidget {
  const AcademicOverviewApp({super.key});

  @override
  State<AcademicOverviewApp> createState() => _AcademicOverviewAppState();
}

class _AcademicOverviewAppState extends State<AcademicOverviewApp>{
  bool _isDarkMode = false;

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Academic Overview',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.teal,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.teal,
        brightness: Brightness.dark,
      ),
      themeMode: _isDarkMode? ThemeMode.dark : ThemeMode.light,
      home: OverviewHomePage(
        isDark: _isDarkMode,
        onThemeToggled: (val) => setState(() => _isDarkMode = val),
      ),
    );
  }
}

class OverviewHomePage extends StatelessWidget{
  const OverviewHomePage({required this.isDark, required this.onThemeToggled, super.key,});
  
  final bool isDark;
  final ValueChanged<bool> onThemeToggled;
  static const double kWideBreakpoint = 700;

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text('Academic Overview', style: TextStyle(fontWeight: FontWeight.w600)),
        actions: [
          Semantics(
            label: 'Tombol tema gelap dan tema terang',
            child: Row(
              children: [
                Icon(isDark ? Icons.nights_stay_rounded : Icons.wb_sunny_rounded, size: 20),
                const SizedBox(width: 8),
                CupertinoSwitch(
                  value: isDark,
                  onChanged: onThemeToggled,
                ),
                const SizedBox(width: 16),
              ],
            ),
          )
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints){
          final isWide = constraints.maxWidth >= kWideBreakpoint;
          final crossAxisCount = isWide ? 2 : 1;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Semantics(
                label: 'Profil Akademik Mahasiswa',
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: const Text('FK', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Fahrul Khoiruzaki',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Teknik Informatika • Senester 5',
                              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              GridView.count(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: isWide ? 2.8 : 2.4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: const[
                  InfoCard(title: 'IPK Sementara', value: '3.48', icon: Icons.school_rounded),
                  InfoCard(title: 'SKS Tempuh', value: '144 SKS', icon: Icons.book_rounded),
                  InfoCard(title: 'Kehadiran Kelas', value: '96%', icon: Icons.verified_rounded),
                  InfoCard(title: 'Tugas Selesai', value: '14 / 15', icon: Icons.task_alt_rounded),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class InfoCard extends StatelessWidget{
  const InfoCard({required this.title, required this.value, required this.icon, super.key});
  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context){
    return Semantics(
      label: 'Informasi $title bernilai $value',
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.6),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}