# Tahap 6 — Step 7: Refactoring, Testing, dan Boundary

Dokumen ini mencatat implementasi Step 7 pada target `07-week-7-clean-architecture/` berdasarkan [Codelab Clean Architecture Week 7](https://jti-polinema.github.io/flutter-codelab/07-minggu-7-clean-architecture/index.html#1).

## Scope dan batasan

Step 7 menerapkan pola Clean Architecture ke feature kedua, menambahkan helper pure, memperjelas boundary failure, dan menambah fake-based test. Scope sengaja dibatasi pada Week 7:

- feature `notes` yang sudah direfactor pada Step 4–5 tetap menjadi reference implementation;
- feature kedua diberi nama `announcements`, tetapi sumber datanya adalah cache `cached_posts` yang sudah ada;
- tidak ada endpoint atau schema Campus Notify announcements yang dapat diverifikasi di target ini;
- Week 6 tidak disentuh karena memiliki perubahan lokal existing;
- `pubspec.yaml`, lockfile, dependency, dan konfigurasi tidak dibuat atau diubah;
- Step 8 belum dimulai.

Karena itu, feature announcements harus dibaca sebagai **local cached-announcements adapter**, bukan klaim integrasi backend Campus Notify.

Target tidak mempunyai `pubspec.yaml` atau metadata dependency Flutter. Flutter runtime, `flutter analyze`, `flutter test`, dan screenshot aplikasi tidak dapat diverifikasi sebagai project runnable tanpa menambahkan konfigurasi yang berada di luar scope dan memerlukan persetujuan terpisah.

## Dependency direction

```text
presentation → domain ← data
                    ↑
          core failures/format
```

Domain hanya berisi entity, kontrak repository, dan use case. Data mengetahui kontrak Domain dan menangani mapping/cache boundary. Provider menjadi composition boundary yang menginjeksikan loader legacy; page hanya membaca state typed dari provider.

## Feature announcements

```text
lib/features/announcements/
├── domain/
│   ├── entities/announcement.dart
│   ├── repositories/announcement_repository.dart
│   └── usecases/get_announcements.dart
├── data/
│   ├── models/announcement_model.dart
│   └── repositories/announcement_repository_impl.dart
└── presentation/
    ├── pages/announcements_page.dart
    └── providers/announcements_providers.dart
```

Alur dependency:

```text
AnnouncementsPage
  → announcementsProvider
    → GetAnnouncements
      → AnnouncementRepository
        → AnnouncementRepositoryImpl
          → injected AnnouncementRowsLoader
            → loadPostsCacheFirst → cached_posts / existing refresh path
```

### Domain

`Announcement` hanya membawa data bisnis `id`, `title`, `body`, dan optional `publishedAt`. Entity tidak memiliki `fromMap`, `toMap`, JSON, nama kolom SQLite, atau import Flutter/infrastruktur.

`AnnouncementRepository` mengembalikan record berisi `List<Announcement>` dan nullable `Failure`. `GetAnnouncements` menjadi use-case boundary untuk operasi read feature ini dan dapat diuji dengan fake repository tanpa database atau network.

### Data

`AnnouncementModel.fromMap` menyerap perbedaan bentuk payload cache dan melakukan konversi tipe/date. `AnnouncementRepositoryImpl` menerima `AnnouncementRowsLoader` melalui constructor, memetakan model menjadi entity, dan mengubah exception loader/mapping menjadi `LocalFailure` dengan pesan stabil:

```text
Gagal memuat pengumuman dari penyimpanan lokal.
```

Loader provider memakai `loadPostsCacheFirst`, `postsDioProvider`, dan `forceOfflineProvider` yang sudah ada. Cache, SQLite, JSON, Dio, dan background refresh tetap berada di compatibility seam lama; detail tersebut tidak masuk ke Domain atau page.

### Presentation dan route

`AnnouncementsPage` menangani loading, error, empty, data, retry, dan refresh. Page tidak mengimpor Dio/SQLite, tidak membaca `Map<String, dynamic>`, dan tidak membuat repository. Error typed ditampilkan melalui `Failure.message`; error tak dikenal memakai fallback tetap `Gagal memuat pengumuman.`.

Route baru `/announcements` ditambahkan. Route `/posts` dipertahankan sebagai compatibility route dan merender page typed yang sama. Tombol cache pada `NotesPage` diarahkan ke `/announcements`.

## Failure handling

`Failure` sekarang mengimplementasikan `toString()` yang mengembalikan `message`. Provider notes dan announcements melempar objek `Failure` yang sudah diterjemahkan repository, bukan `Exception(failure.message)` baru. Dengan begitu tipe failure tidak hilang dan presentation menerima pesan yang stabil.

Repository notes tetap menerjemahkan error SQLite ke `LocalFailure`. Repository announcements menerjemahkan kegagalan cache loader/mapping ke `LocalFailure`. Tidak ada raw exception dari boundary data baru yang diteruskan ke UI.

Legacy CRUD/settings/detail providers masih merupakan compatibility seam bertahap. Migrasi seluruh operasi lama tidak dilakukan karena akan memperluas Step 7 dan berisiko mengubah behavior existing.

## Pure helpers

`lib/core/format.dart` tidak mengimpor Flutter atau package eksternal.

- `formatDate(DateTime)` menghasilkan format deterministik `dd/MM/yyyy HH:mm` menggunakan komponen local date.
- `normalizeRoute(String?)` menambahkan leading slash dan mengembalikan `/` untuk input kosong/missing.
- `parseRouteId(String?)` menerima ID dengan atau tanpa leading slash dan mengembalikan `null` untuk input invalid.

`NoteDetailPage` menggunakan `formatDate`, sedangkan parser route `/note/:id` menggunakan `parseRouteId`.

## Testing strategy

Test baru tidak memakai SQLite, Dio, Firebase, database nyata, network, atau Flutter runtime logic selain test API yang sudah diimpor oleh project Flutter:

- `test/get_announcements_test.dart`: fake repository success dan typed `LocalFailure` propagation;
- `test/format_test.dart`: zero-padding date, root route fallback, slash normalization, valid/invalid route ID;
- `test/get_notes_test.dart`: success, `LocalFailure`, dan exact friendly message.

Adapter data dapat diuji terpisah dengan loader injectable bila dependency metadata tersedia. Use-case tests tetap menjadi bukti utama bahwa Domain tidak bergantung pada infrastructure.

## Mapping file sebelum/sesudah

| Existing path | Responsibility sebelumnya | Step 7 result |
|---|---|---|
| `lib/data/sync.dart` | Dio, SQLite, JSON, cache-first posts | Dipertahankan sebagai compatibility/data seam; dipakai melalui injected loader |
| `lib/data/providers.dart` | Legacy posts provider dan dependency wiring | Tidak dihapus; loader dependency dipakai oleh announcements composition provider |
| `lib/pages/posts_page.dart` | Render raw `Map<String, dynamic>` | Menjadi wrapper compatibility menuju `AnnouncementsPage` |
| `lib/features/announcements/domain/entities/announcement.dart` | Belum ada | Entity bisnis murni |
| `lib/features/announcements/domain/repositories/announcement_repository.dart` | Belum ada | Kontrak Domain typed dengan `Failure` result |
| `lib/features/announcements/domain/usecases/get_announcements.dart` | Belum ada | Use case read feature |
| `lib/features/announcements/data/models/announcement_model.dart` | Belum ada | Mapping cache map ke entity |
| `lib/features/announcements/data/repositories/announcement_repository_impl.dart` | Belum ada | Adapter loader dan failure translation |
| `lib/features/announcements/presentation/providers/announcements_providers.dart` | Belum ada | Riverpod composition boundary |
| `lib/features/announcements/presentation/pages/announcements_page.dart` | Belum ada | Typed loading/error/empty/data UI |
| `lib/core/format.dart` | Belum ada | Pure date/route helpers |
| `lib/features/notes/presentation/providers/notes_providers.dart` | Failure dibungkus generic `Exception` | Typed `Failure` dipertahankan |
| `lib/pages/note_detail_page.dart` | Format date inline | Menggunakan `formatDate` |

## Tiga boundary scan resmi

Perintah dijalankan dari repository root. Exit code `1` berarti tidak ada kecocokan; exit code `0` berarti ada kecocokan yang harus diinterpretasikan.

### 1. Core/Domain tidak mengimpor infrastructure

```bash
rg -n "import 'package:(flutter|dio|sqflite|firebase|shared_preferences)'" \
  07-week-7-clean-architecture/lib/core \
  07-week-7-clean-architecture/lib/features/*/domain
```

Hasil aktual:

```text
rg_domain_core_exit=1
```

Tidak ada output kecocokan.

### 2. Entity tidak memuat persistence mapping

```bash
rg -n "(fromMap|toMap|fromJson|toJson|updated_at|dirty)" \
  07-week-7-clean-architecture/lib/features/*/domain/entities
```

Hasil aktual:

```text
07-week-7-clean-architecture/lib/features/notes/domain/entities/note.dart:7:    this.dirty = false,
07-week-7-clean-architecture/lib/features/notes/domain/entities/note.dart:14:  final bool dirty;
rg_entities_exit=0
```

Kecocokan hanya `dirty`, yaitu business state offline-first pada entity notes. Tidak ada fungsi mapping atau kolom `updated_at`; mapping integer dirty tetap berada di `NoteModel`.

### 3. Presentation tidak mengakses concrete infrastructure

```bash
rg -n "(Dio\(|openDatabase|getDatabasesPath|FlutterSecureStorage|SharedPreferences\.getInstance|jsonDecode|NoteRepositoryImpl|openNotesDb|readCachedPosts)" \
  07-week-7-clean-architecture/lib/features/*/presentation \
  07-week-7-clean-architecture/lib/pages \
  07-week-7-clean-architecture/lib/widgets
```

Hasil aktual:

```text
07-week-7-clean-architecture/lib/features/notes/presentation/providers/notes_providers.dart:11:  return NoteRepositoryImpl(openDb: openNotesDb);
rg_presentation_exit=0
```

Kecocokan berada di provider composition boundary notes, bukan page/widget. Provider tersebut memang merakit dependency Data. Tidak ada kecocokan untuk loader posts karena loader dipakai di announcements provider, yang merupakan composition boundary; page tetap bebas infrastructure.

## Scan tambahan

```bash
rg -n "Map<String, dynamic>|Dio\(|jsonDecode|readCachedPosts|Exception\(" \
  07-week-7-clean-architecture/lib/features/*/presentation \
  07-week-7-clean-architecture/lib/pages \
  07-week-7-clean-architecture/lib/widgets
```

Hasil aktual:

```text
rg_additional_presentation_exit=1
```

Tidak ada output. Raw map/Dio/JSON/exception constructor tidak berada pada presentation/page/widget yang dipindahkan.

## Verification aktual

### Formatting

```text
dart format ...
Formatted 17 files (5 changed) in 0.02 seconds.
```

Perintah mencakup file Core, feature announcements, notes presentation, route, dan test yang berubah.

### Pure Core/Domain analyze

```text
dart analyze 07-week-7-clean-architecture/lib/core/format.dart \
  07-week-7-clean-architecture/lib/core/failures.dart \
  07-week-7-clean-architecture/lib/features/notes/domain \
  07-week-7-clean-architecture/lib/features/announcements/domain

No issues found!
dart_core_domain_exit=0
```

### Analyze dengan test files

Percobaan analyze yang juga memasukkan test menghasilkan unresolved package karena target tidak memiliki package configuration. Hasil tersebut tidak diklaim PASS; test source membutuhkan `flutter_test` dan package URI project.

### Flutter analyze dan test

`flutter analyze` dijalankan dari target dan gagal karena dependency tidak dapat di-resolve:

```text
flutter_analyze_exit=1
error • Target of URI doesn't exist: 'package:path/path.dart' ... lib/data/local/db.dart:1:8
```

`flutter test` dijalankan dari target dan gagal karena metadata Flutter tidak tersedia:

```text
flutter_test_exit=1
Error: No pubspec.yaml file found.
```

Kedua status tersebut adalah **BLOCKED/FAIL**, bukan PASS. Tidak ada `pubspec.yaml` yang dibuat untuk menutupi blocker.

### Diff check

```text
diff_check_exit=0
```

`git diff --check` tidak menemukan whitespace error dan tidak mengubah file.

## Screenshot evidence

Tidak ada screenshot aplikasi yang dibuat. Target tidak dapat dijalankan tanpa metadata Flutter/dependency, sehingga screenshot before/after UI tidak tersedia secara valid.

Percobaan screenshot alternatif hanya boleh disimpan jika menghasilkan file aktual yang dapat diverifikasi. Tidak ada placeholder, terminal screenshot palsu, atau screenshot Week 6 yang disalin/relabel. Status evidence: **BLOCKED** oleh project target yang tidak runnable.

## Trade-off dan keputusan

1. **Announcements dipilih daripada auth.** Auth Week 6 memiliki token/session/FCM dan perubahan lokal existing. Announcements dapat dibatasi pada cache yang benar-benar tersedia di target tanpa mengarang backend contract.
2. **Cache seam dipertahankan.** Reuse menghindari duplikasi Dio/SQLite/JSON dan menjaga cache-first behavior, tetapi boundary legacy belum merupakan data source ideal yang sepenuhnya terisolasi.
3. **Use case hanya satu untuk feature read.** `GetAnnouncements` memberi boundary yang fake-testable. Tidak dibuat class satu-baris untuk setiap legacy CRUD method karena belum ada business policy baru.
4. **Route `/posts` dipertahankan.** Compatibility wrapper mengurangi risiko deep link lama, sementara `/announcements` menjadi nama feature yang eksplisit.
5. **No new dependency/config.** Missing metadata dicatat sebagai blocker daripada ditutupi dengan pubspec yang tidak disetujui.

## Checklist Step 7

- [x] Feature kedua memiliki entity Domain.
- [x] Feature kedua memiliki repository contract Domain.
- [x] Feature kedua memiliki repository implementation Data.
- [x] Feature kedua memiliki use case.
- [x] Feature kedua memiliki Riverpod provider wiring.
- [x] Presentation announcements memakai typed entity, loading/error/empty/data, retry, dan refresh.
- [x] Pure date formatter dan route parser ditambahkan serta digunakan.
- [x] Failure data diterjemahkan menjadi `Failure` sebelum UI.
- [x] Fake repository success/failure tests ditambahkan.
- [x] Boundary scan resmi dan scan tambahan dijalankan.
- [x] Week 6, dependency, lockfile, dan konfigurasi tidak diubah.
- [ ] `flutter analyze` PASS — blocked oleh tidak adanya `pubspec.yaml`.
- [ ] `flutter test` PASS — blocked oleh tidak adanya `pubspec.yaml`.
- [ ] Screenshot runtime — blocked karena target tidak runnable.
- [x] Step 8 belum dimulai.
