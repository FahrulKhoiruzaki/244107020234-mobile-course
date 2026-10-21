# **Local Storage & Offline First**

## Pengujian SQLite CRUD

| halaman_awal |
|:---:|
| <img src="screenshots/sqlite_1.png" width="250"> |

| tambahkan_catatan | setelah_keluar_app |
|:---:|:---:|
| <img src="screenshots/sqlite_2.png" width="250"> | <img src="screenshots/sqlite_3.png" width="250"> |

| tes_hapus | dihapus |
|:---:|:---:|
| <img src="screenshots/sqlite_4.png" width="250"> | <img src="screenshots/sqlite_5.png" width="250"> |

| keluar_buka_apps |
|:---:|
| <img src="screenshots/sqlite_6.png" width="250"> |

## Offline First

| halaman_offline |
|:---:|
| <img src="screenshots/offline_1.png" width="250"> |

| buat_catatan | buka_kembali |
|:---:|:---:|
| <img src="screenshots/offline_2.png" width="250"> | <img src="screenshots/offline_3.png" width="250"> |

| force_offline_aktif | sinkronisasi_offline |
|:---:|:---:|
| <img src="screenshots/offline_4.png" width="250"> | <img src="screenshots/offline_5.png" width="250"> |

| sinkronisasi |
|:---:|
| <img src="screenshots/offline_6.png" width="250"> |

## AI Challenge

| flutter_analyze_test |
|:---:|
| <img src="screenshots/ai_9.png" width="250"> |

| halaman_awal |
|:---:|
| <img src="screenshots/ai_1.png" width="250"> |

| tambah_catatan | buka_kembali |
|:---:|:---:|
| <img src="screenshots/ai_2.png" width="250"> | <img src="screenshots/ai_3.png" width="250"> |

| tambah_catatan_offline | buka_kembali_offline |
|:---:|:---:|
| <img src="screenshots/ai_4.png" width="250"> | <img src="screenshots/ai_5.png" width="250"> |

| sinkronisasi_aktif | sinkronisasi_mati |
|:---:|:---:|
| <img src="screenshots/ai_6.png" width="250"> | <img src="screenshots/ai_10.png" width="250"> |

| ubah_gelap | buka_kembali |
|:---:|:---:|
| <img src="screenshots/ai_7.png" width="250"> | <img src="screenshots/ai_8.png" width="250"> |

### AI Verification Checklist

1. **Apakah AI menempatkan daftar catatan di SharedPreferences?**
   Tidak. Daftar catatan disimpan menggunakan SQLite karena lebih sesuai untuk menyimpan koleksi data yang membutuhkan operasi CRUD. SharedPreferences digunakan untuk menyimpan preferensi tema dan waktu terakhir aplikasi dibuka.

2. **Apakah skema AI mendukung antrean sync (`dirty flag` / `updated_at`) atau hanya CRUD polos?**
   Ya. Model `Note` memiliki atribut `dirty` dan `updatedAt` untuk menandai catatan yang belum disinkronkan serta mencatat waktu pembaruan. Proses sinkronisasi masih berupa simulasi.

3. **Apakah klaim "real-time" AI didukung stream (Drift/watch) atau hanya asumsi?**
   Implementasi belum menggunakan stream dari Drift atau mekanisme `watch`. Pembaruan data dilakukan melalui pemanggilan ulang fungsi untuk membaca data, sehingga belum dapat diklaim sebagai pembaruan real-time berbasis stream.

4. **Apakah estimasi boilerplate AI masuk akal setelah Anda mencoba instalasinya (`flutter pub add` + migrasi skema)?**
   Proyek menggunakan `shared_preferences`, `sqflite`, dan `path` sebagai dependensi penyimpanan lokal. Skema tabel dibuat melalui kode inisialisasi database. Kesesuaian estimasi boilerplate dinilai berdasarkan proses instalasi dependensi dan pengujian implementasi pada proyek.

5. **Keputusan final beserta alasannya**
   SQLite dipilih untuk menyimpan catatan karena mendukung operasi CRUD dan penyimpanan data terstruktur. SharedPreferences digunakan untuk preferensi sederhana. Atribut `dirty` dan `updatedAt` disertakan untuk mendukung proses sinkronisasi. Sinkronisasi saat ini masih berupa simulasi dan implementasi belum menggunakan stream real-time.


## Refactoring, testing, dan error umum

| flutter_analyze | flutter_test |
|:---:|:---:|
| <img src="screenshots/refac_analyze.png" width="250"> | <img src="screenshots/refac_test.png" width="250"> |

### Checklist verifikasi mandiri

- [x] UI tidak memanggil SQLite/SharedPreferences langsung; semua lewat repository + provider.
- [x] Aplikasi penuh berfungsi dalam mode pesawat: baca, tambah, hapus catatan.
- [x] Badge dirty akurat sebelum/sesudah sync; cache posts tampil tanpa internet.
- [x] `flutter analyze` tanpa issue dan semua test lulus.
- [x] Hasil AI diverifikasi dan didokumentasikan pada folder `docs/`.

## Tugas dan Refleksi

| flutter_analyze | flutter_test |
|:---:|:---:|
| <img src="screenshots/tugas_analyze.png" width="250"> | <img src="screenshots/tugas_test.png" width="250"> |

### Hasil

| halaman_awal |
|:---:|
| <img src="screenshots/tugas_1.png" width="250"> |

| menambahkan_catatan_offline |
|:---:|
| <img src="screenshots/tugas_2.png" width="250"> |

| menyinkronkan |
|:---:|
| <img src="screenshots/tugas_3.png" width="250"> |

| mode_gelap |
|:---:|
| <img src="screenshots/tugas_4.png" width="250"> |

### Refleksi

- **Mengapa daftar catatan tidak boleh disimpan di SharedPreferences? Apa yang rusak jika aturan ini dilanggar?**  
  Karena SharedPreferences digunakan untuk data sederhana berupa key-value, bukan data terstruktur seperti daftar catatan. Jika dipaksakan, pengelolaan CRUD, pencarian, dan perubahan data menjadi lebih sulit serta tidak efisien.

- **Kapan cache-first cukup, dan kapan membutuhkan strategi lain?**
  Cache-first cukup ketika data lokal masih dapat digunakan dan tidak harus selalu terbaru, seperti catatan. Untuk data yang harus selalu terbaru, seperti harga real-time, lebih tepat menggunakan network-first agar aplikasi mengambil data terbaru dari server.

- **Bagaimana dirty flag berubah menjadi antrean sync tanpa memblokir UI? Kapan antrean terpisah (tabel outbox) menjadi perlu?**
  Data yang memiliki `dirty = true` dianggap sebagai data yang perlu disinkronkan. Proses sync dapat dijalankan secara asynchronous di background sehingga UI tetap dapat digunakan. Tabel outbox diperlukan jika jumlah perubahan semakin banyak atau membutuhkan antrean operasi yang lebih terstruktur dan dapat menyimpan setiap operasi yang belum berhasil dikirim.

- **Bagian mana dari rekomendasi AI yang ditolak, dan mengapa?**
  Rekomendasi AI yang menyimpan daftar catatan di SharedPreferences ditolak karena tidak sesuai untuk data terstruktur dan operasi CRUD. Untuk catatan, SQLite lebih sesuai karena mendukung tabel, query, dan pengelolaan data yang lebih baik.