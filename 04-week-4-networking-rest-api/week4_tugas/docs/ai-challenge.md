# Dokumentasi AI Challenge

## Prompt

Buatkan repository layer Flutter untuk endpoint GET `/comments?postId={id}` dari JSONPlaceholder menggunakan Dio dan flutter_riverpod.

Persyaratan:
- Model `Comment` dengan `fromJson` aman null (`postId`, `id`, `name`, `email`, `body`).
- `CommentRepository` dengan method `fetchComments(postId)`.
- Timeout 10 detik.
- Provider dengan penanganan error dan pesan yang ramah pengguna untuk timeout, connection error, 404, dan 500.
- Unit test `fromJson` untuk field yang hilang.
- Jelaskan setiap bagian kode.

## Ringkasan hasil implementasi

- `Comment` memetakan field numerik dengan `as num?` dan `toInt()`, serta teks dengan `as String?`.
- Field yang tidak tersedia atau `null` menggunakan nilai default.
- `CommentRepository` mengambil komentar melalui Dio dengan query `postId`.
- `CommentListNotifier` mengelola state loading, data, dan error.
- `friendlyCommentErrorMessage` mengubah beberapa kegagalan jaringan menjadi pesan yang lebih mudah dipahami.

## Verifikasi dan perbaikan

- Ditambahkan test ketika field hilang.
- Ditambahkan edge case ketika semua field bernilai `null`.
- Import test menggunakan `package:week4_api/...` agar sesuai dengan struktur package.
- `friendlyErrorMessage` untuk post dipisahkan ke `lib/data/network_errors.dart` saat refactoring.

## Alasan teknis

Pemisahan repository, provider, dan UI menjaga satu tanggung jawab pada setiap lapisan. Nilai default pada `fromJson` mengurangi risiko gagal parsing karena field hilang atau `null`. Repository palsu pada unit test memungkinkan pengujian provider tanpa request HTTP sungguhan.

