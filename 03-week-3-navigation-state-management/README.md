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

### (lib/pages/product_page.dart):

| product_page |
| :---: |
| ![home_page](03-week3_async/screenshot/product_page.png) |

### (lib/providers/product_provider.dart):

| product_providers |
| :---: |
| ![detail_page](03-week3_async/screenshot/products_providers.png) |

### Output

| Output |
| :---: |
| ![Output](03-week3_async/screenshot/hasil_1.png) |

### Ubah build() sementara untuk melempar error:

| kode_sebelum | kode_sesudah |
| :---: | :---: |
| ![sebelum](03-week3_async/screenshot/kode_sebelum_1.png) | ![sesudah](03-week3_async/screenshot/kode_sesudah_1.png) |

| Output |
| :---: |
| ![Output](03-week3_async/screenshot/hasil_error.png) |

### Pulihkan kode

| Output |
| :---: |
| ![Output](03-week3_async/screenshot/hasil_pulih.png) |

### Refleksi
*mengapa menampilkan ulang data lama (stale data) dengan indikator refresh kadang lebih baik daripada mengosongkan layar? Kapan pola itu penting?*

Karena menampilkan data lama dengan indikator refresh lebih bagus kareana pengguna dapat melihat informasi yang tersedia selama proses pembaruan berlangsung. Pola ini penting di aplikasi kayak marketplace, berita, atau dashboard, karena mengosongkan layar saat refresh dapat membuat aplikasi kerasa lambat dan mengganggu pengalaman seorang pengguna.

## AI Challenge

| stats_provider.dart |
| :---: |
| ![kode](03-week3_async/screenshot/stats_provider.png) |

| stats_page.dart |
| :---: |
| ![kode](03-week3_async/screenshot/stats_page.png) |

| main.dart |
| :---: |
| ![kode](03-week3_async/screenshot/main_ai.png) |

| stats_provider_test.dart |
| :---: |
| ![kode](03-week3_async/screenshot/stats_provider_test.png) |

**Ada satu masalah**

Karena requirement-nya gagal secara acak 30%, unit test di atas secara teori bisa gagal 30% juga.
Itu jelek untuk automated testing.
Jadi perlu memperbaiki desain supaya testing deterministik.

**Hasil**

| hasil |
| :---: |
| ![kode](03-week3_async/screenshot/hasil_ai.png) |

**Perbaikan**

| perbaikan_kode |
| :---: |
| ![kode](03-week3_async/screenshot/perbaikan_ai.png) |

| flutter_analyze_test |
| :---: |
| ![output](03-week3_async/screenshot/analyze_test.png) |

### Verification Checklist

* *Immutable State* — ✅<br>
State dikelola menggunakan AsyncValue dan tidak dimodifikasi secara langsung dengan state.add().
* *Penggunaan ref.watch dan ref.read* — ✅<br>
ref.watch() digunakan untuk memantau state di build, sedangkan ref.read() digunakan pada tombol retry.
8 *Penanganan AsyncValue* — ✅<br>
UI menangani tiga kondisi: loading, error, dan success/data.
* *Provider Terdefinisi dengan Jelas* — ✅<br>
Menggunakan satu AsyncNotifierProvider<StatsNotifier, List<String>> dengan tipe state yang jelas.
* *Menggunakan API Riverpod Terbaru* — ✅<br>
Implementasi menggunakan AsyncNotifier dan ConsumerWidget, tanpa API Riverpod lama.
* *Pengujian dan Analisis Kode* — ✅<br>
flutter analyze sudah diperbaiki hingga tidak ada issue, dan flutter test digunakan untuk memastikan kode berjalan dengan benar.

## Refactoring dan testing

### Refactoring Challenge

* **Pisahkan widget bar ToDo**

| struktur_folder |
| :---: |
| ![code](03-week3_todo/screenshot/struktur_folder2.png) |

* **Ekstrak logika filter**

| code |
| :---: |
| ![code](03-week3_todo/screenshot/provider_filter.png) |

* **Integrasi aplikasi ToDo dengan GoRouter**

| code |
| :---: |
| ![code](03-week3_todo/screenshot/code_routing.png) |

### Testing

| output |
| :---: |
| ![output](03-week3_todo/screenshot/verifikasi.png) |

### Checklist verifikasi mandiri

* **Navigasi GoRouter bekerja: pindah halaman, back, dan akses path detail langsung.** ✅
* **ProviderScope membungkus root aplikasi; state ToDo bertahan saat berpindah halaman.** ✅
* **UI AsyncValue menangani loading, error, dan success, bukan hanya success.** ✅
* **flutter analyze tanpa issue dan semua test lulus.** ✅
* **Hasil AI diverifikasi dan didokumentasikan pada folder docs/.** ✅

