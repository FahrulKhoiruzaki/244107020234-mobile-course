# Refleksi Final — Step 8

Dokumen ini menjawab pertanyaan refleksi resmi pada penutupan Codelab Clean Architecture Week 7. Jawaban dibatasi pada keputusan yang benar-benar diterapkan di target `07-week-7-clean-architecture/`: feature `notes`, adapter lokal `announcements`, provider Riverpod, dan compatibility seam dari project sebelumnya.

## 1. Mengapa interface repository tinggal di Domain, bukan di Data? Apa yang rusak bila dibalik?

Interface repository berada di Domain karena Domain membutuhkan kemampuan bisnis—misalnya mengambil daftar `Note` atau `Announcement`—tanpa perlu mengetahui apakah data berasal dari SQLite, HTTP, cache, atau fake test. Kontrak `NoteRepository` dan `AnnouncementRepository` mendeskripsikan kebutuhan tersebut, sedangkan `NoteRepositoryImpl` dan `AnnouncementRepositoryImpl` menerjemahkannya ke detail Data. Dengan susunan ini, arah dependency tetap:

```text
presentation → domain ← data
```

Manfaat konkretnya terlihat pada test `GetNotes` dan `GetAnnouncements`: fake cukup mengimplementasikan kontrak Domain dan tidak perlu membuka SQLite, Dio, Firebase, atau jaringan. Entity Domain juga tidak membawa `fromMap`, `toMap`, nama kolom SQLite, atau import infrastructure; mapping dilakukan oleh model Data.

Jika interface diletakkan di Data, Domain dan test akan bergantung pada lokasi serta vocabulary infrastructure. Beberapa hal yang rusak atau menjadi lebih mahal:

1. use case perlu mengimpor layer Data hanya untuk menemukan kontrak;
2. fake test berisiko mewarisi repository konkret atau ikut mengetahui detail database;
3. penggantian SQLite dengan API atau cache memaksa perubahan pada Domain;
4. dependency rule berbalik sehingga detail teknis menjadi pusat yang menentukan aturan bisnis;
5. batas antara kontrak yang stabil dan implementasi yang berubah menjadi kabur.

Memindahkan interface ke Domain tidak berarti Data hilang. Data tetap menjadi implementor yang mengetahui schema, JSON, database, dan error translation; Data hanya bergantung ke kontrak yang lebih stabil.

## 2. Kapan use case benar-benar dibutuhkan, dan kapan repository langsung ke notifier sudah cukup?

Use case layak dipakai ketika operasi memiliki nama dan tujuan bisnis yang jelas, validasi, transformasi, sorting/filtering bisnis, orkestrasi beberapa repository, retry/cache policy, sinkronisasi, atau ketika boundary tersebut perlu diuji dan dikembangkan secara terpisah. `GetNotes` dan `GetAnnouncements` digunakan sebagai entry point read yang dapat diuji dengan fake repository dan menjaga notifier/provider tidak bergantung langsung pada implementasi Data.

Repository langsung ke notifier/provider masih cukup untuk operasi yang benar-benar tipis: satu pemanggilan repository, tanpa aturan bisnis, tanpa transformasi, dan tanpa rencana orkestrasi. Untuk CRUD sederhana pada feature kecil, tambahan use case dapat menjadi indirection yang tidak memberi perilaku baru. Pilihan ini harus dievaluasi per operasi, bukan dipaksakan seragam ke semua method.

Pada target ini, provider tetap menjadi composition boundary. Provider membuat implementasi repository dan use case, sedangkan page hanya membaca state. Compatibility seam lama tetap dipakai untuk operasi CRUD/sync yang belum memiliki kontrak Domain lengkap. Itu adalah keputusan migrasi bertahap, bukan klaim bahwa seluruh legacy path sudah menjadi Clean Architecture.

## 3. Apa biaya over-engineering use case satu-baris per CRUD bagi tim kecil? Kapan biayanya sepadan?

Biayanya meliputi lebih banyak file dan nama, navigasi kode yang lebih panjang, boilerplate constructor/call method, waktu review, dan beban kognitif bagi anggota tim yang hanya ingin memahami alur CRUD sederhana. Jika setiap method hanya meneruskan argumen ke repository, use case dapat menyamarkan fakta bahwa tidak ada policy bisnis di antaranya. Untuk tim kecil, ceremony seperti ini dapat memperlambat perubahan tanpa meningkatkan correctness atau testability secara berarti.

Biaya tersebut sepadan ketika use case menjadi boundary yang memang bernilai, misalnya:

- aturan bisnis akan berkembang atau dipakai oleh lebih dari satu UI;
- beberapa sumber data harus diorkestrasi;
- validasi, authorization, retry, cache, atau transaction policy perlu dipusatkan;
- operasi perlu diuji terpisah dari Riverpod dan infrastructure;
- nama operasi bisnis lebih bermakna daripada method persistence generik;
- tim menginginkan dependency graph dan titik observability yang konsisten pada domain yang cukup kompleks.

Keputusan Week 7 adalah selektif: `GetNotes` dan `GetAnnouncements` dipertahankan karena menjadi boundary read yang diuji, tetapi tidak dibuat use case satu-baris untuk seluruh CRUD/sync legacy yang belum memiliki policy baru. Dengan begitu, abstraksi mengikuti kebutuhan feature dan risiko perubahan, bukan checklist jumlah class.

## 4. Bagian mana dari usulan AI yang ditolak atau disederhanakan, dan mengapa?

Usulan AI diterima sebagai proposal untuk dependency direction, repository contract di Domain, model/mapping di Data, Riverpod sebagai composition boundary, dan larangan widget membuat repository atau client. Namun beberapa bagian ditolak atau disederhanakan:

1. **Migrasi auth dan announcements Week 6 tidak dilakukan pada tahap AI Challenge.** Target Week 7 berisi feature `notes`, sedangkan Week 6 memiliki perubahan lokal yang harus dipertahankan. Kontrak endpoint dan schema backend announcements juga tidak tersedia secara verifiable. Mengimplementasikan migrasi berdasarkan tebakan akan menghasilkan klaim yang tidak grounded.
2. **Struktur `app/` besar tidak ditambahkan.** Untuk target feature `notes` yang kecil, `main.dart` sebagai composition root dan provider feature sudah cukup. Menambah `app.dart`, router wrapper, dan provider hierarchy tambahan tanpa kebutuhan nyata hanya menambah ceremony.
3. **Use case tidak dibuat untuk setiap method CRUD/sync.** Operasi legacy belum memiliki policy Domain yang lengkap. `GetNotes` dan `GetAnnouncements` cukup untuk boundary read yang benar-benar dipakai dan diuji; class satu-baris tambahan akan menambah indirection tanpa manfaat sepadan.
4. **Compatibility seam tidak langsung dihapus.** Provider lama dan cache-first path masih dibutuhkan oleh operasi yang belum dimigrasikan. Seam ini menjaga behavior existing selama refactor bertahap, dengan konsekuensi bahwa audit akhir harus membedakan provider composition boundary yang diizinkan dari page/widget yang tidak boleh mengakses infrastructure.
5. **Tidak ada dependency atau konfigurasi baru.** AI dapat mengusulkan struktur yang memerlukan package atau metadata project, tetapi target tidak memiliki `pubspec.yaml`. Menambahkan konfigurasi tanpa instruksi terpisah akan mengubah scope dan membuat status verifikasi menjadi menyesatkan.

Keputusan tersebut mengikuti source yang dapat dibuktikan, batas scope Step 8, dan prinsip bahwa proposal AI bukan bukti implementasi atau bukti runtime.

## Referensi

Referensi berikut adalah bahan pembelajaran dan pembanding konsep, bukan bukti bahwa seluruh target dapat dijalankan:

- [Codelab Clean Architecture Week 7](https://jti-polinema.github.io/flutter-codelab/07-minggu-7-clean-architecture/index.html#1)
- [Flutter App Architecture Guide](https://docs.flutter.dev/app-architecture/guide)
- [Robert C. Martin — The Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Riverpod — Providers](https://riverpod.dev/docs/concepts/providers)
- [Dart — Records](https://dart.dev/language/records)
- [fpdart](https://pub.dev/packages/fpdart)
- [GoRouter](https://go_router.dev/)
- [Learn X in Y Minutes — Dart](https://learnxinyminutes.com/docs/dart/)

Codelab juga mencantumkan path slide lokal `../00-slides/Week_07_Clean_Architecture.html`, tetapi file tersebut tidak tersedia pada checkout ini. Karena itu, path tersebut dicatat sebagai referensi yang tidak tersedia, bukan diklaim telah dibaca.
