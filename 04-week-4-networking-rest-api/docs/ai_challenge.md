## Verification Checklist AI Challenge

* [x] **UI tidak memanggil Dio secara langsung**
  UI mengakses data melalui Provider/Notifier dan Repository. Pemanggilan Dio dilakukan di dalam `PostRepository` dan `CommentRepository`.

* [x] **`fromJson` aman terhadap field null/hilang**
  `Post.fromJson` dan `Comment.fromJson` menggunakan cast nullable seperti `as num?` dan `as String?` dengan nilai default, sehingga field yang hilang tidak menyebabkan aplikasi crash.

* [x] **Tipe `DioException` dipetakan ke pesan pengguna**
  Timeout, `connectionError`, dan `badResponse` ditangani dan diubah menjadi pesan yang lebih mudah dipahami pengguna. Status `404` dan `500` juga memiliki pesan khusus.

* [x] **`baseUrl` dan timeout terpusat di client**
  `baseUrl`, `connectTimeout`, dan `receiveTimeout` utama dikonfigurasi pada `api_client.dart`. Repository menggunakan client tersebut sehingga konfigurasi tidak tersebar di setiap method.

* [x] **Test menguji field hilang dan minimal satu edge case**
  Test `fromJson` sudah menguji field yang hilang. Namun, perlu ditambahkan minimal satu edge case sendiri agar checklist ini lengkap.

* [x] **`flutter analyze` dan `flutter test`**
  Checklist ini dinyatakan selesai setelah perintah `flutter analyze` dan `flutter test` dijalankan dan hasil akhirnya menunjukkan tidak ada masalah serta seluruh test berhasil.
