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

## Praktikum 2 — Aplikasi ToDo dengan Riverpod

## Struktur folder

| struktur |
| :---: |
| ![struktur](03-week3_todo/screenshot/struktur_folder.png) |

### Bungkus aplikasi dengan ProviderScope di lib/main.dart:

| code_main |
| :---: |
| ![main](03-week3_todo/screenshot/code_main.png) |

### Buat state dan provider (lib/providers/todo_provider.dart):

| code_todo_provider |
| :---: |
| ![todo_provider](03-week3_todo/screenshot/code_todo_provider.png) |

### Tampilkan dengan ConsumerWidget (lib/pages/todo_page.dart):

| code_todo_page_1 | code_todo_page_2 |
| :---: | :---: |
| ![todo_page1](03-week3_todo/screenshot/code_todo_page.png) | ![todo_page2](03-week3_todo/screenshot/code_todo_page1.png) |

## AsyncValue: loading, error, success

### Struktur folder:
| struktur |
| :---: |
| ![struktur](03-week3_async/screenshot/struktur_folder.png) |

### Halaman Home (lib/pages/product_page.dart):

| product_page |
| :---: |
| ![home_page](03-week3_async/screenshot/product_page.png) |

### Halaman Detail (lib/providers/product_provider.dart):

| product_providers |
| :---: |
| ![detail_page](03-week3_async/screenshot/products_providers.png) |