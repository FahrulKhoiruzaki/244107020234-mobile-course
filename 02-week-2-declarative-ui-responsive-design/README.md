# Pertemuan Minggu 2

## Eksperimen Warm-up

**1. Hapus Expanded pada baris nama, lalu amati peringatan overflow atau perilaku layout-nya; kembalikan setelah itu.**

Penghapusan Expanded pada Baris Nama: Menyebabkan teks mengalami overflow (peringatan kuning-hitam khas Flutter) karena teks mengambil ruang tak terbatas di dalam Row.

| iPad | iPhone |
| :---: | :---: |
| ![iPad](screenshot/hasil_hapus_expand_ipad.png) | ![iPhone](screenshot/hasil_hapus_expand_iphone.png) |

**2. Ganti mainAxisSize: MainAxisSize.min menjadi nilai default dan amati perubahan tinggi kartu.**

Nilai default dari mainAxisSize di Column adalah MainAxisSize.max. Ketika diubah kembali ke default, Column akan memanjang secara vertikal, beda dengan MainAxisSize.min yang membuat tinggi kartu pas dan fleksibel mengikuti banyak konten di dalamnya.

| iPad | iPhone |
| :---: | :---: |
| ![iPad](screenshot/hasil_ubah_mainAxisSize_ipad.png) | ![iPhone](screenshot/hasil_ubah_mainAxisSize_iphone.png) |

**3. Tambahkan satu baris data (misal Email) menggunakan pola Row + Expanded yang sama.**

| iPad | iPhone |
| :---: | :---: |
| ![iPad](screenshot/hasil_email_ipad.png) | ![iPhone](screenshot/hasil_email_iphone.png) |

## Praktikum Dashboard Responsif

**Hasil praktikum dashboard responsif**

| iPad | iPhone |
| :---: | :---: |
| ![iPad](screenshot/hasil_praktikum_dashboard_responsif_ipad.png) | ![iPhone](screenshot/hasil_praktikum_dashboard_responsif_iphone.png) |

**Menambahkan StatefulWidget dan Cupertino**

| iPad | iPhone |
| :---: | :---: |
| ![iPad](screenshot/hasil_tambah_cupertino_ipad.png) | ![iPhone](screenshot/hasil_tambah_cupertino_iphone.png) |

## Eksperimen Layout

**1. Ubah breakpoint dari 700 menjadi nilai lain dan amati perubahan jumlah kolom.**

Breakpoint digunakan sebagai batas untuk menentukan perubahan layout. Jika lebar layar memenuhi nilai breakpoint, dashboard menggunakan 2 kolom. Jika tidak memenuhi, dashboard menggunakan 1 kolom. Untuk ipad air memiliki nilai 2000 sedangkan iphone 11 memakai nilai 400 untuk bisa 2 kolom

| iPad | iPhone |
| :---: | :---: |
| ![iPad](screenshot/hasil_ubah_breakpoint_2000_ipad.png) | ![iPhone](screenshot/hasil_ubah_breakpoint_400_iphone.png) |

**2. Ubah themeMode menjadi ThemeMode.dark, lalu kembalikan ke ThemeMode.system.**

ThemeMode untuk menentukan pengaturan tema aplikasi, ThemeMode.dark dan ThemeMode.light memaksa aplikasi untuk menggunakan tema tersebut, sedangkan ThemeMode.system aplikasi akan mengikuti pengaturan device yang dipakai.

| iPad | iPhone |
| :---: | :---: |
| ![iPad](screenshot/hasil_ubah_themedark_ipad.png) | ![iPhone](screenshot/hasil_ubah_themedark_iphone.png) |

**3. Uji aplikasi dengan ukuran layar emulator yang berbeda.**

Hasi menunjukkan jika aplikasi bisa menyesuaikan layout mengikuti ukuran layar. Penggunaan LayoutBuilder membuat dashboard lebih responsif jadi dapat digunakan untuk perangkat yang memiliki ukuran layar berbeda.

**4. Tambahkan Semantics atau label yang bermakna pada elemen yang penting bagi screen reader.**

Semantics membantu aksesbilitas aplikasi, yang jika ditekan akan berbunyi sesuai label yang diberi. Widget yang mempunyai fungsi penting bisa diberikan label dan petunjuk sehingga lebih mudah dipahami oleh pengguna yang menggunakan screen reader.

