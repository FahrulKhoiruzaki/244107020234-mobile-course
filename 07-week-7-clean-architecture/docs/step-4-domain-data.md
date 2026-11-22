# Tahap 3 — Step 4: Domain dan Data per feature

Dokumen ini mencatat implementasi Praktikum 2 pada Codelab [Clean Architecture Week 7](https://jti-polinema.github.io/flutter-codelab/07-minggu-7-clean-architecture/index.html#1).

## Scope

Tahap ini menggunakan target `07-week-7-clean-architecture/` dan hasil audit Tahap 2 sebagai dasar. Fokusnya hanya memisahkan Domain dan Data untuk feature `notes`.

Yang dikerjakan:

- membuat entity Domain murni;
- memindahkan kontrak repository ke Domain;
- menambahkan use case pembacaan catatan;
- membuat model Data untuk mapping SQLite;
- membuat implementasi repository di Data;
- menerjemahkan error persistence menjadi `Failure` yang eksplisit;
- menginjeksikan fungsi pembuka database ke repository.

Yang belum dikerjakan:

- refactoring page/widget;
- provider dan Dependency Injection Riverpod;
- pemindahan state notifier;
- integrasi use case ke presentation;
- refactoring posts/settings dan sinkronisasi.

Item tersebut merupakan scope Step 5 / Tahap 4.

## Struktur feature-first

```text
lib/
├── core/
│   └── failures.dart
└── features/
    └── notes/
        ├── domain/
        │   ├── entities/note.dart
        │   ├── repositories/note_repository.dart
        │   └── usecases/get_notes.dart
        └── data/
            ├── models/note_model.dart
            └── repositories/note_repository_impl.dart
```

Arah dependensi:

```text
presentation → domain ← data
```

Entity dan interface repository tidak mengetahui SQLite. Implementasi Data mengimpor kontrak Domain, bukan sebaliknya.

## Implementasi Domain

### Failure

`lib/core/failures.dart` mendefinisikan tipe dasar `Failure` serta `LocalFailure` dan `NetworkFailure`. Repository tidak mengekspos exception mentah ke caller.

```dart
sealed class Failure {
  const Failure(this.message);

  final String message;
}
```

Tahap ini menggunakan `LocalFailure` untuk kegagalan operasi SQLite. `NetworkFailure` disiapkan sebagai vocabulary lintas feature untuk tahap berikutnya.

### Entity

`lib/features/notes/domain/entities/note.dart` hanya memuat data bisnis:

- `id` opsional;
- `title`;
- `body`;
- `updatedAt`;
- `dirty`.

File ini tidak memiliki `toMap`, `fromMap`, nama kolom SQLite, atau import package infrastruktur.

### Repository contract

`lib/features/notes/domain/repositories/note_repository.dart` menjadi boundary abstrak:

```dart
abstract interface class NoteRepository {
  Future<({List<Note> notes, Failure? failure})> fetchNotes();

  Future<({Note? note, Failure? failure})> addNote({
    required String title,
    String body = '',
  });
}
```

Dart records membuat data sukses dan kegagalan terlihat eksplisit tanpa membocorkan tipe database kepada Domain. Implementasi dapat diganti dengan fake repository pada tahap testing.

### Use case

`GetNotes` di `domain/usecases/get_notes.dart` menyediakan entry point untuk membaca catatan melalui kontrak repository. Use case belum dihubungkan ke provider karena wiring tersebut berada di Step 5.

## Implementasi Data

### NoteModel

`NoteModel` bertanggung jawab atas serialisasi persistence:

- `toMap()` menulis nama kolom SQLite `updated_at` dan `dirty`;
- `updatedAt` disimpan sebagai ISO-8601 string;
- `dirty` disimpan sebagai integer `1` atau `0`;
- `fromMap()` membaca nilai row dengan fallback aman untuk tipe yang invalid atau hilang;
- `toEntity()` mengubah model Data menjadi `Note` Domain.

Fallback yang digunakan:

- ID numerik dikonversi ke `int` jika tersedia;
- `title` dan `body` menjadi string kosong jika bukan `String`;
- tanggal invalid/hilang menjadi epoch;
- `dirty` hanya bernilai `true` untuk nilai numerik `1`.

Dengan demikian, entity tidak membawa detail schema atau parsing SQLite.

### NoteRepositoryImpl

`NoteRepositoryImpl` mengimplementasikan `NoteRepository` dan menerima dependency database melalui constructor:

```dart
NoteRepositoryImpl({required Future<Database> Function() openDb})
```

`fetchNotes()`:

1. membuka database melalui fungsi yang diinjeksi;
2. membaca tabel `notes` dengan urutan `updated_at DESC`;
3. memetakan row menjadi `NoteModel`;
4. mengubah model menjadi entity `Note`;
5. mengembalikan record notes tanpa failure jika sukses.

`addNote()`:

1. membuat `NoteModel` baru dengan `DateTime.now()`;
2. menetapkan `dirty: true` agar catatan baru masuk kandidat sinkronisasi;
3. memasukkan map ke tabel `notes`;
4. mengembalikan entity dengan ID SQLite yang baru;
5. menerjemahkan error database menjadi `LocalFailure`.

Pesan failure dibuat stabil dan user-facing:

- `Gagal memuat catatan dari penyimpanan lokal.`
- `Gagal menambahkan catatan ke penyimpanan lokal.`

Exception mentah tidak dikembalikan melalui kontrak Domain.

## Verifikasi yang dilakukan

### Formatting

Perintah `dart format` dijalankan terhadap enam file baru/yang diubah pada Domain dan Data. Pemeriksaan akhir menghasilkan:

```text
Formatted 6 files (0 changed) in 0.00 seconds.
```

### Boundary Domain

Pencarian import package infrastruktur pada `lib/core` dan `lib/features/notes/domain` tidak menghasilkan output:

```bash
rg -n "import 'package:(flutter|dio|sqflite|firebase|shared_preferences)" \
  07-week-7-clean-architecture/lib/features/notes/domain \
  07-week-7-clean-architecture/lib/core
```

Artinya, Domain/Core yang dibuat pada tahap ini tidak mengimpor Flutter, Dio, SQLite, Firebase, atau SharedPreferences.

### Flutter analyze

`flutter analyze` dicoba dari `07-week-7-clean-architecture/`, tetapi tidak dapat menjadi verifikasi PASS. Repository tidak menyediakan `pubspec.yaml` atau metadata dependency. Output aktual memuat error unresolved package seperti:

```text
Target of URI doesn't exist: 'package:path/path.dart'
Target of URI doesn't exist: 'package:sqflite/sqflite.dart'
Target of URI doesn't exist: 'package:shared_preferences/shared_preferences.dart'
Target of URI doesn't exist: 'package:dio/dio.dart'
Target of URI doesn't exist: 'package:flutter_riverpod/flutter_riverpod.dart'
```

### Flutter test

`flutter test` belum dapat dijalankan secara valid karena blocker metadata/dependency yang sama. Tidak ada hasil test palsu yang dibuat atau diklaim.

## Bukti visual

Screenshot tidak dibuat. Aplikasi tidak dapat dijalankan tanpa metadata Flutter/dependency, dan tahap ini belum memiliki hasil UI yang perlu dibuktikan secara visual.

## Checklist Step 4

- [x] Entity `Note` dipisahkan dari mapping SQLite.
- [x] Kontrak `NoteRepository` berada di Domain.
- [x] `GetNotes` use case ditambahkan.
- [x] `NoteModel` berada di Data.
- [x] `NoteRepositoryImpl` berada di Data.
- [x] Database opener diinjeksikan melalui constructor.
- [x] Row SQLite dikonversi menjadi entity Domain.
- [x] Kegagalan persistence dikonversi menjadi `LocalFailure`.
- [x] Domain/Core bebas dari import infrastruktur.
- [x] Presentation dan provider tidak diubah karena berada di luar scope Step 4.
- [ ] `flutter analyze` PASS — BLOCKED oleh metadata dependency.
- [ ] `flutter test` PASS — BLOCKED oleh metadata dependency.
- [ ] Screenshot aplikasi — tidak dibuat karena aplikasi tidak dapat dijalankan.
