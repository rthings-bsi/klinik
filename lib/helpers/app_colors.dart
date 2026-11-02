import 'package:flutter/material.dart';

/// Warna identitas aplikasi. Hanya dipakai di luar tema Material, misalnya
/// tombol hapus yang sengaja diberi warna sendiri. Lihat DESIGN.md.
class AppColors {
  /// Biru klinik, warna utama aplikasi. Kontras 5.75:1 dengan teks putih,
  /// lolos WCAG AA untuk teks normal.
  static const Color biru = Color(0xFF1565C0);

  /// Merah untuk aksi yang menghapus data. Kontras 5.62:1 dengan teks putih.
  static const Color merahHapus = Color(0xFFC62828);
}
