# Tahap 1 — Konsep SOLID dan Clean Architecture

Dokumentasi ini merupakan artifact Tahap 1 (Step 1 + Step 2) praktikum Minggu 7. Step 1 adalah pembuka, sedangkan isi pembelajaran utama berasal dari bagian konsep SOLID dan Clean Architecture pada Codelab resmi:

<https://jti-polinema.github.io/flutter-codelab/07-minggu-7-clean-architecture/index.html#1>

Tahap ini hanya mendokumentasikan pemahaman konsep. Belum ada perubahan source code, pemindahan file, refactoring, atau penambahan dependency.

## Tujuan

Clean Architecture digunakan untuk memisahkan aturan bisnis dari framework dan detail infrastruktur. Dengan pemisahan ini, kode domain dapat diuji tanpa database atau jaringan, implementasi penyimpanan dapat diganti, dan perubahan pada UI tidak perlu mengubah aturan bisnis.

## SOLID dalam Flutter

- **Single Responsibility Principle** — satu class memiliki satu alasan utama untuk berubah. Page tidak seharusnya sekaligus mengatur UI, melakukan query SQLite, memanggil API, dan mem-parsing response.
- **Open/Closed Principle** — perilaku dapat diperluas melalui abstraksi atau implementasi baru tanpa terus memodifikasi kode inti yang sudah stabil.
- **Liskov Substitution Principle** — implementasi pengganti, termasuk fake repository pada test, harus tetap memenuhi kontrak repository.
- **Interface Segregation Principle** — kontrak dibuat secukupnya agar client tidak dipaksa bergantung pada operasi yang tidak digunakannya.
- **Dependency Inversion Principle** — domain dan presentation bergantung pada abstraksi, bukan langsung pada Dio, SQLite, Firebase, atau package infrastruktur lainnya.

SOLID bukan alasan untuk membuat abstraksi sebanyak mungkin. Abstraksi harus mengurangi coupling dan memberikan manfaat yang dapat dijelaskan.

## Tiga layer

### Presentation

Layer ini berisi page, widget, notifier, routing, dan pengelolaan state. Presentation membaca state, mengirim input pengguna ke domain, serta menampilkan loading, error, dan data. Widget tidak membuat repository atau client secara manual.

### Domain

Layer ini berisi entity, kontrak repository, use case, failure, dan aturan bisnis. Domain tidak boleh mengimpor Flutter, Dio, SQLite, Firebase, atau detail infrastruktur lain.

### Data

Layer ini berisi model, implementasi repository, database, API client, secure storage, serta adapter untuk sumber data eksternal. Mapping database/JSON dan parsing format eksternal ditempatkan di sini, bukan di entity atau widget.

## Arah dependensi

Dependensi diarahkan ke dalam:

```text
presentation → domain ← data
```

Presentation menggunakan kontrak atau operasi domain. Data mengimplementasikan kontrak domain. Domain tidak mengetahui bagaimana data disimpan atau bagaimana UI dibangun.

Pemindahan file ke folder baru saja belum cukup. Import dan tanggung jawab yang melanggar arah dependensi juga harus diperbaiki pada tahap refactoring berikutnya.

## Feature-first dan layer-first

- **Feature-first** mengelompokkan `domain`, `data`, dan `presentation` di dalam setiap fitur, misalnya `features/notes/`.
- **Layer-first** mengelompokkan seluruh entity, repository, dan page ke folder global berdasarkan layer.

Untuk project yang memiliki beberapa fitur, feature-first dipilih karena batas fitur lebih mudah ditemukan, dikembangkan, dan diuji. Layer-first masih dapat masuk akal untuk project yang sangat kecil. Pilihan struktur harus mengikuti ukuran dan kompleksitas project, bukan sekadar mengikuti pola populer.

## Entity, model, dan repository

### Entity

Entity adalah object bisnis murni. Entity `Note` hanya menjelaskan data dan makna bisnis seperti `id`, `title`, `body`, `updatedAt`, dan status `dirty`.

Entity tidak boleh memiliki:

- `toMap`, `fromMap`, `toJson`, atau `fromJson`;
- nama kolom SQLite;
- parsing tanggal dari string eksternal;
- dependency pada Flutter atau database.

### Model

Model adalah representasi data dari SQLite, JSON, atau sumber eksternal lainnya. Model bertanggung jawab melakukan konversi antara data eksternal dan entity, termasuk parsing tanggal dan konversi nilai `dirty` ke format database.

### Repository

Interface repository ditempatkan di domain karena domain membutuhkan kemampuan mengambil atau menyimpan data, tetapi tidak perlu mengetahui detail sumber datanya. Implementasi repository ditempatkan di data dan boleh menggunakan SQLite, Dio, atau layanan eksternal.

Pemisahan ini membuat implementasi repository dapat diganti dengan fake repository saat pengujian domain tanpa menjalankan database atau jaringan.

## Dependency Injection

Dependency Injection berarti dependency diberikan dari luar class yang memakainya. Pada project Flutter ini, Riverpod menjadi tempat wiring utama:

1. provider data source atau database dibuat di provider;
2. provider repository mengembalikan implementasi konkret sebagai interface domain;
3. provider use case menerima interface repository bila use case diperlukan;
4. provider notifier menerima use case atau repository melalui dependency tersebut;
5. widget hanya membaca state dan memanggil notifier.

Dengan pola ini, presentation tidak membuat `NoteRepository`, `Dio`, atau database secara langsung dan test dapat mengganti dependency melalui override.

## Pertimbangan penggunaan use case

Use case layak digunakan jika terdapat validasi, aturan bisnis, penggabungan beberapa repository, sorting/filtering khusus, atau sinkronisasi. Use case juga dapat menjadi boundary yang jelas untuk operasi domain yang memiliki nama dan tujuan bisnis.

Untuk CRUD sederhana yang hanya meneruskan satu pemanggilan repository, use case tambahan dapat menjadi boilerplate tanpa manfaat sepadan. Keputusan akhir harus didasarkan pada kompleksitas operasi dan kebutuhan pengujian. Tidak semua method repository harus otomatis dibungkus use case.

## Trade-off dan keputusan untuk tahap berikutnya

Project target adalah `05-week-5-local-storage-offline-first` dengan fitur catatan sebagai kandidat fitur utama. Kondisi existing menunjukkan bahwa `Note` masih mencampur entity dan mapping SQLite, `NoteRepository` masih mencampur kontrak dengan implementasi, dan provider masih langsung menggunakan repository konkret.

Acuan refactoring yang akan digunakan pada tahap berikutnya:

1. memakai struktur feature-first untuk fitur `notes`;
2. memindahkan entity `Note` ke domain sebagai class Dart murni;
3. membuat kontrak `NoteRepository` di domain;
4. membuat `NoteModel` dan `NoteRepositoryImpl` di data;
5. menyimpan failure dan formatter murni di `core` bila benar-benar diperlukan;
6. menempatkan wiring Riverpod pada provider;
7. menjaga fitur SQLite, dirty flag, cache-first, sinkronisasi simulasi, dan tema tetap berjalan;
8. membuat use case hanya untuk operasi yang memiliki alasan domain yang jelas;
9. menguji use case dengan fake repository tanpa SQLite;
10. tidak menambahkan fitur baru atau dependency baru di luar kebutuhan Codelab.

Struktur di atas masih berupa keputusan dan rencana. File implementasi belum dibuat pada Tahap 1.

## Checklist konseptual

- [x] SOLID dipahami sebagai panduan pengurangan coupling, bukan alasan membuat abstraksi berlebihan.
- [x] Peran presentation, domain, dan data telah dibedakan.
- [x] Arah dependensi menuju domain telah ditetapkan.
- [x] Entity dibedakan dari model persistence/API.
- [x] Kontrak repository ditempatkan di domain dan implementasi di data.
- [x] Dependency Injection direncanakan melalui provider Riverpod.
- [x] Keputusan penggunaan use case mempertimbangkan kompleksitas operasi.
- [x] Keputusan arsitektur untuk refactoring fitur catatan telah dicatat.

## Status verifikasi Tahap 1

- Perubahan source code: tidak ada.
- Refactoring: belum dilakukan.
- Screenshot: tidak dibuat karena tahap ini konseptual dan tidak memiliki output visual yang perlu dibuktikan.
- `flutter analyze`: **BLOCKED**, karena `pubspec.yaml` tidak tersedia di repository.
- `flutter test`: **BLOCKED**, karena `pubspec.yaml` dan metadata dependency tidak tersedia di repository.
- Klaim PASS untuk test atau analyze tidak dibuat.
