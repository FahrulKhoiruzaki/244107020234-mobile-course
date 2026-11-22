# Tahap 2 — Audit Layer Project Lama

Dokumen ini berisi hasil Step 3 / Praktikum 1 Codelab Clean Architecture pada project `05-week-5-local-storage-offline-first`.

Sumber utama: <https://jti-polinema.github.io/flutter-codelab/07-minggu-7-clean-architecture/index.html#1>

Tahap ini hanya melakukan audit, pemetaan, pencarian pelanggaran, dan perancangan target. Tidak ada refactoring source code, pemindahan file, penambahan dependency, atau implementasi Step 4.

## Scope dan baseline

- Project yang diaudit: `05-week-5-local-storage-offline-first`.
- Branch: `praktikum/week-7-clean-architecture`.
- Baseline sebelum perubahan Tahap 2: commit Tahap 1 `9607b63fcb2362bb4300361c61d2774a0e785bdd` (`docs: document solid and clean architecture concepts`).
- Baseline tersebut digunakan sebagai snapshot yang sudah ada; tidak dibuat commit kosong baru.
- Perubahan existing pada project Minggu 6 dan file untracked di luar whitelist dipertahankan.

## Pemetaan file ke layer saat ini

| File | Layer saat ini | Masalah atau tanggung jawab yang perlu diaudit |
|---|---|---|
| `lib/main.dart` | Presentation/composition | Menggabungkan routing, root app, dan wiring provider melalui import `data/providers.dart`. Setelah refactor, routing tetap di composition root tetapi provider fitur sebaiknya tidak berada di data global. |
| `lib/pages/note_detail_page.dart` | Presentation | Membaca provider dari `data`, memakai object data secara langsung, dan memformat `updatedAt` melalui `toLocal()` di UI. Formatting perlu dipindahkan ke fungsi murni pada tahap refactor. |
| `lib/pages/posts_page.dart` | Presentation | Hanya membaca provider, tetapi merender `Map<String, dynamic>` mentah (`post['title']`, `post['body']`). Model/entity posts belum dipisahkan dari data cache. |
| `lib/pages/settings_page.dart` | Presentation | Hanya membaca provider dan menampilkan state. Namun dependency presentation langsung menuju `data/providers.dart`, bukan provider fitur yang menjadi boundary presentation. |
| `lib/widgets/note_tile.dart` | Presentation | Mengimpor `data/local/note.dart`, sehingga widget bergantung pada tipe yang juga menangani mapping SQLite. Widget seharusnya menerima entity domain. |
| `lib/data/local/db.dart` | Data | Membuka SQLite dan mendefinisikan schema `notes` serta `cached_posts`. Tanggung jawab ini sesuai data, tetapi belum dibungkus data source/model fitur. |
| `lib/data/local/note.dart` | Data/domain tercampur | Class `Note` berisi field bisnis sekaligus `toMap`, `fromMap`, nama kolom SQLite, parsing tanggal, dan konversi `dirty`. Entity dan model persistence perlu dipisahkan. |
| `lib/data/prefs.dart` | Data | Mengakses `SharedPreferences` untuk tema dan waktu buka aplikasi. Class ini menjadi implementasi storage tanpa kontrak domain terpisah. |
| `lib/data/repositories/note_repository.dart` | Data, kontrak dan implementasi tercampur | Class konkret membuka database, query/insert/update/delete, membuat `Note`, dan memanggil `Note.fromMap`/`toMap`. Interface repository belum berada di domain. |
| `lib/data/providers.dart` | DI/state, ditempatkan di data | Menggabungkan provider storage, repository konkret, Dio, FutureProvider, AsyncNotifier, dan operasi sinkronisasi. Provider langsung bergantung pada implementasi data dan mengembalikan `Map<String, dynamic>` mentah untuk posts. |
| `lib/data/sync.dart` | Data/infrastruktur | Menggabungkan Dio, SQLite, JSON decode/encode, cache-first, serta sinkronisasi note. `syncNotes` menerima repository konkret sehingga belum bergantung pada kontrak domain. |
| `test/note_test.dart` | Test | `FakeNoteRepository` mewarisi repository SQLite konkret dan hanya menimpa sebagian method. Test menjadi terikat pada implementasi data, bukan kontrak domain. |

## Hasil pencarian pelanggaran

Perintah berikut dijalankan dari root project yang diaudit.

### 1. Akses jaringan, database, atau storage dari presentation

```bash
rg 'Dio\(|http\.|openDatabase|SharedPreferences\.getInstance|FlutterSecureStorage' lib/pages lib/widgets
```

Hasil aktual: **tidak ada output**.

Interpretasi: tidak ditemukan pemanggilan langsung Dio, HTTP, SQLite opening, SharedPreferences, atau secure storage di `lib/pages` dan `lib/widgets`. Ini merupakan boundary yang sudah relatif baik. Namun, pages masih mengimpor `data/providers.dart`, sehingga dependency tidak langsung tetap perlu dibersihkan pada tahap presentation/DI.

### 2. Parsing JSON atau formatting tanggal dari presentation

```bash
rg 'DateFormat|jsonDecode|\.toIso8601String' lib/pages lib/widgets
```

Hasil aktual: **tidak ada output**.

Interpretasi: tidak ditemukan `DateFormat`, `jsonDecode`, atau `toIso8601String` di pages/widgets. Ada formatting `value.updatedAt.toLocal()` pada `lib/pages/note_detail_page.dart:29`; pola tersebut tidak tertangkap oleh command Codelab, tetapi tetap dicatat sebagai kandidat refactor karena presentation melakukan transformasi waktu.

### 3. Pembuatan repository atau client manual

Perintah Codelab:

```bash
rg 'Repository\(|Dio\(BaseOptions' lib/pages lib/providers
```

Hasil aktual: perintah tidak dapat memeriksa `lib/providers` karena folder tersebut tidak ada pada project ini:

```text
rg: lib/providers: No such file or directory (os error 2)
```

Project memakai `lib/data/providers.dart`, sehingga pencarian disesuaikan menjadi:

```bash
rg 'Repository\(|Dio\(BaseOptions' lib/pages lib/widgets lib/data/providers.dart
```

Hasil aktual:

```text
lib/data/providers.dart:final prefsRepositoryProvider = Provider<PrefsRepository>((ref) => PrefsRepository());
lib/data/providers.dart:final noteRepositoryProvider = Provider<NoteRepository>((ref) => NoteRepository());
lib/data/providers.dart:  return Dio(BaseOptions(
```

Tidak ada hasil dari `lib/pages` atau `lib/widgets`. Temuan berada di provider, bukan widget. Ini bukan akses manual dari UI, tetapi menunjukkan wiring provider masih membuat implementasi konkret dan berada bersama kode data. Hal tersebut menjadi kandidat pemisahan DI dan kontrak repository pada tahap berikutnya.

## Temuan dan rencana refactor

| ID | Bukti | Temuan | Rencana pada tahap refactor |
|---|---|---|---|
| A-01 | `lib/data/local/note.dart:16-32` | Entity dan mapping SQLite berada dalam satu class. | Buat entity domain murni dan `NoteModel` di data. |
| A-02 | `lib/data/repositories/note_repository.dart:7-105` | Kontrak dan implementasi repository bercampur. | Buat interface `NoteRepository` di domain dan `NoteRepositoryImpl` di data. |
| A-03 | `lib/data/repositories/note_repository.dart:19,32,47` | Repository melakukan mapping melalui `fromMap`/`toMap`. | Pindahkan mapping ke model data dengan method `toEntity`. |
| A-04 | `lib/pages/note_detail_page.dart:29` | Presentation memformat waktu melalui `toLocal()`. | Pindahkan aturan formatting ke fungsi murni, misalnya `core/format.dart`. |
| A-05 | `lib/widgets/note_tile.dart:4` | Widget mengimpor tipe dari `data/local`. | Ubah widget agar menerima entity domain. |
| A-06 | `lib/pages/*.dart:4` | Page bergantung langsung pada `data/providers.dart`. | Expose provider fitur melalui layer presentation/DI yang bergantung pada domain. |
| A-07 | `lib/pages/posts_page.dart:28-31` | Page membaca `Map<String, dynamic>` mentah. | Evaluasi model posts pada data dan tipe yang aman untuk presentation. |
| A-08 | `lib/data/providers.dart:9,11,45` | Provider membuat `PrefsRepository`, `NoteRepository`, dan `Dio` konkret. | Pusatkan wiring dan expose abstraksi domain; pertahankan client sebagai dependency data. |
| A-09 | `lib/data/providers.dart:39-107` | Provider file menggabungkan DI, state notifier, dan operasi fitur. | Pisahkan provider berdasarkan fitur/layer tanpa mengubah perilaku. |
| A-10 | `lib/data/sync.dart:12-93` | Cache posts mencampur Dio, SQLite, JSON, dan orchestration. | Pisahkan data source/model dan gunakan kontrak yang jelas bila masuk scope refactor. |
| A-11 | `test/note_test.dart:8-24` | Fake mewarisi repository SQLite konkret. | Ubah fake agar mengimplementasikan kontrak domain tanpa membuka database. |
| A-12 | `lib/data/sync.dart:97-110` | Sinkronisasi menerima `NoteRepository` konkret. | Evaluasi agar operasi bergantung pada interface domain. |

## Rancangan target feature-first

Rancangan ini hanya dokumentasi. Tidak ada folder atau file target yang dibuat pada Tahap 2.

```text
lib/
├── core/
│   ├── failures.dart
│   ├── format.dart
│   └── providers.dart                 # opsional, hanya dependency lintas fitur
├── features/
│   └── notes/
│       ├── domain/
│       │   ├── entities/
│       │   │   └── note.dart           # entity murni
│       │   ├── repositories/
│       │   │   └── note_repository.dart # interface
│       │   └── usecases/
│       │       └── get_notes.dart       # bila aturan/use case dibutuhkan
│       ├── data/
│       │   ├── datasources/
│       │   │   └── notes_local_data_source.dart # opsional
│       │   ├── models/
│       │   │   └── note_model.dart
│       │   └── repositories/
│       │       └── note_repository_impl.dart
│       └── presentation/
│           ├── providers/
│           │   └── note_providers.dart
│           ├── pages/
│           └── widgets/
├── features/posts/                    # bila audit posts dilanjutkan
├── features/settings/                 # bila audit preferences dilanjutkan
└── main.dart                          # composition root dan routing
```

Arah dependensi yang dipertahankan:

```text
presentation → domain ← data
```

Domain tidak mengimpor Flutter, Dio, SQLite, SharedPreferences, atau package infrastruktur. Model data memetakan row SQLite ke entity domain. Provider menjadi tempat Dependency Injection dan tidak membuat widget mengakses data source langsung.

## Checklist Tahap 2

- [x] Project Minggu 5 yang disepakati telah diaudit.
- [x] Baseline sebelum perubahan terdokumentasi pada commit Tahap 1.
- [x] Semua file `lib/` dan `test/` yang relevan dipetakan.
- [x] Tiga pencarian arsitektur dijalankan; path `lib/providers` yang tidak ada dicatat transparan.
- [x] Hasil pencarian aktual dicatat.
- [x] Setiap temuan diberi ID dan rencana refactor.
- [x] Rancangan feature-first untuk fitur `notes` dibuat.
- [x] Arah dependensi `presentation → domain ← data` dijelaskan.
- [x] Tidak ada source code yang diubah.
- [x] Tidak ada implementasi Step 4.
- [ ] `flutter analyze` — BLOCKED karena `pubspec.yaml` tidak tersedia.
- [ ] `flutter test` — BLOCKED karena `pubspec.yaml` tidak tersedia.

## Bukti screenshot

Tidak ada screenshot dibuat. Tahap ini menghasilkan bukti tekstual berupa hasil pencarian command dan tabel audit; tidak ada aplikasi atau test yang dapat dijalankan karena metadata Flutter tidak tersedia.
