# Week 7 — Clean Architecture

Implementasi praktikum Clean Architecture berdasarkan [Codelab Week 7](https://jti-polinema.github.io/flutter-codelab/07-minggu-7-clean-architecture/index.html#1).

## Status tahap

### Tahap 3 — Step 4: Domain dan Data per feature

**Status:** selesai pada scope Domain dan Data untuk feature `notes`.

Project target tahap ini adalah folder `07-week-7-clean-architecture/`. Baseline source dan test berasal dari project Week 5 offline-first. Refactoring presentation, provider, dan Dependency Injection sengaja belum dilakukan karena termasuk Step 5 / Tahap 4.

Dokumentasi implementasi: [Step 4 — Domain dan Data per feature](docs/step-4-domain-data.md)

## Struktur target yang ditambahkan

```text
lib/
├── core/
│   └── failures.dart
└── features/
    └── notes/
        ├── domain/
        │   ├── entities/note.dart
        │   ├── repositories/note_repository.dart
        │   └── usecases/get_notes.dart
        └── data/
            ├── models/note_model.dart
            └── repositories/note_repository_impl.dart
```

Arah dependensi yang dijaga:

```text
presentation → domain ← data
```

`domain` tidak mengimpor Flutter, Dio, SQLite, Firebase, atau package infrastruktur lain. Mapping SQLite berada di `NoteModel`, sedangkan kontrak repository berada di domain dan implementasinya berada di data.

## Verifikasi

- `dart format` pada enam file Domain/Data: **berhasil**, 0 file berubah pada pemeriksaan akhir.
- Pemeriksaan import infrastruktur pada `lib/core` dan `lib/features/notes/domain`: **berhasil**, tidak ada hasil.
- `flutter analyze`: **BLOCKED/FAIL**, karena metadata dependency tidak tersedia dan `pubspec.yaml` tidak ada di repository. Output menunjukkan URI package seperti `sqflite`, `path`, `dio`, `flutter_riverpod`, dan `shared_preferences` tidak dapat di-resolve.
- `flutter test`: belum dapat dijalankan secara valid karena alasan yang sama; tidak diklaim PASS.
- Screenshot: tidak dibuat. Tidak ada aplikasi yang dapat dijalankan tanpa metadata Flutter/dependency, sehingga tidak ada bukti visual yang boleh diklaim.

Tahap berikutnya adalah Step 5 / Tahap 4 setelah mendapat approval terpisah.

## Riwayat tahap sebelumnya

- [Tahap 1 — Konsep SOLID dan Clean Architecture](../05-week-5-local-storage-offline-first/docs/clean-architecture-concepts.md)
- [Tahap 2 — Audit layer project lama](../05-week-5-local-storage-offline-first/docs/architecture-audit.md)
