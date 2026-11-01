# Hasil Pengujian FCM

Pengujian Firebase Cloud Messaging (FCM) dilakukan pada perangkat Redmi Note 9 Pro untuk memastikan notifikasi dapat diterima dan diarahkan ke halaman yang sesuai pada tiga kondisi aplikasi.

## 1. Tabel Pengujian Tiga Kondisi Aplikasi

| No. | Kondisi Aplikasi | Skenario Pengujian | Hasil yang Diharapkan | Hasil Pengujian |
|---|---|---|---|---|
| 1 | Foreground | Mengirim notifikasi ketika aplikasi sedang terbuka. | Local notification muncul dan dapat diklik untuk membuka halaman pengumuman. | Berhasil |
| 2 | Background | Mengirim notifikasi ketika aplikasi berada di latar belakang, kemudian mengetuk notifikasi. | Notifikasi muncul dan aplikasi membuka halaman pengumuman sesuai rute pada data payload. | Berhasil |
| 3 | Terminated | Mengirim notifikasi ketika aplikasi sudah ditutup, kemudian mengetuk notifikasi. | Aplikasi terbuka dan diarahkan ke halaman pengumuman sesuai rute pada data payload. | Berhasil |

## 2. Pengujian Topic

| No. | Skenario | Hasil Pengujian |
|---|---|---|
| 1 | Perangkat subscribe ke topic `pengumuman-kampus`. | Berhasil |
| 2 | Mengirim notifikasi ke topic setelah subscribe. | Notifikasi diterima |
| 3 | Perangkat unsubscribe dari topic `pengumuman-kampus`. | Berhasil |
| 4 | Mengirim notifikasi ke topic setelah unsubscribe. | Notifikasi tidak diterima |
| 5 | Perangkat subscribe kembali ke topic. | Berhasil |
| 6 | Mengirim notifikasi setelah subscribe kembali. | Notifikasi diterima |

## 3. Kesimpulan

Berdasarkan pengujian, notifikasi FCM berhasil diterima pada kondisi foreground, background, dan terminated. Klik notifikasi juga berhasil mengarahkan aplikasi ke halaman pengumuman sesuai rute yang dikirim melalui data payload.

Pengujian subscribe dan unsubscribe topic juga berhasil dilakukan pada perangkat Android.

## 4. Perangkat Pengujian

- Perangkat: Redmi Note 9 Pro
- Platform: Android
- Aplikasi: Campus Notify
- Topic: `pengumuman-kampus`
- Rute pengujian: `/pengumuman/3`

## 5. Keputusan Final dan Alasan Teknis

**Keputusan Final:**

Implementasi `PushService` digunakan setelah dilakukan penyesuaian dan pengujian manual pada perangkat Android.

**Alasan Teknis:**

1. Background handler menggunakan fungsi top-level dengan `@pragma('vm:entry-point')` agar dapat dijalankan ketika aplikasi berada di background.
2. Pengiriman token melalui callback `onToken` memastikan token awal dan token yang diperbarui dapat dikirim ke backend melalui endpoint `/devices`.
3. Local notification digunakan untuk menampilkan notifikasi secara manual ketika aplikasi berada dalam kondisi foreground.
4. `onMessageOpenedApp` dan `getInitialMessage` digunakan untuk menangani navigasi ketika notifikasi dibuka dari kondisi background dan terminated.
5. Fungsi subscribe dan unsubscribe digunakan untuk mengatur keanggotaan perangkat pada topic `pengumuman-kampus`.
6. Token tidak ditampilkan secara penuh pada debug log untuk menghindari tereksposnya informasi token.

Berdasarkan hasil pengujian, implementasi dapat digunakan pada perangkat Android yang diuji. Pengujian pada iOS dan simulasi pembaruan token secara langsung belum dilakukan.
