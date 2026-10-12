# Dokumentasi Penggunaan AI

## 1. Tujuan Penggunaan AI

AI digunakan sebagai alat bantu selama pengembangan aplikasi **Offline Notes** pada praktikum Local Storage & Offline First. Penggunaan AI bertujuan membantu memahami struktur kode Flutter, memperbaiki kesalahan program, dan memeriksa implementasi fitur penyimpanan lokal.

## 2. Bagian yang Dibantu AI

Beberapa bagian yang dibantu selama pengembangan aplikasi adalah:

1. **Struktur aplikasi Flutter**
   Membantu menyusun halaman daftar catatan, dialog tambah catatan, dan halaman pengaturan.

2. **Penyimpanan lokal SQLite**
   Membantu memahami penggunaan repository untuk menyimpan, membaca, dan menghapus catatan secara lokal.

3. **SharedPreferences**
   Membantu implementasi penyimpanan preferensi Mode Gelap dan waktu terakhir aplikasi dibuka.

4. **Mode offline dan sinkronisasi**
   Membantu memahami mekanisme Force Offline serta simulasi sinkronisasi catatan yang belum tersinkronisasi.

5. **Debugging**
   Membantu menganalisis error `TextEditingController was used after being disposed` dan kesalahan pemanggilan fungsi `_addNote()` yang tidak sesuai dengan deklarasinya.

## 3. Proses Debugging

Pada proses pengembangan, aplikasi mengalami error ketika tombol tambah catatan ditekan. Berdasarkan log Terminal, ditemukan penggunaan `TextEditingController` setelah controller tersebut di-dispose.

Perbaikan dilakukan dengan memisahkan dialog tambah catatan ke dalam widget tersendiri, yaitu `AddNoteDialog`. Controller dikelola melalui `initState()` dan `dispose()` pada State dialog. Data catatan dikembalikan ke halaman utama, kemudian disimpan melalui `NoteRepository`.

Selain itu, pemanggilan fungsi tambah catatan disesuaikan agar tidak lagi menggunakan argumen yang tidak didukung.

## 4. Verifikasi Hasil

Kode hasil perbaikan perlu diverifikasi melalui langkah berikut:

* Menjalankan `flutter analyze` untuk memeriksa masalah pada kode.
* Menjalankan `flutter test` untuk menjalankan pengujian otomatis.
* Menjalankan aplikasi pada perangkat untuk memeriksa fitur tambah, baca, dan hapus catatan.
* Memeriksa apakah catatan tetap tersedia setelah aplikasi dibuka kembali.
* Memeriksa apakah preferensi Mode Gelap tersimpan.
* Menguji Force Offline dan simulasi sinkronisasi.

Hasil pengujian dicatat berdasarkan hasil yang benar-benar diperoleh ketika aplikasi dijalankan.

## 5. Batasan Penggunaan AI

AI digunakan sebagai alat bantu, bukan sebagai pengganti proses pemahaman dan pengujian kode. Implementasi akhir tetap perlu diperiksa agar sesuai dengan jobsheet praktikum.

Fitur sinkronisasi pada aplikasi ini merupakan simulasi. Keberhasilan sinkronisasi simulasi tidak berarti data telah dikirim ke server sungguhan.

## 6. Kesimpulan

Penggunaan AI membantu proses pengembangan dan debugging aplikasi Offline Notes. Melalui proses tersebut, struktur kode dapat diperbaiki dan pemahaman mengenai penyimpanan lokal, pengelolaan state, serta siklus hidup widget Flutter dapat ditingkatkan. Seluruh fitur dan hasil pengujian tetap perlu diverifikasi sebelum aplikasi dikumpulkan.
