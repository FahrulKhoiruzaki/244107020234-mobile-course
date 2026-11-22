# Week 7 — Clean Architecture

Implementasi praktikum Clean Architecture berdasarkan [Codelab Week 7](https://jti-polinema.github.io/flutter-codelab/07-minggu-7-clean-architecture/index.html#1).

## Status tahap

### Tahap 3 — Step 4: Domain dan Data per feature

**Status:** selesai pada scope Domain dan Data untuk feature `notes`.

Project target tahap ini adalah folder `07-week-7-clean-architecture/`. Baseline source dan test berasal dari project Week 5 offline-first. Refactoring presentation, provider, dan Dependency Injection sengaja belum dilakukan karena termasuk Step 5 / Tahap 4.

Dokumentasi implementasi: [Step 4 — Domain dan Data per feature](docs/step-4-domain-data.md)

## Struktur target yang ditambahkan

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

Arah dependensi yang dijaga:

```text
presentation → domain ← data
```

`domain` tidak mengimpor Flutter, Dio, SQLite, Firebase, atau package infrastruktur lain. Mapping SQLite berada di `NoteModel`, sedangkan kontrak repository berada di domain dan implementasinya berada di data.

## Verifikasi

- `dart format` pada enam file Domain/Data: **berhasil**, 0 file berubah pada pemeriksaan akhir.
- Pemeriksaan import infrastruktur pada `lib/core` dan `lib/features/notes/domain`: **berhasil**, tidak ada hasil.
- `flutter analyze`: **BLOCKED/FAIL**, karena metadata dependency tidak tersedia dan `pubspec.yaml` tidak ada di repository. Output menunjukkan URI package seperti `sqflite`, `path`, `dio`, `flutter_riverpod`, dan `shared_preferences` tidak dapat di-resolve.
- `flutter test`: belum dapat dijalankan secara valid karena alasan yang sama; tidak diklaim PASS.
- Screenshot: tidak dibuat. Tidak ada aplikasi yang dapat dijalankan tanpa metadata Flutter/dependency, sehingga tidak ada bukti visual yang boleh diklaim.

### Tahap 4 — Step 5: Presentation, DI, dan Verifikasi

**Status:** selesai pada scope presentation dan Dependency Injection feature `notes`.

Step 5 menghubungkan halaman daftar catatan dengan `GetNotes`, interface `NoteRepository`, `NoteRepositoryImpl`, dan `openNotesDb` melalui provider Riverpod. `NotesPage` dipindahkan ke `lib/features/notes/presentation/pages/notes_page.dart`; wiring provider berada di `lib/features/notes/presentation/providers/notes_providers.dart`; `NoteTile` menggunakan entity Domain. CRUD/sync Week 5 yang belum memiliki kontrak Domain dipertahankan melalui compatibility seam agar perilaku existing tidak hilang.

Dokumentasi: [Step 5 — Presentation, DI, dan Verifikasi](docs/step-5-presentation-di.md)

`dart format` dan pemeriksaan boundary Domain/Core/presentation dijalankan. `flutter analyze` dan `flutter test` dicoba tetapi **BLOCKED** karena `pubspec.yaml` dan metadata dependency tidak tersedia; keduanya tidak diklaim PASS. Screenshot tidak dibuat karena aplikasi tidak dapat dijalankan tanpa metadata Flutter/dependency. Step 6 / AI Challenge belum dimulai.

### Tahap 5 — Step 6: AI Challenge

**Status:** selesai pada scope dokumentasi dan analisis proposal arsitektur AI. Tidak ada source code aplikasi, test, dependency, `pubspec`, konfigurasi, atau file Week 6 yang diubah.

Dokumentasi: [Step 6 — AI Challenge](docs/step-6-ai-challenge.md)

Step 6 mendokumentasikan prompt AI, excerpt output awal yang grounded pada source Campus Notify Week 6, perbandingan dengan keputusan final yang sudah diterapkan pada feature `notes`, alasan menerima/menolak/menyesuaikan proposal, serta tepat tiga verification command dengan hasil aktual. Auth dan announcements **tidak diklaim sudah dimigrasikan**; target Week 7 tetap menjadi implementasi notes dari Step 4–5.

Verifikasi tambahan:

- `dart analyze` pada `lib/core` dan Domain notes: **PASS**, `No issues found!`.
- Tiga scan `rg`: dijalankan dan hasil aktual dicatat di dokumentasi; check 2 menemukan field bisnis `dirty`, sedangkan check 3 menemukan wiring concrete repository di provider composition boundary yang disengaja.
- `flutter analyze`: **BLOCKED**, karena package/dependency tidak dapat di-resolve tanpa metadata Flutter.
- `flutter test`: **BLOCKED**, karena target tidak memiliki `pubspec.yaml`.
- Screenshot UI before/after: **BLOCKED**, karena target tidak runnable. Tidak ada screenshot palsu, placeholder, atau screenshot Week 6 yang direlabel sebagai bukti Stage 5.

Bukti visual alternatif tidak dibuat karena Chrome DevTools tidak tersedia dan tidak ada aplikasi/preview target yang dapat ditampilkan secara valid. Output command aktual dicatat sebagai teks, bukan diklaim sebagai screenshot aplikasi.

Step 7 / Tahap 6 dimulai setelah Stage 5 dan didokumentasikan pada bagian Tahap 6 di atas.


### Tahap 6 — Step 7: Refactoring, Testing, dan Boundary

**Status:** implementasi Step 7 selesai pada scope Week 7; Step 8 belum dimulai.

Feature kedua `announcements` memakai struktur feature-first lengkap:

```text
announcements presentation
  → domain GetAnnouncements
    → domain AnnouncementRepository
      → data AnnouncementRepositoryImpl
        → injected cache loader
          → existing cached_posts/cache-first seam
```

Entity, repository contract, use case, model, repository implementation, provider wiring, dan page berada di `lib/features/announcements/`. Sumber data menggunakan cache `cached_posts` yang sudah ada. Ini adalah local cached-announcements adapter; tidak diklaim sebagai migrasi backend Campus Notify karena endpoint/schema announcements tidak tersedia secara verifiable pada target.

Perubahan Step 7 lainnya:

- `lib/core/format.dart` menambahkan `formatDate`, `normalizeRoute`, dan `parseRouteId` tanpa Flutter atau dependency eksternal.
- `NoteDetailPage` menggunakan formatter pure dan router menggunakan parser pure.
- `Failure` mempertahankan pesan user-facing melalui `toString`; notes dan announcements provider mempertahankan typed `Failure` tanpa membungkusnya dengan generic `Exception`.
- `/announcements` ditambahkan dan `/posts` dipertahankan sebagai compatibility route menuju typed announcements page.
- Fake repository tests ditambahkan untuk announcements dan formatter; notes failure test mengassert pesan friendly.

Dokumentasi lengkap: [Step 7 — Refactoring, Testing, dan Boundary](docs/step-7-refactoring-testing.md)

Verifikasi aktual:

- `dart format`: berhasil, `Formatted 17 files (5 changed) in 0.02 seconds.`
- `dart analyze` pada Core dan Domain: **PASS**, `No issues found!`.
- Boundary scans: hasil aktual dicatat di dokumentasi; Core/Domain bebas import infrastructure, entity hanya memiliki `dirty` sebagai business state, dan concrete repository match berada pada provider composition boundary.
- Scan tambahan presentation raw map/Dio/JSON/exception: tidak menemukan output.
- `flutter analyze`: **BLOCKED/FAIL**, karena target tidak memiliki `pubspec.yaml` dan dependency metadata; actual output diawali `Target of URI doesn't exist: 'package:path/path.dart'` dan exit code `1`.
- `flutter test`: **BLOCKED/FAIL**, karena target tidak memiliki `pubspec.yaml`; actual output `Error: No pubspec.yaml file found.` dan exit code `1`.
- `git diff --check`: **PASS**, exit code `0`.
- Screenshot runtime: **BLOCKED**, karena aplikasi target tidak runnable. Tidak ada placeholder atau screenshot Week 6 yang disalin.
- Week 6, Week 5, dependency, lockfile, dan konfigurasi tidak menjadi bagian perubahan Step 7.

## Riwayat tahap sebelumnya

- [Tahap 1 — Konsep SOLID dan Clean Architecture](../05-week-5-local-storage-offline-first/docs/clean-architecture-concepts.md)
- [Tahap 2 — Audit layer project lama](../05-week-5-local-storage-offline-first/docs/architecture-audit.md)
