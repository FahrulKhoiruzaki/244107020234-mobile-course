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

## Praktikum 3: FCM, permission, dan token lifecycle