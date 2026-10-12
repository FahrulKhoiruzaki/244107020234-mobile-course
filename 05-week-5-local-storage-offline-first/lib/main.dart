
import 'package:flutter/material.dart';

import 'data/local/note.dart';
import 'data/prefs.dart';
import 'data/repositories/note_repository.dart';
import 'data/sync.dart';
import 'pages/settings_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const NotesApp());
}

// ============================================================
// APLIKASI UTAMA
// ============================================================

class NotesApp extends StatefulWidget {
  const NotesApp({super.key});

  @override
  State<NotesApp> createState() => _NotesAppState();
}

class _NotesAppState extends State<NotesApp> {
  bool _darkMode = false;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _initializePrefs();
  }

  // Memuat preferensi dan menyimpan waktu aplikasi dibuka.
  Future<void> _initializePrefs() async {
    try {
      final darkMode = await AppPrefs.getDarkMode();
      await AppPrefs.saveLastOpened();

      if (!mounted) return;

      setState(() {
        _darkMode = darkMode;
        _ready = true;
      });
    } catch (error) {
      debugPrint('Gagal memuat preferensi: $error');

      if (!mounted) return;

      setState(() {
        _ready = true;
      });
    }
  }

  // Menyimpan perubahan tema.
  Future<void> _changeTheme(bool value) async {
    try {
      await AppPrefs.setDarkMode(value);

      if (!mounted) return;

      setState(() {
        _darkMode = value;
      });
    } catch (error) {
      debugPrint('Gagal menyimpan tema: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Offline Notes',

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
        ),
        useMaterial3: true,
      ),

      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),

      themeMode: _darkMode ? ThemeMode.dark : ThemeMode.light,

      home: NotesPage(
        darkMode: _darkMode,
        onThemeChanged: _changeTheme,
      ),
    );
  }
}

// ============================================================
// HALAMAN DAFTAR CATATAN
// ============================================================

class NotesPage extends StatefulWidget {
  const NotesPage({
    super.key,
    required this.darkMode,
    required this.onThemeChanged,
  });

  final bool darkMode;
  final ValueChanged<bool> onThemeChanged;

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final NoteRepository _repository = NoteRepository();

  List<Note> _notes = [];

  bool _loading = true;
  bool _forceOffline = false;
  bool _syncing = false;
  bool _addingNote = false;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  // ----------------------------------------------------------
  // MEMUAT CATATAN DARI SQLITE
  // ----------------------------------------------------------

  Future<void> _loadNotes() async {
    try {
      final notes = await _repository.fetchNotes();

      if (!mounted) return;

      setState(() {
        _notes = notes;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat catatan: $error'),
        ),
      );
    }
  }

  // ----------------------------------------------------------
  // MENAMBAHKAN CATATAN
  // ----------------------------------------------------------

  Future<void> _addNote() async {
    // Mencegah dialog tambah catatan dibuka berulang kali.
    if (_addingNote) return;

    setState(() {
      _addingNote = true;
    });

    try {
      // Dialog mengelola controller-nya sendiri.
      // Controller tidak dibuat atau di-dispose di fungsi ini.
      final result = await showDialog<Map<String, String>>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return const AddNoteDialog();
        },
      );

      if (!mounted || result == null) return;

      final title = result['title']?.trim() ?? '';
      final body = result['body']?.trim() ?? '';

      if (title.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Judul catatan tidak boleh kosong'),
          ),
        );
        return;
      }

      // Menyimpan catatan melalui repository SQLite.
      await _repository.addNote(
        title: title,
        body: body,
      );

      if (!mounted) return;

      await _loadNotes();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Catatan berhasil disimpan'),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan catatan: $error'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _addingNote = false;
        });
      }
    }
  }

  // ----------------------------------------------------------
  // MENGHAPUS CATATAN
  // ----------------------------------------------------------

  Future<void> _deleteNote(int id) async {
    try {
      await _repository.deleteNote(id);

      if (!mounted) return;

      await _loadNotes();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Catatan berhasil dihapus'),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus catatan: $error'),
        ),
      );
    }
  }

  // ----------------------------------------------------------
  // FORCE OFFLINE
  // ----------------------------------------------------------

  void _changeOffline(bool value) {
    setState(() {
      _forceOffline = value;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          value
              ? 'Force Offline diaktifkan'
              : 'Force Offline dinonaktifkan',
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // SIMULASI SINKRONISASI
  // ----------------------------------------------------------

  Future<void> _syncNotes() async {
    if (_syncing) return;

    setState(() {
      _syncing = true;
    });

    try {
      final processed = await syncNotes(
        _repository,
        forceOffline: _forceOffline,
      );

      if (!mounted) return;

      await _loadNotes();

      if (!mounted) return;

      final String message;

      if (_forceOffline) {
        message =
            'Force Offline aktif. Sinkronisasi tidak dijalankan.';
      } else if (processed == 0) {
        message = 'Tidak ada catatan yang perlu disinkronkan.';
      } else {
        message =
            '$processed catatan berhasil disinkronkan (simulasi).';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sinkronisasi gagal: $error'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _syncing = false;
        });
      }
    }
  }

  // ----------------------------------------------------------
  // MEMBUKA PENGATURAN
  // ----------------------------------------------------------

  Future<void> _openSettings() async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => SettingsPage(
          darkMode: widget.darkMode,
          onThemeChanged: widget.onThemeChanged,
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // TAMPILAN DAFTAR CATATAN
  // ----------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Notes'),
        actions: [
          IconButton(
            onPressed: _openSettings,
            icon: const Icon(Icons.settings),
            tooltip: 'Pengaturan',
          ),
          IconButton(
            onPressed: _loading ? null : _loadNotes,
            icon: const Icon(Icons.refresh),
            tooltip: 'Muat ulang catatan',
          ),
        ],
      ),

      body: Column(
        children: [
          // Status offline aplikasi.
          SwitchListTile(
            title: const Text(
              'Force Offline',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              _forceOffline
                  ? 'Aktif — sinkronisasi dinonaktifkan'
                  : 'Nonaktif — sinkronisasi diizinkan',
            ),
            secondary: Icon(
              _forceOffline
                  ? Icons.cloud_off
                  : Icons.cloud_done,
            ),
            value: _forceOffline,
            onChanged: _changeOffline,
          ),

          const Divider(height: 1),

          // Tombol sinkronisasi.
          Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _syncing ? null : _syncNotes,
                icon: const Icon(Icons.sync),
                label: Text(
                  _syncing
                      ? 'Memproses...'
                      : 'Sinkronkan Catatan',
                ),
              ),
            ),
          ),

          // Isi daftar catatan.
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : _notes.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.note_alt_outlined,
                                size: 64,
                              ),
                              SizedBox(height: 12),
                              Text(
                                'Belum ada catatan',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Tekan tombol Tambah Catatan '
                                'untuk membuat catatan baru.',
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _notes.length,
                        itemBuilder: (context, index) {
                          final note = _notes[index];

                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 5,
                            ),
                            child: ListTile(
                              leading: Icon(
                                note.dirty
                                    ? Icons.cloud_upload_outlined
                                    : Icons.cloud_done_outlined,
                                color: note.dirty
                                    ? Colors.orange
                                    : Colors.green,
                              ),
                              title: Text(note.title),
                              subtitle: Text(
                                '${note.body.isEmpty ? 'Tanpa isi' : note.body}\n'
                                'Status: ${note.dirty ? 'Belum disinkronkan' : 'Tersinkronisasi (simulasi)'}',
                              ),
                              isThreeLine: true,
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                ),
                                tooltip: 'Hapus catatan',
                                onPressed: note.id == null
                                    ? null
                                    : () => _deleteNote(note.id!),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addingNote ? null : _addNote,
        icon: const Icon(Icons.add),
        label: Text(
          _addingNote ? 'Membuka...' : 'Tambah Catatan',
        ),
      ),
    );
  }
}

// ============================================================
// DIALOG TAMBAH CATATAN
// ============================================================
//
// Controller dimiliki oleh State dialog ini.
// Flutter akan memanggil dispose() ketika State dilepas.
// Dengan begitu, controller tidak langsung dihancurkan
// oleh fungsi pemanggil ketika dialog sedang ditutup.
// ============================================================

class AddNoteDialog extends StatefulWidget {
  const AddNoteDialog({super.key});

  @override
  State<AddNoteDialog> createState() => _AddNoteDialogState();
}

class _AddNoteDialogState extends State<AddNoteDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController();
    _bodyController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();

    super.dispose();
  }

  void _save() {
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Judul catatan wajib diisi'),
        ),
      );
      return;
    }

    // Mengembalikan data ke halaman daftar catatan.
    // Penyimpanan SQLite dilakukan oleh NotesPage.
    Navigator.of(context).pop(
      <String, String>{
        'title': title,
        'body': body,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tambah Catatan'),

      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Judul',
                hintText: 'Masukkan judul catatan',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _save(),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: _bodyController,
              minLines: 3,
              maxLines: 5,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Isi catatan',
                hintText: 'Tuliskan catatan di sini',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),

      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Batal'),
        ),

        FilledButton.icon(
          onPressed: _save,
          icon: const Icon(Icons.save_outlined),
          label: const Text('Simpan'),
        ),
      ],
    );
  }
}