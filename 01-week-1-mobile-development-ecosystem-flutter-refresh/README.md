# Pertemuan Minggu 1

## Tujuan
Tugas ini untuk memahami ekosistem pengembangan mobile lintas platform menggunakan Flutter, serta praktek pembuatan desain (UI) dasar secara deklaratif.

## Fitur Utama
- Menampilkan UI profil sederhana
- Menampilkan ikon sekolah
- Menampilkan nama, nim, dan satu informasi tambahan

## Stack Teknologi
- **Bahasa:** Dart
- **Framework:** Flutter

## Cara Menjalankan
1. Pastikan Flutter SDK telah terinstal dan terkonfigurasi.
2. Buka terminal dan arahkan ke dalam folder proyek ini.
3. Jalankan aplikasi dengan perintah `flutter run`.
4. Untuk memperbarui perubahan UI tanpa menghapus *state*, tekan `r` (hot reload) di terminal.
5. Untuk memuat ulang aplikasi dari awal, tekan `R` (hot restart) di terminal.

## Hasil yang Dicapai
Berhasil membuat aplikasi pertama yang ada struktur 'Widget tree', dan berhasil mencoba perbedaan kecepatan dan retensi antara fitur *hot reload* dan *hot restart*

## Bukti
![output](01-week-1-mobile-development-ecosystem-flutter-refresh/screenshot/hasil_1.png)
![output mini assignment](01-week-1-mobile-development-ecosystem-flutter-refresh/screenshot/hasil_Mini_Assignment.png)

## Refleksi
**1. Kapan native lebih tepat dipilih daripada cross-platform?**
Memilih native jika aplikasinya butuh performa sangat berat, butuh akses langsung ke fitur hardware rumit (kamera/sensor), atau memang targetnya cuma satu OS aja.
**2. Bagaimana perubahan state berhubungan dengan widget tree dan UI deklaratif?**
Tampilan (UI) itu hanya cerminan dari data. Kalau datanya berubah, flutter tidak edit tampilan yang lama, tapi langsung menggambar ulang susunan widgetnya agar sesuai dengan data yang baru.
**3. Mengapa commit kecil dengan pesan jelas bermanfaat bagi pekerjaan tim dan portfolio?**
Untuk tim: Biar kode tidak mudah bentrok dan teman setim langsung paham apa yang kita ubah tanpa harus membaca seluruh kodenya.
Untuk portofolio: Untuk bukti kerapian dan profesional.