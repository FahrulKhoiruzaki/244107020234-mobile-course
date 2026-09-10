# Pertemuan 3

## Praktikum 1 — Aplikasi multi-page dengan GoRouter

### Struktur folder:
| struktur |
| :---: |
| ![struktur](screenshot/struktur_folder.png) |

### Definisikan router di lib/main.dart:

| main_dart |
| :---: |
| ![main_dart](screenshot/main_dart.png) |

### Halaman Home (lib/pages/home_page.dart):

| home_page |
| :---: |
| ![home_page](screenshot/home_page_code.png) |

### Halaman Detail (lib/pages/detail_page.dart):

| detail_page |
| :---: |
| ![detail_page](screenshot/detail_page_code.png) |

### Jalankan dan amati.

| home_page | detail_page |
| :---: | :---: |
| ![home](screenshot/home_page.png) | ![detail](screenshot/detail_page_5.png) |

**Penjelasan:**
Aplikasi dijalandkan dengan membuka item dari halaman Home. Waktu item dipilih, aplikasi berpindah ke halaman Detail dan menampilkan ID item yang dipilih.

Praktikum berhasil menggunakan GoRouter untuk membuat navigasi halaman. Penggunaan path parameter memungkinkan halaman Detail menerima ID item secara dinamis.
