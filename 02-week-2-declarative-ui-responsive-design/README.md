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