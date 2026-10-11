# Week 4 - Networking & REST API

Aplikasi Flutter yang menampilkan daftar data dari REST API (JSONPlaceholder `/posts`) melalui repository + Riverpod, dikerjakan sesuai codelab "#04 | Networking & REST API".

## Fitur utama

- Model `Post` dengan `fromJson` aman null.
- Dio terpusat (base URL, timeout 10 detik, header, `LogInterceptor`) di `lib/data/api_client.dart`.
- `PostRepository`: `fetchPosts`, `fetchPostsPage` (`_page` dan `_limit`), `fetchPost`.
- `PostListPage`: empat state (loading, error + tombol "Coba lagi", empty, success), refresh.
- `PagedPostPage`: infinite scroll 10 item per halaman, guard request ganda, indikator akhir data.
- Halaman detail `/post/:id` dengan GoRouter (data dari list yang sudah dimuat, atau via repository bila dibuka langsung).
- AI Challenge: `Comment`, `CommentRepository`, `commentListProvider` (lihat `docs/ai-challenge.md`).

## Uji tiga skenario error

1. Jalankan aplikasi dengan internet normal, amati loading lalu daftar 100 posts.

| uji_internet_normal | uji_internet_normal |
|:---:|:---:|
| <img src="screenshot/internet_normal1.png" width="250"> | <img src="screenshot/internet_normal2.png" width="250"> |

2. Matikan internet (mode pesawat), tekan refresh, amati pesan ramah + tombol "Coba lagi". Nyalakan kembali internet, tekan Coba lagi.

| internet_mati | internet_nyala |
|:---:|:---:|
| <img src="screenshot/uji_mode_pesawat.png" width="250"> | <img src="screenshot/nyalakan_lagi.png" width="250"> |

3. Sementara ubah baseUrl menjadi URL salah, amati pesan error koneksi. Kembalikan setelah uji.

| url_salah | hasil |
|:---:|:---:|
| <img src="screenshot/url_salah_.png" width="250"> | <img src="screenshot/nyalakan_lagi.png" width="250"> |

## AI Challenge

| test_hasil_AI |
|:---:|
| <img src="screenshot/test_hasil_ai.png" width="250"> |

| kesalahan | perbaikan |
|:---:|:---:|
| <img src="screenshot/kesalahan_ai.png" width="250"> | <img src="screenshot/perbaikan.png" width="250"> |

| test_setelah_perbaikan |
|:---:|
| <img src="screenshot/test_perbaikan.png" width="250"> |

| menambahkan_edge_case |
|:---:|
| <img src="screenshot/test_perbaikan.png" width="250"> |

## Refactoring dan Testing

| flutter_analyze_test |
|:---:|
| <img src="screenshot/analyze_test_refac.png" width="250"> |

| hasil_1 | hasil_2 |
|:---:|:---:|
| <img src="screenshot/refac_test_1.png" width="250"> | <img src="screenshot/refac_test_2.png" width="250"> |

| hasil_detail_1 | hasil_detail_2 |
|:---:|:---:|
| <img src="screenshot/refac_test_detail_1.png" width="250"> | <img src="screenshot/refac_test_detail_2.png" width="250"> |

### Checklist Verifikasi Mandiri

* [x] **UI menggunakan Repository dan Provider.** Pengambilan data post dilakukan melalui `PostRepository` dan `postListProvider`, bukan dengan memanggil Dio langsung dari UI.

* [x] **Empat state tampilan.** Loading, error dengan tombol *Coba lagi*, empty, dan success sudah diimplementasikan. Perilaku setiap state perlu dipastikan melalui pengujian aplikasi.

* [x] **Pagination.** Halaman `PagedPostPage` menggunakan `pagedPostsProvider` untuk memuat data bertahap. Perlu diuji secara langsung untuk memastikan data bertambah saat scroll, tidak ada request ganda, dan indikator akhir data tampil.

* [x] **Pemeriksaan kode dan unit test.** Hasil `flutter analyze` menunjukkan `No issues found!` dan hasil `flutter test` menunjukkan `All tests passed!` pada pengujian yang telah dijalankan.

* [x] **Dokumentasi AI.** Hasil penggunaan AI, prompt, kode yang diverifikasi, perbaikan, dan alasan perbaikan didokumentasikan di folder `docs/`.


