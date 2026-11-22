# Week 7 — Clean Architecture

Implementasi praktikum Clean Architecture berdasarkan [Codelab Week 7](https://jti-polinema.github.io/flutter-codelab/07-minggu-7-clean-architecture/index.html#1).

## Ringkasan final Step 8

Tujuan project ini adalah memisahkan aturan bisnis dari detail Flutter, SQLite, Dio, JSON, dan storage melalui struktur feature-first Clean Architecture. Hasil implementasi mencakup pemisahan Domain/Data untuk `notes`, wiring Presentation/DI dengan Riverpod, feature kedua `announcements` berbasis cache lokal, pure date/route helpers, typed failure boundary, dan fake-based use-case tests.

Arah dependensi final:

```text
presentation → domain ← data
```

- **Presentation:** page, widget, provider, loading/error/empty/data state, retry, dan refresh.
- **Domain:** entity, repository contract, use case, dan failure vocabulary; tidak mengimpor infrastructure.
- **Data:** model, mapping, repository implementation, cache/database/API adapter.
- **Composition boundary:** provider Riverpod merakit implementation Data dan dependency legacy yang masih menjadi compatibility seam.

### Fitur utama

1. `notes`: entity `Note`, `NoteRepository`, `GetNotes`, `NoteModel`, `NoteRepositoryImpl`, `NotesPage`, dan provider feature.
2. `announcements`: entity/model/repository/use case/provider/page typed yang membaca cache `cached_posts` melalui adapter lokal. Ini bukan klaim integrasi backend announcements.
3. Pure helpers: `formatDate`, `normalizeRoute`, dan `parseRouteId` di `lib/core/format.dart`.
4. Compatibility: route `/posts` tetap tersedia dan mengarah ke typed `AnnouncementsPage`; legacy CRUD/sync dipertahankan secara bertahap.

### Stack teknologi

Flutter/Dart source, Riverpod untuk provider dan DI, SQLite/sqflite serta Dio pada compatibility/data seam existing, GoRouter untuk routing, dan fake repository untuk pengujian Domain. Tidak ada dependency atau konfigurasi baru yang ditambahkan pada Step 8.

### Status seluruh tahap

| Tahap | Step | Status |
|---|---:|---|
| Tahap 1 | Step 1–2 — konsep SOLID/Clean Architecture | Selesai — dokumentasi |
| Tahap 2 | Step 3 — audit project lama | Selesai — dokumentasi |
| Tahap 3 | Step 4 — Domain/Data notes | Selesai — implementasi |
| Tahap 4 | Step 5 — Presentation/DI notes | Selesai — implementasi |
| Tahap 5 | Step 6 — AI Challenge | Selesai — dokumentasi |
| Tahap 6 | Step 7 — announcements, helpers, failure, tests | Selesai — implementasi |
| Tahap 7 | Step 8 — finalisasi, refleksi, evidence | Selesai — dokumentasi |

Rincian final ada di [Step 8 — Finalisasi](docs/step-8-finalization.md) dan [Refleksi](docs/reflection.md). Step 8 adalah tahap terakhir; tidak ada tahap/codelab lanjutan yang dimulai.

### Cara menjalankan dan status runtime

Target ini belum merupakan checkout Flutter runnable karena tidak memiliki `pubspec.yaml`, `pubspec.lock`, atau metadata dependency. Runbook berikut bersifat conditional untuk project resmi yang lengkap:

```bash
cd 07-week-7-clean-architecture
flutter pub get
flutter analyze
flutter test
flutter run
```

`flutter analyze` aktual **BLOCKED/FAIL** dengan exit `1` karena package URI tidak dapat di-resolve. `flutter test` aktual **BLOCKED/FAIL** dengan exit `1` dan output `Error: No pubspec.yaml file found.`. Jangan membaca command conditional di atas sebagai hasil PASS.

### Hasil, trade-off, dan batasan

- Pure Core/Domain analyze: **PASS**, `No issues found!`.
- Fake success/failure tests tersedia pada `get_notes_test.dart` dan `get_announcements_test.dart`; eksekusi Flutter test blocked oleh metadata.
- Tiga boundary scan resmi terdokumentasi di [Step 8](docs/step-8-finalization.md) dan [Step 7](docs/step-7-refactoring-testing.md). Check entity mencocokkan `dirty` sebagai business state yang sah; check presentation mencocokkan concrete repository pada provider composition boundary yang disengaja.
- Use case dipakai selektif untuk read boundary yang diuji; tidak dibuat class satu-baris untuk seluruh CRUD/sync legacy.
- Cache seam dan route lama dipertahankan untuk mengurangi risiko behavior change, dengan konsekuensi migrasi belum menyapu seluruh legacy path.
- Manual test sekitar lima menit, verifikasi behavior unchanged, dan screenshot UI before/after **BLOCKED** karena target tidak runnable. Folder existing `screenshot/` kosong; kriteria resmi `screenshots/` belum terpenuhi. Tidak ada placeholder atau screenshot Week 6 yang direlabel.

### Referensi

- [Codelab Clean Architecture Week 7](https://jti-polinema.github.io/flutter-codelab/07-minggu-7-clean-architecture/index.html#1)
- [Flutter App Architecture Guide](https://docs.flutter.dev/app-architecture/guide)
- [Robert C. Martin — The Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Riverpod Providers](https://riverpod.dev/docs/concepts/providers)
- [Dart Records](https://dart.dev/language/records)
- [fpdart](https://pub.dev/packages/fpdart)
- [GoRouter](https://go_router.dev/)
- [Learn Dart in Y Minutes](https://learnxinyminutes.com/docs/dart/)
- Path slide lokal yang dicantumkan Codelab, `../00-slides/Week_07_Clean_Architecture.html`, tidak tersedia pada checkout ini.

## Mapping awal → hasil final

| Area awal | Masalah/tanggung jawab | Hasil final |
|---|---|---|
| `lib/data/local/note.dart` | Entity bercampur mapping SQLite | Entity Domain `Note` dan `NoteModel` Data |
| `lib/data/repositories/note_repository.dart` | Kontrak dan implementasi bercampur | `NoteRepository` di Domain dan `NoteRepositoryImpl` di Data |
| `lib/data/providers.dart` | DI, state, client, dan repository legacy bercampur | Compatibility seam; provider feature menjadi boundary baru |
| `lib/pages/note_detail_page.dart` | Formatting tanggal berada di UI | Menggunakan pure `formatDate` |
| `lib/pages/posts_page.dart` | Merender `Map<String, dynamic>` mentah | Wrapper compatibility menuju typed `AnnouncementsPage` |
| `lib/data/sync.dart` | Dio, SQLite, JSON, cache-first, orchestration bercampur | Dipakai melalui injected cache loader |
| `features/notes` dan `features/announcements` | Feature-first belum tersedia | Domain/Data/Presentation dan provider wiring terdokumentasi/terimplementasi sesuai scope |

Mapping lengkap dan alasan keputusan ada di [Step 8 — Finalisasi](docs/step-8-finalization.md); audit awal ada di [architecture-audit.md](../05-week-5-local-storage-offline-first/docs/architecture-audit.md).

## Tiga boundary scan resmi

Dijalankan dari repository root; exit `1` berarti tidak ada kecocokan dan exit `0` berarti ada kecocokan yang harus diinterpretasikan.

```bash
rg -n "import 'package:(flutter|dio|sqflite|firebase|shared_preferences)'" \
  07-week-7-clean-architecture/lib/core \
  07-week-7-clean-architecture/lib/features/*/domain
# rg_domain_core_exit=1 — tidak ada output
```

```bash
rg -n "(fromMap|toMap|fromJson|toJson|updated_at|dirty)" \
  07-week-7-clean-architecture/lib/features/*/domain/entities
# exit=0 — hanya field business state `dirty` pada Note; tidak ada mapping method/kolom updated_at
```

```bash
rg -n "(Dio\(|openDatabase|getDatabasesPath|FlutterSecureStorage|SharedPreferences\.getInstance|jsonDecode|NoteRepositoryImpl|openNotesDb|readCachedPosts)" \
  07-week-7-clean-architecture/lib/features/*/presentation \
  07-week-7-clean-architecture/lib/pages \
  07-week-7-clean-architecture/lib/widgets
# exit=0 — NoteRepositoryImpl/openNotesDb hanya pada provider composition boundary; bukan page/widget
```

## Status tahap

### Tahap 3 — Step 4: Domain dan Data per feature

**Status:** selesai pada scope Domain dan Data untuk feature `notes`.

Project target tahap ini adalah folder `07-week-7-clean-architecture/`. Baseline source dan test berasal dari project Week 5 offline-first. Pada akhir Tahap 3, refactoring presentation, provider, dan Dependency Injection belum dilakukan karena termasuk scope Step 5 / Tahap 4. Tahap berikutnya kini sudah didokumentasikan di bawah.

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

`dart format` dan pemeriksaan boundary Domain/Core/presentation dijalankan. `flutter analyze` dan `flutter test` dicoba tetapi **BLOCKED** karena `pubspec.yaml` dan metadata dependency tidak tersedia; keduanya tidak diklaim PASS. Screenshot tidak dibuat karena aplikasi tidak dapat dijalankan tanpa metadata Flutter/dependency. Pada akhir Tahap 4, Step 6 / AI Challenge belum dimulai; dokumentasinya kini tersedia pada bagian Tahap 5.

### Tahap 5 — Step 6: AI Challenge

**Status:** selesai pada scope dokumentasi dan analisis proposal arsitektur AI. Tidak ada source code aplikasi, test, dependency, `pubspec`, konfigurasi, atau file Week 6 yang diubah.

Dokumentasi: [Step 6 — AI Challenge](docs/step-6-ai-challenge.md)

Step 6 mendokumentasikan prompt AI, excerpt output awal yang grounded pada source Campus Notify Week 6, perbandingan dengan keputusan final yang sudah diterapkan pada feature `notes`, alasan menerima/menolak/menyesuaikan proposal, serta tepat tiga verification command dengan hasil aktual. Auth dan announcements **tidak diklaim sudah dimigrasikan pada akhir Tahap 5**; implementasi `announcements` kemudian dikerjakan dalam scope Step 7 sebagai adapter cache lokal.

Verifikasi tambahan:

- `dart analyze` pada `lib/core` dan Domain notes: **PASS**, `No issues found!`.
- Tiga scan `rg`: dijalankan dan hasil aktual dicatat di dokumentasi; check 2 menemukan field bisnis `dirty`, sedangkan check 3 menemukan wiring concrete repository di provider composition boundary yang disengaja.
- `flutter analyze`: **BLOCKED**, karena package/dependency tidak dapat di-resolve tanpa metadata Flutter.
- `flutter test`: **BLOCKED**, karena target tidak memiliki `pubspec.yaml`.
- Screenshot UI before/after: **BLOCKED**, karena target tidak runnable. Tidak ada screenshot palsu, placeholder, atau screenshot Week 6 yang direlabel sebagai bukti Stage 5.

Bukti visual alternatif tidak dibuat karena Chrome DevTools tidak tersedia dan tidak ada aplikasi/preview target yang dapat ditampilkan secara valid. Output command aktual dicatat sebagai teks, bukan diklaim sebagai screenshot aplikasi.

Step 7 / Tahap 6 dimulai setelah Tahap 5 dan didokumentasikan pada bagian Tahap 6 di bawah.


### Tahap 6 — Step 7: Refactoring, Testing, dan Boundary

**Status saat penutupan:** implementasi Step 7 selesai dan dokumentasi final Step 8 juga selesai. Runtime evidence tetap blocked karena target tidak runnable.

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
