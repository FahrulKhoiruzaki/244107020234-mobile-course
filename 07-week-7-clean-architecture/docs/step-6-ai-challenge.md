# Tahap 5 — Step 6: AI Challenge

Dokumen ini mencatat AI Challenge pada [Codelab Clean Architecture Week 7](https://jti-polinema.github.io/flutter-codelab/07-minggu-7-clean-architecture/index.html#1).

## Scope dan konteks repository

Tahap ini hanya mendokumentasikan proposal arsitektur dan keputusan evaluasinya. Tidak ada source code aplikasi, test, dependency, `pubspec`, atau konfigurasi yang diubah.

Codelab menyebut project `campus_notify`. Pada repository ini, source Campus Notify yang paling sesuai berada di `06-week-6-authentication-security-fcm/`, sedangkan target Week 7 berada di `07-week-7-clean-architecture/` dan berisi feature `notes` dari project Week 5. Perubahan lokal Week 6 dipertahankan dan tidak disentuh. Karena itu:

- source Week 6 dibaca sebagai bahan audit read-only;
- arsitektur `notes` pada target Week 7 menjadi referensi keputusan final yang sudah diterapkan pada Step 4–5;
- migrasi auth dan announcements tidak diklaim sudah diimplementasikan pada Step 6;
- Step 7 tidak dimulai.

Tidak terdapat `pubspec.yaml` atau metadata dependency Flutter pada target Week 7. Aplikasi target tidak dapat dijalankan sebagai project Flutter mandiri, sehingga bukti visual UI before/after tidak tersedia dan tidak dibuat-buat.

## 1. Prompt AI yang digunakan

Prompt resmi yang menjadi dasar tugas Codelab adalah:

```text
Project Flutter saya: campus_notify (auth + FCM + daftar pengumuman).

Kondisi kini: folder lib/{data, providers, pages, messaging},

repository tercampur dengan implementasi, widget memanggil Dio langsung.

Tugas:

1. Usulkan struktur feature-first Clean Architecture
(presentation/domain/data) untuk fitur auth + announcements.

2. Untuk tiap file lama, sebutkan tujuan barunya (pindah/pecah/hapus).

3. Tandai bagian yang over-engineering bila diterapkan ke CRUD sederhana,
dan kapan use case benar-benar dibutuhkan vs repository langsung.

4. Tunjukkan wiring DI dengan Riverpod (tanpa package DI tambahan).

Jelaskan trade-off setiap keputusan.
```

Karena repository tidak memiliki folder bernama `campus_notify` dan source Week 6 memiliki perubahan lokal yang harus dijaga, prompt yang benar-benar dikirim kepada AI coding assistant menambahkan batasan grounding dan no-implementation berikut:

```text
Act as a senior Flutter reviewer. Audit the existing Campus Notify project in this repository, especially authentication and announcements. Propose a feature-first Clean Architecture migration only; do not implement unrelated features, Step 7, UI redesign, pubspec/config changes, or claim tests/screenshots you cannot run. For each feature, show the intended domain entities, repository interfaces, justified use cases, data models/mappers, repository implementations, presentation providers, and one centralized Riverpod composition boundary. Enforce: repository contracts in domain; implementations in data; domain with no Flutter/Dio/SQLite/Firebase imports; entities with no persistence mapping; widgets must not create repositories. Discuss where a use case would be unnecessary and the trade-offs of keeping a direct provider/repository call. Compare the proposal with the existing Week 7 notes architecture and identify migration risks and verification commands.
```

Prompt kedua adalah adaptasi eksplisit agar AI membaca source yang benar-benar tersedia di repository, tidak melakukan implementasi di luar scope, dan tidak mengarang hasil verifikasi. Keduanya mencakup empat permintaan resmi Codelab.

## 2. Output awal AI

Bagian berikut adalah **excerpt representatif dari output awal AI**. Ini adalah proposal, bukan hasil implementasi. Nama file dan observasi di dalamnya berasal dari pembacaan source Week 6; endpoint dan schema backend yang tidak tampak di source ditandai sebagai asumsi.

### Observasi awal AI

- `lib/data/auth_repository.dart` berisi `AuthSession`, repository konkret, dan login/refresh mock berbasis `Future.delayed`.
- `lib/data/token_store.dart` membungkus secure storage.
- `lib/data/api_client.dart` membuat Dio, memasang access token, dan menangani refresh ketika menerima 401.
- `lib/providers/auth_provider.dart` mencampur wiring `TokenStore`, `AuthRepository`, Dio, dan `AuthNotifier`.
- `lib/pages/login_page.dart` membaca `authStateProvider` dan memanggil notifier.
- `lib/pages/home_page.dart` membuat Dio langsung dengan base URL hard-coded untuk `_testBackendConnection`, lalu memanggil `apiClientProvider.post('/devices', ...)` untuk token FCM.
- `lib/pages/announcement_page.dart` baru menampilkan ID pengumuman; repository/data source daftar atau detail pengumuman belum terlihat.
- `lib/messaging/push_service.dart` mencampur Firebase Messaging, local notification, token lifecycle, topic subscription, dan callback navigasi.
- Bentuk endpoint dan JSON backend untuk login, refresh, announcements, dan device registration tidak dapat dipastikan dari source yang dibaca.

### Struktur feature-first yang diusulkan AI

```text
lib/
├── app/
│   ├── app.dart
│   ├── router.dart
│   └── app_providers.dart
├── core/
│   ├── error/
│   ├── network/
│   ├── storage/
│   └── messaging/
├── features/
│   ├── auth/
│   │   ├── domain/
│   │   │   ├── entities/auth_session.dart
│   │   │   ├── repositories/auth_repository.dart
│   │   │   └── usecases/
│   │   │       ├── login.dart
│   │   │       ├── restore_session.dart
│   │   │       └── logout.dart
│   │   ├── data/
│   │   │   ├── models/auth_session_model.dart
│   │   │   ├── datasources/auth_remote_data_source.dart
│   │   │   └── repositories/auth_repository_impl.dart
│   │   └── presentation/
│   │       ├── providers/auth_providers.dart
│   │       └── pages/login_page.dart
│   └── announcements/
│       ├── domain/
│       │   ├── entities/announcement.dart
│       │   └── repositories/announcement_repository.dart
│       ├── data/
│       │   ├── models/announcement_model.dart
│       │   ├── datasources/announcement_remote_data_source.dart
│       │   └── repositories/announcement_repository_impl.dart
│       └── presentation/
│           ├── providers/announcement_providers.dart
│           └── pages/announcement_page.dart
└── main.dart
```

### Rekomendasi use case dan DI dari output awal

AI merekomendasikan use case untuk alur auth karena login, restore session, refresh token, logout, dan penyimpanan token memiliki orkestrasi serta efek samping. Untuk read announcements yang hanya meneruskan satu operasi repository, AI menilai repository langsung melalui provider masih cukup; use case baru bernilai ketika ada pagination, cache, filter bisnis, mark-as-read, retry policy, atau orkestrasi beberapa sumber.

Contoh wiring yang diusulkan AI bersifat skematis:

```dart
final dioProvider = Provider<Dio>((ref) {
  return Dio(BaseOptions(baseUrl: apiBaseUrl));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remote: ref.watch(authRemoteDataSourceProvider),
    tokenStore: ref.watch(tokenStoreProvider),
  );
});

final announcementsProvider =
    FutureProvider.autoDispose<List<Announcement>>((ref) {
  return ref.watch(announcementsRepositoryProvider).fetchAnnouncements();
});
```

AI juga menekankan bahwa widget tidak boleh membuat Dio, token store, data source, atau repository. Push service sebaiknya menjadi adapter infrastruktur; background handler tetap top-level dan tidak memakai `BuildContext` atau state widget. Navigasi dari payload notification dikirim sebagai route intent ke application/router boundary.

### Status output awal

Output tersebut tidak memverifikasi endpoint, schema response, build, test, runtime, atau screenshot. Proposal tidak diperlakukan sebagai bukti bahwa auth/announcements telah dimigrasikan.

## 3. Perbandingan proposal AI dan keputusan final

Keputusan final pada tabel ini merujuk pada implementasi target Week 7 yang sudah selesai pada Step 4–5, terutama feature `notes`. Ini adalah keputusan arsitektur yang dipakai sebagai pola; bukan klaim bahwa feature auth dan announcements sudah dibuat di target Week 7.

| Concern | Proposal AI | Keputusan final Week 7 | Status | Alasan teknis |
|---|---|---|---|---|
| Feature boundary | `features/auth` dan `features/announcements`, masing-masing tiga layer | `features/notes` sudah memakai `domain`, `data`, dan `presentation` | Disesuaikan | Polanya diterima, tetapi Stage 5 tidak menambah migrasi feature Week 6 yang berada di luar target. |
| Arah dependency | `presentation → domain ← data` | Sama | Diterima | Domain menjadi boundary yang tidak mengetahui framework/infrastruktur. |
| Repository contract | `AuthRepository`/`AnnouncementRepository` di Domain | `NoteRepository` berada di `features/notes/domain/repositories` | Diterima | Kontrak dapat dipalsukan dalam test dan tidak mengikat Domain ke SQLite. |
| Repository implementation | Implementation di Data | `NoteRepositoryImpl` berada di `features/notes/data/repositories` | Diterima | Detail database tetap berada di Data. |
| Entity dan mapper | Entity murni; JSON/map di model | `Note` murni; `NoteModel` memiliki `fromMap`, `toMap`, dan `toEntity` | Diterima | Nama kolom `updated_at` dan representasi `dirty` tidak bocor ke entity. |
| Use-case granularity | Use case untuk auth yang berorkestrasi; repository langsung boleh untuk read sederhana | `GetNotes` dipertahankan; tidak dibuat use case untuk setiap operasi legacy CRUD/sync | Disesuaikan | `GetNotes` menjadi boundary read yang sedang diuji; use case satu-baris tambahan tanpa policy akan menjadi ceremony. |
| Riverpod DI | Riverpod sebagai composition boundary tanpa DI package baru | `notesProvider → GetNotes → NoteRepository → NoteRepositoryImpl → openNotesDb` | Diterima | Provider membuat dependency graph dan widget tidak membuat repository. |
| Composition root | `app`/provider graph merakit dependency | `main.dart` menjadi composition root/router/theme; provider feature merakit notes | Diterima dengan skala lebih kecil | Tidak perlu menambah struktur `app/` baru untuk target notes yang kecil. |
| Widget responsibility | Page hanya membaca state dan mengirim event | `NotesPage` menangani loading/error/empty/data, retry, refresh, dan callback UI | Diterima | `NotesPage` tidak mengandung SQL, Dio, JSON parsing, atau konstruksi repository. |
| Auth token | Pisahkan token store dan refresh dari widget; pertimbangkan abstraction/mutex bila perlu | Tidak dimigrasikan pada Stage 5; proposal auth dicatat sebagai rencana | Ditunda | Source Week 6 memiliki perubahan lokal dan kontrak backend belum tersedia. Refactor akan melampaui dokumentasi AI Challenge. |
| Announcements/network | Tambahkan data source/model/repository untuk list/detail | Tidak diimplementasikan pada target Week 7 | Ditolak untuk scope ini | `announcement_page.dart` yang tersedia hanya menampilkan ID; tidak ada schema backend yang dapat dijadikan dasar implementasi. |
| Legacy CRUD/sync | Migrasi bertahap dan hapus file lama setelah validasi | Provider legacy tetap menjadi compatibility seam untuk operasi yang belum memiliki kontrak Domain | Diterima sementara | Menjaga perilaku Week 5 sambil memindahkan read path notes pada Step 5. |
| Verification | Jalankan scan, analyze, test, dan capture evidence tanpa klaim palsu | Scan dan Dart Domain/Core tersedia; Flutter commands tetap dicatat sebagai blocked | Diterima dengan batasan | Target tidak memiliki metadata Flutter/dependency. |
| Screenshot | Before/after runtime bila project dapat dijalankan | Tidak ada screenshot UI; status alternatif dijelaskan di bagian evidence | Disesuaikan | Tidak boleh menyalin atau merelabel screenshot Week 6 sebagai bukti Step 6. |

## 4. Alasan keputusan diterima, ditolak, atau disesuaikan

### Keputusan yang diterima

1. **Repository interface di Domain dan implementation di Data.** Ini langsung diwujudkan pada `NoteRepository` dan `NoteRepositoryImpl`.
2. **Entity bebas infrastruktur.** `Note` tidak mengimpor Flutter, Dio, SQLite, Firebase, atau package lain.
3. **Mapping di model.** `NoteModel` menangani SQLite map dan konversi ke entity.
4. **Riverpod sebagai DI.** Tidak ada package DI baru. Provider menjadi tempat merakit opener database, repository, dan use case.
5. **Widget tidak membuat repository.** `NotesPage` hanya membaca provider dan menjalankan callback presentation.
6. **Use case selektif.** `GetNotes` dipertahankan karena menjadi boundary operasi read yang dipakai presentation dan fake-test.

### Keputusan yang ditolak atau disesuaikan

1. **Migrasi auth/announcements tidak dikerjakan.** Target Stage 5 adalah dokumentasi AI Challenge di Week 7, bukan implementasi ulang Week 6. Source Week 6 juga memiliki perubahan lokal yang harus dipertahankan.
2. **Tidak membuat `app/` besar.** Untuk feature notes yang kecil, `main.dart` dan provider feature sudah cukup menjadi composition boundary. Struktur tambahan baru akan menjadi ceremony tanpa kebutuhan saat ini.
3. **Tidak membuat use case untuk semua method.** CRUD/sync legacy belum memiliki kontrak Domain yang lengkap. Menambah class satu-baris untuk setiap method akan menambah indirection tanpa policy baru.
4. **Compatibility seam dipertahankan.** Provider lama masih dipakai oleh settings, posts, detail, dirty count, dan sync. Ini adalah keputusan migrasi bertahap, bukan pola akhir untuk semua feature.
5. **Tidak mengklaim endpoint announcements.** Source yang tersedia belum menyediakan endpoint dan schema yang dapat diverifikasi. Membuat model/repository berdasarkan tebakan akan menghasilkan implementasi yang tidak grounded.

## 5. Tiga verification command dan hasil aktual

Perintah berikut dijalankan terhadap target `07-week-7-clean-architecture/`. Hasil ditulis apa adanya; `rg_exit=1` berarti `rg` tidak menemukan baris, sedangkan `rg_exit=0` berarti ada kecocokan yang harus diinterpretasikan.

### Check 1 — Domain/Core tidak mengimpor infrastruktur

```bash
rg -n "import 'package:(flutter|dio|sqflite|firebase|shared_preferences)'" \
  07-week-7-clean-architecture/lib/core \
  07-week-7-clean-architecture/lib/features/*/domain
```

Hasil aktual:

```text
rg_exit=1
```

Tidak ada output baris. Ini berarti import package terlarang yang dicari tidak ditemukan pada Core dan Domain. Pemeriksaan ini tidak menggantikan `flutter analyze`.

### Check 2 — Entity tidak memuat mapping persistence

```bash
rg -n "(fromMap|toMap|fromJson|toJson|updated_at|dirty)" \
  07-week-7-clean-architecture/lib/features/*/domain/entities
```

Hasil aktual:

```text
07-week-7-clean-architecture/lib/features/notes/domain/entities/note.dart:7:    this.dirty = false,
07-week-7-clean-architecture/lib/features/notes/domain/entities/note.dart:14:  final bool dirty;
rg_exit=0
```

Kecocokan hanya `dirty`, yaitu state bisnis offline-first pada entity `Note`; tidak ada `fromMap`, `toMap`, `fromJson`, `toJson`, atau nama kolom `updated_at`. `dirty` bukan pelanggaran mapping karena entity memang perlu membawa status sinkronisasi. Mapping integer `0/1` tetap berada di `NoteModel`.

> Catatan reproducibility: pola check ini menggunakan `rg` pada wildcard `lib/features/*/domain/entities`. Dengan target saat ini, output aktual di atas harus dibaca sebagai audit manual yang membedakan field bisnis `dirty` dari fungsi/kolom mapping; kriteria mapping tetap terpenuhi karena tidak ada fungsi mapping atau `updated_at` di entity.

### Check 3 — Presentation tidak mengakses concrete infrastructure secara langsung

```bash
rg -n "(Dio\(|openDatabase|getDatabasesPath|FlutterSecureStorage|SharedPreferences\.getInstance|jsonDecode|NoteRepositoryImpl|openNotesDb)" \
  07-week-7-clean-architecture/lib/features/*/presentation \
  07-week-7-clean-architecture/lib/pages \
  07-week-7-clean-architecture/lib/widgets
```

Hasil aktual:

```text
07-week-7-clean-architecture/lib/features/notes/presentation/providers/notes_providers.dart:11:  return NoteRepositoryImpl(openDb: openNotesDb);
rg_exit=0
```

Kecocokan tersebut berada di provider composition boundary yang memang bertugas merakit Data dependency, bukan di widget/page. `NotesPage`, `NoteTile`, dan `NoteDetailPage` tidak membuat `NoteRepositoryImpl`, tidak memanggil `openNotesDb`, dan tidak membuat Dio. Hasil ini dicatat sebagai compatibility/composition seam yang disengaja, bukan disembunyikan sebagai “no output”.

## 6. Verifikasi tambahan dan keterbatasan

Verifikasi yang tersedia sebelum dan selama Stage 5:

- `dart analyze 07-week-7-clean-architecture/lib/core 07-week-7-clean-architecture/lib/features/notes/domain` menghasilkan `No issues found!`.
- `flutter analyze` dicoba terhadap target, tetapi **BLOCKED/FAIL** dengan exit code `1`; target menghasilkan `412 issues found`, dimulai dari package yang tidak dapat di-resolve seperti `package:path/path.dart`, `package:sqflite/sqflite.dart`, `package:shared_preferences/shared_preferences.dart`, `package:dio/dio.dart`, dan `package:flutter_riverpod/flutter_riverpod.dart`.
- `flutter test` dicoba dari target dan **BLOCKED/FAIL** dengan exit code `1`: `Error: No pubspec.yaml file found. This command should be run from the root of your Flutter project.`
- `git diff --check` menghasilkan exit code `0`.
- Tidak ada `pubspec.yaml` atau `pubspec.lock` yang dibuat.
- Tidak ada file Week 6 yang diubah oleh Stage 5.
- Tidak ada hasil test Flutter atau runtime yang diklaim PASS.

Keterbatasan yang tidak dapat diselesaikan tanpa source/runtime tambahan:

- tidak ada kontrak endpoint dan JSON announcements yang dapat diverifikasi;
- tidak ada project Flutter runnable di target Week 7;
- perilaku backend auth/refresh dan device registration tidak dapat diuji dari target;
- before/after UI Campus Notify tidak dapat diambil secara valid;
- screenshot Week 6 yang sudah ada tidak digunakan ulang sebagai bukti Stage 5.

## 7. Bukti screenshot

Aplikasi target tidak dapat dijalankan karena metadata Flutter/dependency tidak tersedia. Oleh karena itu tidak ada screenshot UI before/after yang dapat dipertanggungjawabkan.

Status evidence:

- **Screenshot aplikasi before/after:** BLOCKED — tidak ada runtime target yang valid.
- **Screenshot terminal/editor alternatif:** BLOCKED — Chrome DevTools tidak dapat terhubung karena remote debugging tidak aktif; percobaan `screencapture` juga gagal dengan pesan aktual `could not create image from display`. Output command di atas dicatat langsung sebagai teks agar konteksnya tidak menyesatkan.
- **Screenshot Week 6:** tidak disalin, tidak diganti nama, dan tidak diklaim sebagai bukti Step 6.

Jika checkout Flutter runnable disediakan kemudian, capture yang sesuai harus diambil dari aplikasi yang benar-benar dijalankan, disimpan di `07-week-7-clean-architecture/screenshot/`, dan diberi caption bahwa gambar tersebut adalah before/after runtime. Tahap ini sengaja tidak membuat placeholder.

## 8. Checklist deliverable Step 6

- [x] Prompt AI yang digunakan.
- [x] Output awal AI berupa excerpt yang diberi label dan grounded pada source.
- [x] Perbandingan proposal AI dengan keputusan final Week 7.
- [x] Alasan keputusan yang diterima, ditolak, dan disesuaikan.
- [x] Tepat tiga verification command dengan hasil aktual.
- [x] Dokumentasi Step 6.
- [x] README diarahkan ke dokumentasi Stage 5.
- [x] Tidak ada source code aplikasi yang diubah.
- [x] Tidak ada Week 5/Week 6/configuration yang diubah.
- [x] Tidak ada klaim test, runtime, atau screenshot palsu.
- [ ] Screenshot UI before/after — BLOCKED karena target tidak runnable.
- [x] Step 7 belum dimulai.
