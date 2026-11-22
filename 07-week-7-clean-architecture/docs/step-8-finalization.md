# Tahap 7 — Step 8: Finalisasi dan Definition of Done

Dokumen ini menutup Codelab Clean Architecture Week 7 pada target `07-week-7-clean-architecture/`. Step 8 dikerjakan sebagai finalisasi dokumentasi, refleksi, inventaris evidence, dan pelaporan blocker. Tidak ada feature baru, migrasi ulang Step 4–7, perubahan Week 5/Week 6, dependency, `pubspec`, lockfile, konfigurasi, atau screenshot placeholder.

Sumber utama: [Codelab Clean Architecture Week 7](https://jti-polinema.github.io/flutter-codelab/07-minggu-7-clean-architecture/index.html#1).

## Status seluruh tahap

| Tahap | Step | Isi | Status akhir |
|---|---:|---|---|
| Tahap 1 | Step 1–2 | Konsep SOLID, Clean Architecture, layer, dependency rule, entity/model/repository/use case/DI | **Selesai — dokumentasi** |
| Tahap 2 | Step 3 | Audit project lama, hasil pencarian, mapping file, rencana refactor | **Selesai — dokumentasi** |
| Tahap 3 | Step 4 | Pemisahan Domain/Data feature `notes` | **Selesai — implementasi** |
| Tahap 4 | Step 5 | Presentation, Riverpod DI, fake test `notes` | **Selesai — implementasi** |
| Tahap 5 | Step 6 | AI Challenge, proposal-vs-final, trade-off, verification scan | **Selesai — dokumentasi** |
| Tahap 6 | Step 7 | Feature `announcements`, pure helpers, typed failure, fake tests, boundary | **Selesai — implementasi** |
| Tahap 7 | Step 8 | README final, refleksi, references, status/evidence, definition of done | **Selesai — dokumentasi finalisasi** |

Status `selesai` pada implementasi berarti source dan dokumentasi tahap tersebut dikerjakan sesuai scope. Status itu tidak mengubah fakta bahwa Flutter runtime, `flutter analyze`, `flutter test`, manual behavior check, dan screenshot masih blocked oleh metadata project yang tidak tersedia.

## Deliverable final

- [Tahap 1 — konsep SOLID dan Clean Architecture](../../05-week-5-local-storage-offline-first/docs/clean-architecture-concepts.md)
- [Tahap 2 — audit layer project lama](../../05-week-5-local-storage-offline-first/docs/architecture-audit.md)
- [Tahap 3 — Step 4 Domain dan Data](step-4-domain-data.md)
- [Tahap 4 — Step 5 Presentation dan DI](step-5-presentation-di.md)
- [Tahap 5 — Step 6 AI Challenge](step-6-ai-challenge.md)
- [Tahap 6 — Step 7 Refactoring, Testing, dan Boundary](step-7-refactoring-testing.md)
- [Refleksi resmi Step 8](reflection.md)
- README target sebagai ringkasan final dan navigasi submission.

## Arsitektur final

Feature-first dipakai agar Domain, Data, dan Presentation setiap feature berada berdekatan. Arah dependency yang dituju adalah:

```text
                                      ┌──────────────────────────┐
                                      │  existing cache/database │
                                      │  Dio / SQLite / JSON     │
                                      └─────────────┬────────────┘
                                                    │
                                                    ▼
┌──────────────────────┐    depends on    ┌──────────────────────┐
│ presentation         │ ───────────────▶ │ domain               │
│ pages/providers      │                  │ entities/contracts   │
└──────────────────────┘                  │ use cases/failures   │
                                          └──────────────┬───────┘
                                                         ▲
                                                         │ implements/uses
                                          ┌──────────────┴───────┐
                                          │ data                 │
                                          │ models/repositories  │
                                          │ adapters/mapping     │
                                          └──────────────────────┘
```

Secara ringkas:

```text
presentation → domain ← data
```

`notes` memiliki entity, kontrak repository, use case, model, implementasi repository, provider, dan page. `announcements` memakai struktur yang sama, tetapi repository-nya adalah adapter cache lokal atas `cached_posts`; tidak diklaim sebagai integrasi backend announcements. Provider adalah composition boundary yang boleh merakit implementasi Data. Page/widget tidak membuat Dio, database, atau repository concrete.

## Pemetaan awal ke hasil akhir

| Area awal | Masalah/tanggung jawab | Hasil final Week 7 |
|---|---|---|
| `lib/data/local/note.dart` | Entity bercampur mapping SQLite | Entity `features/notes/domain/entities/note.dart` dan `NoteModel` di Data |
| `lib/data/repositories/note_repository.dart` | Kontrak dan implementasi bercampur | `NoteRepository` di Domain; `NoteRepositoryImpl` di Data |
| `lib/data/providers.dart` | Provider, state, client, dan repository legacy bercampur | Dipertahankan sebagai compatibility seam; provider feature menjadi boundary baru |
| `lib/pages/note_detail_page.dart` | Formatting tanggal dilakukan di UI | Menggunakan pure `formatDate` dari `lib/core/format.dart` |
| `lib/pages/posts_page.dart` | UI merender `Map<String, dynamic>` mentah | Compatibility wrapper menuju typed `AnnouncementsPage` |
| `lib/data/sync.dart` | Cache-first, Dio, SQLite, JSON, dan orchestration bercampur | Dipakai sebagai legacy/cache seam melalui loader yang di-inject |
| `features/notes` | Belum feature-first | Domain/Data/Presentation lengkap untuk scope notes |
| `features/announcements` | Belum ada | Entity, repository contract/impl, use case, provider, page, dan model |
| `test/note_test.dart` dan test baru | Test lama terikat pada implementasi; fake use-case belum lengkap | Fake success/failure tests pada `get_notes_test.dart` dan `get_announcements_test.dart`; formatter test juga tersedia |

Rincian mapping dan audit awal tersedia pada [architecture-audit.md](../../05-week-5-local-storage-offline-first/docs/architecture-audit.md) dan [step-7-refactoring-testing.md](step-7-refactoring-testing.md).

## Audit dependency rule dan tiga scan resmi

Semua command berikut dijalankan dari repository root dan hasilnya dipertahankan apa adanya. `rg` exit `1` berarti tidak ada kecocokan; exit `0` berarti ada kecocokan yang harus diinterpretasikan.

### 1. Core/Domain bebas import infrastructure

```bash
rg -n "import 'package:(flutter|dio|sqflite|firebase|shared_preferences)'" \
  07-week-7-clean-architecture/lib/core \
  07-week-7-clean-architecture/lib/features/*/domain
```

Hasil: `rg_domain_core_exit=1`, tanpa output. Tidak ditemukan import infrastructure pada Core dan Domain yang diaudit.

### 2. Entity bebas persistence mapping

```bash
rg -n "(fromMap|toMap|fromJson|toJson|updated_at|dirty)" \
  07-week-7-clean-architecture/lib/features/*/domain/entities
```

Hasil: exit `0` hanya untuk field `dirty` pada entity `Note`:

```text
notes/domain/entities/note.dart:7: this.dirty = false,
notes/domain/entities/note.dart:14: final bool dirty;
```

`dirty` adalah business state offline-first, bukan method mapping atau nama kolom persistence. Tidak ada `fromMap`, `toMap`, `fromJson`, `toJson`, atau `updated_at` pada entity; konversi integer `dirty` tetap dilakukan `NoteModel`.

### 3. Presentation tidak membuat/access concrete infrastructure secara langsung

```bash
rg -n "(Dio\(|openDatabase|getDatabasesPath|FlutterSecureStorage|SharedPreferences\.getInstance|jsonDecode|NoteRepositoryImpl|openNotesDb|readCachedPosts)" \
  07-week-7-clean-architecture/lib/features/*/presentation \
  07-week-7-clean-architecture/lib/pages \
  07-week-7-clean-architecture/lib/widgets
```

Hasil: satu kecocokan pada `features/notes/presentation/providers/notes_providers.dart`, yaitu pembuatan `NoteRepositoryImpl` dengan `openNotesDb`. Ini adalah provider composition boundary yang memang merakit dependency Data, bukan page/widget. Page dan widget tetap tidak membuat repository, database, Dio, atau JSON parser.

Scan tambahan terhadap `Map<String, dynamic>`, `Dio`, `jsonDecode`, `readCachedPosts`, dan `Exception(` pada presentation/page/widget tidak menghasilkan output.

## Test dan verification evidence

Evidence yang tersedia:

- `dart format`: berhasil; pemeriksaan akhir melaporkan `Formatted 17 files (5 changed) in 0.02 seconds.`
- Pure Core/Domain analyze: **PASS**, `No issues found!`, exit `0`.
- `test/get_notes_test.dart`: fake repository success dan `LocalFailure` propagation.
- `test/get_announcements_test.dart`: fake repository success dan `LocalFailure` propagation.
- `test/format_test.dart`: date formatting dan route parsing.
- `git diff --check`: **PASS**, exit `0` pada verification tahap sebelumnya.

Evidence yang tidak dapat diselesaikan pada checkout ini:

- `flutter analyze`: **BLOCKED/FAIL**, exit `1`; package URI seperti `package:path/path.dart` tidak dapat di-resolve karena tidak ada `pubspec.yaml`/metadata dependency.
- `flutter test`: **BLOCKED/FAIL**, exit `1`; output aktual `Error: No pubspec.yaml file found.`
- Manual behavior check sekitar lima menit untuk notes dan announcements: **BLOCKED**, karena target tidak runnable.
- Before/after screenshot UI: **BLOCKED**, karena tidak ada runtime valid. Folder yang ada adalah singular `screenshot/` dan kosong; kriteria Codelab mengharapkan `screenshots/`. Tidak ada placeholder, screenshot terminal palsu, atau screenshot Week 6 yang disalin/relabel.
- Klaim “behavior identik” tidak dibuat. Yang dapat diklaim hanya compatibility route dan compatibility seam dipertahankan secara source-level.

## Cara menjalankan

Target ini belum dapat dijalankan sebagai project Flutter mandiri. `pubspec.yaml`, `pubspec.lock`, dan metadata dependency tidak tersedia, sehingga instruksi berikut adalah **conditional runbook**, bukan command yang berhasil dijalankan pada checkout final ini:

```bash
cd 07-week-7-clean-architecture
# Setelah project Flutter resmi yang lengkap tersedia:
flutter pub get
flutter analyze
flutter test
flutter run
```

Jangan menambahkan `pubspec` atau dependency secara ad hoc hanya untuk mengubah status blocker; hal tersebut berada di luar scope Step 8 dan memerlukan instruksi/artefact project yang resmi.

## Definition of done Step 8

| Requirement | Status | Evidence/limitation |
|---|---|---|
| README memuat tujuan, fitur, stack, diagram, runbook, hasil | **Selesai** | README target dan dokumen ini |
| Refleksi empat pertanyaan resmi | **Selesai** | [reflection.md](reflection.md) |
| Prompt/output/decision AI | **Selesai** | [step-6-ai-challenge.md](step-6-ai-challenge.md) |
| Mapping awal-ke-final | **Selesai** | tabel di atas + audit awal |
| Dependency rule dan tiga scan | **Selesai dengan catatan** | Scan 1 bersih; scan 2 `dirty` business state; scan 3 provider composition match disengaja |
| Minimal dua fake use-case tests | **Source tersedia; execution blocked** | `get_notes_test.dart`, `get_announcements_test.dart`; Flutter test perlu metadata |
| `flutter analyze` bersih | **Blocked/Fail** | Tidak ada `pubspec.yaml`; tidak diklaim PASS |
| `flutter test` hijau | **Blocked/Fail** | `No pubspec.yaml file found.`; tidak diklaim PASS |
| Manual test feature dan behavior unchanged | **Blocked** | Runtime target tidak tersedia |
| Screenshot before/after di `screenshots/` | **Blocked** | Tidak ada capture valid; tidak membuat placeholder |
| Tidak mengubah Week 5/Week 6/dependency/config | **Selesai** | Scope perubahan final hanya dokumentasi Week 7 |
| Step 8 final dan tidak memulai tahap berikutnya | **Selesai** | Ini adalah tahap terakhir pada workflow ini |

## Referensi

- [Codelab Clean Architecture Week 7](https://jti-polinema.github.io/flutter-codelab/07-minggu-7-clean-architecture/index.html#1)
- Path slide yang dicantumkan Codelab: `../00-slides/Week_07_Clean_Architecture.html` — **tidak tersedia pada checkout ini**.
- [Flutter App Architecture Guide](https://docs.flutter.dev/app-architecture/guide)
- [Robert C. Martin — The Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Riverpod — Providers](https://riverpod.dev/docs/concepts/providers)
- [Dart — Records](https://dart.dev/language/records)
- [fpdart](https://pub.dev/packages/fpdart)
- [GoRouter](https://go_router.dev/)
- [Learn X in Y Minutes — Dart](https://learnxinyminutes.com/docs/dart/)

Step 8 adalah tahap terakhir yang dikerjakan. Tidak ada codelab atau tahap setelahnya yang dimulai pada branch ini.
