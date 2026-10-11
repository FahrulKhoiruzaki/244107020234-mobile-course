# Week 4 - Networking & REST API

## Tujuan

Membangun aplikasi Flutter yang mengambil data dari REST API dan menampilkan data melalui Repository dan Riverpod. Proyek ini mengikuti tugas Mini Project / Industry Challenge pada modul Week 4.

## Fitur utama

- Mengambil daftar post dari JSONPlaceholder `/posts`.
- Konfigurasi Dio terpusat: base URL, timeout 10 detik, header, dan logging interceptor.
- Model `Post` dan `Comment` dengan parsing JSON aman terhadap field hilang atau `null`.
- UI dengan state loading, error dengan retry, empty, dan success.
- Pagination server-side menggunakan `_page` dan `_limit`, 10 item per halaman.
- Guard untuk mencegah request pagination ganda.
- Detail post melalui GoRouter `/post/:id`.
- AI Challenge untuk endpoint `/comments?postId={id}`.
- Unit test model, pemetaan error, dan provider menggunakan repository palsu.

## Stack teknologi

- Flutter dan Dart
- Dio
- Riverpod (`flutter_riverpod`)
- GoRouter
- JSONPlaceholder

## Struktur proyek

```text
lib/
  data/
    api_client.dart
    network_errors.dart
    paged_posts.dart
    providers.dart
    models/
    repositories/
  pages/
  widgets/
test/
docs/
screenshots/
```

## Cara menjalankan

1. Pastikan Flutter SDK sudah terpasang.
2. Buka terminal di folder proyek.
3. Ambil dependency:

   ```bash
   flutter pub get
   ```

4. Jalankan pemeriksaan statis:

   ```bash
   flutter analyze
   ```

5. Jalankan unit test:

   ```bash
   flutter test
   ```

6. Jalankan aplikasi pada emulator atau perangkat:

   ```bash
   flutter run
   ```

## Navigasi

- `/` menampilkan daftar post.
- Ketuk item untuk membuka detail post.
- Tombol ikon pagination pada app bar membuka halaman `/paged`.
- `/post/1` dapat dibuka langsung untuk mengambil detail post melalui repository.

## Hasil yang dicapai

Catat hasil aktual setelah menjalankan proyek. Jangan menyatakan test lolos sebelum melihat hasil terminal terbaru.

- `flutter analyze`: _isi berdasarkan hasil aktual_
- `flutter test`: _isi berdasarkan hasil aktual_
- Pagination dan detail post: _isi setelah pengujian manual_

## Dokumentasi AI

Lihat [`docs/ai-challenge.md`](docs/ai-challenge.md) untuk prompt, ringkasan implementasi, perbaikan, dan alasan teknis.

## Screenshot

Simpan screenshot aplikasi yang benar-benar dijalankan di folder `screenshots/`. Contoh yang disarankan sesuai fitur modul: daftar post, state error/retry, halaman pagination, dan halaman detail.
