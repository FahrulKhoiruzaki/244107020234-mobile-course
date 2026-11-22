# Tahap 4 — Step 5: Presentation, DI, dan Verifikasi

Dokumen ini mencatat implementasi Praktikum 3 dari [Codelab Clean Architecture Week 7](https://jti-polinema.github.io/flutter-codelab/07-minggu-7-clean-architecture/index.html#1) pada target `07-week-7-clean-architecture/`.

## Scope

Tahap ini hanya mengerjakan Step 5:

- menghubungkan presentation feature `notes` dengan Domain Tahap 3;
- menambahkan Dependency Injection dengan Riverpod;
- memindahkan halaman daftar catatan ke feature presentation;
- memastikan widget membaca state melalui provider;
- menambahkan pengujian use case dengan fake repository;
- melakukan pemeriksaan boundary dan verifikasi yang tersedia.

Pada akhir Tahap 4, Step 6 / AI Challenge belum dimulai. Catatan tersebut adalah historical scope; dokumentasi Step 6 kini tersedia di [step-6-ai-challenge.md](step-6-ai-challenge.md). Refactoring posts, settings, sinkronisasi, dan kontrak CRUD lain tidak diperluas karena berada di luar scope Step 5.

## Struktur feature setelah Step 5

```text
lib/features/notes/
├── domain/
│   ├── entities/note.dart
│   ├── repositories/note_repository.dart
│   └── usecases/get_notes.dart
├── data/
│   ├── models/note_model.dart
│   └── repositories/note_repository_impl.dart
└── presentation/
    ├── providers/notes_providers.dart
    └── pages/notes_page.dart
```

Arah dependensi yang dipertahankan:

```text
presentation → domain ← data
```

## Provider dan Dependency Injection

`features/notes/presentation/providers/notes_providers.dart` menjadi composition boundary untuk feature notes.

Graph dependency yang digunakan:

```text
notesProvider
    → GetNotes
        → NoteRepository (interface)
            → NoteRepositoryImpl
                → openNotesDb
                    → SQLite
```

Provider inti:

```dart
final noteRepositoryProvider = Provider<NoteRepository>((ref) {
  return NoteRepositoryImpl(openDb: openNotesDb);
});

final getNotesProvider = Provider<GetNotes>((ref) {
  return GetNotes(ref.watch(noteRepositoryProvider));
});
```

`notesProvider` memanggil use case, lalu mengubah `Failure` menjadi error yang bisa ditampilkan oleh state presentation:

```dart
final notesProvider = FutureProvider<List<Note>>((ref) async {
  final result = await ref.watch(getNotesProvider).call();
  if (result.failure != null) {
    throw Exception(result.failure!.message);
  }
  return result.notes;
});
```

Widget tidak membuat `NoteRepositoryImpl`, membuka database, atau memanggil use case secara manual.

Provider legacy untuk CRUD/sync, `dirty` count, dan force-offline diekspos melalui file provider feature sebagai compatibility seam. Ini menjaga perilaku Week 5 tetap tersedia tanpa memperluas scope menjadi refactoring Step 6. Provider settings dan posts tetap berada di provider lama karena belum menjadi bagian Step 5 notes.

## Presentation

`features/notes/presentation/pages/notes_page.dart` sekarang menjadi halaman route `/`.

Halaman tersebut:

- membaca `notesProvider`;
- menampilkan loading, error, empty, dan data state;
- menyediakan tombol retry dengan `ref.invalidate(notesProvider)`;
- menyediakan pull-to-refresh;
- menggunakan entity Domain `Note` melalui `NoteTile`;
- mempertahankan tombol tambah, hapus, sinkronisasi, force-offline, dirty count, dan navigasi Week 5;
- tidak mengandung SQL, Dio, JSON parsing, atau instansiasi repository.

`lib/main.dart` kini berperan sebagai composition root, theme holder, dan router. Definisi `NotesPage` serta dialog tambah catatan tidak lagi berada di `main.dart`.

`lib/widgets/note_tile.dart` tidak lagi mengimpor `data/local/note.dart`; widget menerima entity Domain dari `features/notes/domain/entities/note.dart`.

## Pengujian use case

`test/get_notes_test.dart` menggunakan `FakeNoteRepository implements NoteRepository`.

Skenario yang diuji:

1. repository fake mengembalikan satu catatan dengan `failure == null`;
2. repository fake mengembalikan `LocalFailure` dan daftar kosong tanpa exception dari `GetNotes`.

Test tidak menggunakan SQLite, Dio, Firebase, atau jaringan sungguhan.

## Verifikasi

Perintah formatting dijalankan terhadap file presentation, provider, main, widget, dan test.

Pemeriksaan boundary presentation:

```bash
rg 'Dio\(|openDatabase|getDatabasesPath|FlutterSecureStorage|SharedPreferences\.getInstance|jsonDecode' \
  lib/features/*/presentation lib/pages lib/widgets
```

Tidak ada hasil dari pemeriksaan tersebut.

Pemeriksaan Domain/Core:

```bash
rg "import 'package:(flutter|dio|sqflite|firebase)" \
  lib/features/*/domain lib/core
```

Tidak ada hasil.

`flutter analyze` dan `flutter test` dicoba dari target, tetapi tetap **BLOCKED** karena repository tidak memiliki `pubspec.yaml` dan metadata dependency. Error package yang tidak dapat di-resolve bukan merupakan bukti bahwa implementasi lulus analyze/test. Tidak ada hasil PASS palsu yang dibuat.

Screenshot tidak dibuat karena aplikasi tidak dapat dijalankan tanpa metadata Flutter/dependency. Kriteria visual before/after dicatat sebagai belum tersedia, bukan diklaim selesai.

## Checklist Step 5

- [x] Provider repository mengembalikan `NoteRepositoryImpl` dengan `openNotesDb`.
- [x] Provider `GetNotes` menggunakan interface repository.
- [x] `notesProvider` menggunakan use case.
- [x] `NotesPage` berada di feature presentation.
- [x] Loading/error/empty/data dan retry tersedia.
- [x] Widget tidak mengakses SQLite, Dio, JSON, atau repository concrete.
- [x] `NoteTile` menggunakan entity Domain.
- [x] Fake repository menguji success dan `LocalFailure`.
- [x] Arah dependensi `presentation → domain ← data` dipertahankan.
- [x] `flutter analyze` dicoba dan blocker dilaporkan jujur.
- [x] `flutter test` dicoba dan blocker dilaporkan jujur.
- [ ] Analyze bersih — BLOCKED oleh metadata dependency.
- [ ] Test lulus — BLOCKED oleh metadata dependency.
- [ ] Screenshot before/after — tidak tersedia karena aplikasi tidak dapat dijalankan.
- [x] Pada akhir Tahap 4, Step 6 belum dimulai (historical status; kini sudah didokumentasikan).
