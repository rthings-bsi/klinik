# DESIGN.md

Arah visual Klinik APP. Ditulis dari arahan pemilik produk: lanjutkan identitas biru
yang sudah dipakai aplikasi.

## Identitas

Klinik APP adalah konsol kerja petugas klinik, bukan halaman pemasaran. Isinya data
operasional (pasien, poli, pegawai). Karena dipakai saat bekerja, warna dipakai untuk
menandai status dan tujuan navigasi, bukan untuk menarik perhatian.

## Dial

Dial: ENERGY 2 / RHYTHM 2 / MOTION 2

- ENERGY 2: tiap layar punya satu elemen yang jelas paling penting, sisanya menahan diri.
- RHYTHM 2: komposisi konsisten, dengan satu perubahan bentuk (kartu fokus) sebagai penanda.
- MOTION 2: transisi halus saat status berubah, tanpa animasi berulang.

## Palet

Bidang kerja netral (putih/abu bawaan tema) ditambah satu warna identitas.

| Peran | Nilai | Alasan |
|---|---|---|
| Biru klinik (primary) | `#1565C0` | Biru yang sudah jadi warna aplikasi; kontras 5.75:1 dengan teks putih, lolos WCAG AA untuk teks normal |
| Merah aksi hapus | `#C62828` | Menandai satu-satunya aksi perusak data; kontras 5.62:1 dengan teks putih |
| Netral | `surface` / `outlineVariant` bawaan tema | Bidang kerja dan garis pemisah, bukan warna identitas |

Aturan pakai: biru tidak disebar ke mana-mana. Ia muncul di chrome (AppBar), satu kartu
fokus per layar, ikon navigasi, dan tautan aksi. Sisanya netral. Tidak ada gradien: tidak
ada kebutuhan hierarki yang menuntutnya.

## Tipografi

Font bawaan aplikasi (Roboto lewat tema Material). Alasan: menjaga konsistensi dengan
halaman-halaman yang sudah ada dan tidak menambah dependency. Hierarki dibentuk lewat
ukuran dan berat, bukan lewat ganti font.

- Angka ringkasan: 44 px, berat 600. Satu-satunya ukuran besar di layar.
- Judul bagian: 13 px, berat 600, warna `onSurfaceVariant`, huruf kecil semua (tanpa
  label kapital berjarak lebar).
- Teks isi: 14-16 px bawaan tema.

## Bentuk dan Kedalaman

- Radius: 14 px untuk kartu fokus, 12 px untuk baris data. Tidak ada elemen pill.
- Shadow: tidak ada. Pemisah memakai garis tipis; kartu fokus tampak menonjol lewat warna
  isian, bukan bayangan.

## Motif identitas

Dua gestur yang berulang di seluruh konsol:

1. Hitung dulu: setiap entri modul menampilkan jumlah datanya di sisi kanan, jadi angka
   adalah hal pertama yang terbaca.
2. Inisial nama pasien di kotak biru muda sebagai penanda baris, sehingga nama panjang
   dan nomor RM bisa dipindai cepat.

## Gerak

`AnimatedSwitcher` 200 ms ketika status layar berubah (memuat ke data, galat ke data).
Alasan: mencegah pergantian keras saat data selesai dimuat. Tidak ada animasi berulang,
dan tidak ada gerak yang berjalan tanpa aksi pengguna.
