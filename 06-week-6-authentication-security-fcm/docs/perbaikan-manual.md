# Perbaikan Manual AI Challenge

Setelah memeriksa kode awal AI, dilakukan beberapa penyesuaian dan pengujian pada aplikasi Campus Notify.

## 1. Perbaikan pada PushService

- Menambahkan konstanta `_topic` untuk menyimpan nama topic `pengumuman-kampus`.
- Memisahkan proses subscribe ke dalam fungsi `subscribeToTopic()`.
- Menambahkan fungsi `unsubscribeFromTopic()` untuk berhenti berlangganan topic.
- Memastikan proses inisialisasi FCM memanggil `subscribeToTopic()`.
- Mempertahankan pengiriman token baru ke backend melalui callback `onToken` pada `onTokenRefresh`.
- Memastikan token yang ditampilkan pada debug log hanya 12 karakter pertama dan diikuti tanda `...`.

## 2. Pengujian Manual

Pengujian dilakukan menggunakan perangkat Redmi Note 9 Pro.

| Pengujian | Hasil |
|---|---|
| Izin notifikasi | Berhasil |
| Pengambilan FCM token | Berhasil |
| Registrasi token ke backend melalui `/devices` | Berhasil |
| Notifikasi foreground | Berhasil |
| Notifikasi background | Berhasil |
| Notifikasi terminated | Berhasil |
| Navigasi ke rute dari data notifikasi | Berhasil |
| Subscribe topic `pengumuman-kampus` | Berhasil |
| Menerima notifikasi setelah subscribe | Berhasil |
| Unsubscribe topic `pengumuman-kampus` | Berhasil |
| Tidak menerima notifikasi setelah unsubscribe | Berhasil |

## 3. Hasil Pemeriksaan Kode

- Background handler menggunakan fungsi top-level dengan `@pragma('vm:entry-point')`.
- Background handler tidak menggunakan `BuildContext` maupun Riverpod.
- Foreground menggunakan local notification untuk menampilkan notifikasi secara manual.
- Penanganan notifikasi menggunakan `onMessage`, `onMessageOpenedApp`, dan `getInitialMessage`.
- Token tidak di-hardcode dan tidak ditampilkan secara penuh pada debug log.

## 4. Catatan

Pengujian dilakukan pada perangkat Android. Pengujian pada iOS belum dilakukan.

Pengujian pembaruan token melalui `onTokenRefresh` sudah diimplementasikan, tetapi belum dilakukan simulasi perubahan token secara langsung.
