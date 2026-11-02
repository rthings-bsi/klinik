# Klinik App

Aplikasi CRUD klinik berbasis Flutter yang mengikuti Modul Mobile Programming II
(Pertemuan 2 - 13): Poli, Pegawai, dan Pasien.

## Fitur

- Login admin (`admin` / `admin`) dengan token tersimpan di `shared_preferences`.
- Beranda dengan sidebar/drawer.
- CRUD Poli, Pegawai, dan Pasien:
  - daftar data dari REST API,
  - tambah data,
  - detail data,
  - ubah data,
  - hapus data dengan dialog konfirmasi.

## Struktur

```
lib/
  helpers/   api_client.dart, user_info.dart
  model/     poli.dart, pegawai.dart, pasien.dart
  service/   login_service.dart, poli_service.dart, pegawai_service.dart, pasien_service.dart
  ui/        login, beranda, poli_*, pegawai_*, pasien_*
  widget/    sidebar.dart
  main.dart
```

## Menjalankan

```bash
flutter pub get
flutter run
```

## Catatan API

`lib/helpers/api_client.dart` memakai base URL MockAPI yang tertulis pada modul.
Project MockAPI tersebut sudah tidak aktif (HTTP 404), sehingga `ApiClient`
otomatis memakai penyimpanan data lokal di memori dengan bentuk response yang
sama. Jika memiliki project MockAPI sendiri, cukup ganti `baseUrl` dan hapus
fallback lokal bila tidak diperlukan.

Data lokal sudah diisi contoh Poli, Pegawai, dan Pasien. Perubahan (tambah,
ubah, hapus) bertahan selama aplikasi berjalan.
