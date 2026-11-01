# **Week 6 Authentication, Security, & FCM**

## Praktikum 1: Login + secure storage + token refresh

| struktur folder |
|:---:|
| <img src="screenshot/folder.png" width="250"> |

| flutter analyze dan flutter test |
|:---:|
| <img src="screenshot/p1_analyze_test.png" width="250"> |

### Hasil

| halaman login |
|:---:|
| <img src="screenshot/p1_halamanlogin.png" width="250"> |

| login tidak valid |
|:---:|
| <img src="screenshot/p1_login_gagal.png" width="250"> |

| login valid |
|:---:|
| <img src="screenshot/p1_login_berhasil.png" width="250"> |

| halaman pengumuman |
|:---:|
| <img src="screenshot/p1_pengumuman.png" width="250"> |

## Praktikum 2: FCM, permission, dan token lifecycle

| notifikasi |
|:---:|
| <img src="screenshot/p2_background.png" width="250"> |

| console log |
|:---:|
| <img src="screenshot/fcm-console-test.png" width="250"> |

**Pengujian Notifikasi FCM pada State Background**

Pengujian dilakukan dengan menjalankan aplikasi Campus Notify, kemudian memindahkannya ke background. Notifikasi dikirim melalui Firebase Console dengan target topic `pengumuman-kampus`. Banner notifikasi berhasil muncul pada perangkat Android. Setelah banner diklik, aplikasi Campus Notify terbuka kembali. Pada terminal juga muncul log `Notifikasi dibuka dari background`.

**Hasil:** Berhasil. Notifikasi dapat diterima dan dibuka ketika aplikasi berada dalam kondisi background.

## Praktikum 3: Payload, tiga app state, klik dan topik

| notifikasi |
|:---:|
| <img src="screenshot/p3_notif.png" width="250"> |

| klik banner |
|:---:|
| <img src="screenshot/p3_route.png" width="250"> |

| console  |
|:---:|
| <img src="screenshot/p3_console.png" width="250"> |


## AI Challenge

| notifikasi foreground  |
|:---:|
| <img src="screenshot/ai_foreground.png" width="250"> |

| notifikasi subscribe  |
|:---:|
| <img src="screenshot/ai_subscribe.png" width="250"> |

| klik notifikasi |
|:---:|
| <img src="screenshot/ai_klik_banner.png" width="250"> |

| console klik |
|:---:|
| <img src="screenshot/ai_console_klik.png" width="250"> |

## Refactoring, testing, dan error umum

| test  |
|:---:|
| <img src="screenshot/refac_test.png" width="250"> |

## Checklist Verifikasi Mandiri

- [x] Token disimpan menggunakan `flutter_secure_storage`, bukan SharedPreferences. Tampilan token pada log dibatasi dan tidak menampilkan token secara penuh.
- [x] Mekanisme refresh token diperiksa. Pengujian refresh gagal berhasil membuktikan bahwa token dihapus sehingga pengguna harus login kembali. Mekanisme refresh sukses dan retry satu kali belum diuji secara terpisah.
- [x] Ketiga kondisi aplikasi (foreground, background, dan terminated) telah diuji. Notifikasi berhasil diterima dan klik notifikasi mengarahkan ke rute yang benar.
- [x] Topik digunakan untuk broadcast, sedangkan token perangkat digunakan untuk pengiriman pesan personal.
- [x] Seluruh 11 pengujian berhasil dijalankan menggunakan `flutter test`.
- [ ] `flutter analyze` bersih tanpa informasi deprecated. Saat ini masih terdapat 2 informasi deprecated pada `getToken()` dan `onTokenRefresh` di `push_service.dart`.