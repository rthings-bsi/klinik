import 'package:flutter/material.dart';

class PoliMeta {
  final IconData icon;
  final Color primaryColor;
  final Color backgroundColor;
  final String category;
  final String location;

  const PoliMeta({
    required this.icon,
    required this.primaryColor,
    required this.backgroundColor,
    required this.category,
    required this.location,
  });
}

class PoliHelper {
  static PoliMeta getMeta(String rawNama) {
    final name = rawNama.toLowerCase();

    if (name.contains('saraf') || name.contains('neuro')) {
      return const PoliMeta(
        icon: Icons.psychology_rounded,
        primaryColor: Color(0xFF4F46E5), // Indigo 600
        backgroundColor: Color(0xFFEEF2FF), // Indigo 50
        category: "Spesialis Saraf",
        location: "Gedung B • Lt. 2",
      );
    } else if (name.contains('gigi') || name.contains('dental')) {
      return const PoliMeta(
        icon: Icons.health_and_safety_rounded,
        primaryColor: Color(0xFF0284C7), // Sky 600
        backgroundColor: Color(0xFFF0F9FF), // Sky 50
        category: "Kesehatan Gigi & Mulut",
        location: "Gedung A • Lt. 1",
      );
    } else if (name.contains('ibu') ||
        name.contains('kia') ||
        name.contains('kandungan') ||
        name.contains('obgyn')) {
      return const PoliMeta(
        icon: Icons.family_restroom_rounded,
        primaryColor: Color(0xFFE11D48), // Rose 600
        backgroundColor: Color(0xFFFFF1F2), // Rose 50
        category: "Kesehatan Ibu & Anak (KIA)",
        location: "Gedung B • Lt. 1",
      );
    } else if (name.contains('anak') || name.contains('pediatri')) {
      return const PoliMeta(
        icon: Icons.child_care_rounded,
        primaryColor: Color(0xFFD97706), // Amber 600
        backgroundColor: Color(0xFFFFFBEB), // Amber 50
        category: "Spesialis Anak (Pediatri)",
        location: "Gedung A • Lt. 2",
      );
    } else if (name.contains('dalam') || name.contains('interna')) {
      return const PoliMeta(
        icon: Icons.monitor_heart_rounded,
        primaryColor: Color(0xFF059669), // Emerald 600
        backgroundColor: Color(0xFFECFDF5), // Emerald 50
        category: "Spesialis Penyakit Dalam",
        location: "Gedung A • Lt. 2",
      );
    } else if (name.contains('mata') || name.contains('optik')) {
      return const PoliMeta(
        icon: Icons.visibility_rounded,
        primaryColor: Color(0xFF7C3AED), // Violet 600
        backgroundColor: Color(0xFFF5F3FF), // Violet 50
        category: "Spesialis Mata",
        location: "Gedung B • Lt. 2",
      );
    } else if (name.contains('tht') ||
        name.contains('telinga') ||
        name.contains('hidung')) {
      return const PoliMeta(
        icon: Icons.hearing_rounded,
        primaryColor: Color(0xFFEA580C), // Orange 600
        backgroundColor: Color(0xFFFFF7ED), // Orange 50
        category: "Spesialis THT",
        location: "Gedung B • Lt. 1",
      );
    } else if (name.contains('jantung') || name.contains('kardio')) {
      return const PoliMeta(
        icon: Icons.favorite_rounded,
        primaryColor: Color(0xFFDC2626), // Red 600
        backgroundColor: Color(0xFFFEF2F2), // Red 50
        category: "Kardiologi & Jantung",
        location: "Gedung C • Lt. 1",
      );
    } else if (name.contains('kulit') ||
        name.contains('kelamin') ||
        name.contains('estetika')) {
      return const PoliMeta(
        icon: Icons.spa_rounded,
        primaryColor: Color(0xFFDB2777), // Pink 600
        backgroundColor: Color(0xFFFDF2F8), // Pink 50
        category: "Dermatologi & Estetika",
        location: "Gedung A • Lt. 2",
      );
    } else if (name.contains('bedah')) {
      return const PoliMeta(
        icon: Icons.healing_rounded,
        primaryColor: Color(0xFF2563EB), // Blue 600
        backgroundColor: Color(0xFFEFF6FF), // Blue 50
        category: "Spesialis Bedah",
        location: "Gedung C • Lt. 2",
      );
    } else if (name.contains('dio') ||
        name.contains('test') ||
        name.contains('lab')) {
      return const PoliMeta(
        icon: Icons.biotech_rounded,
        primaryColor: Color(0xFF6366F1), // Indigo 500
        backgroundColor: Color(0xFFF1F5F9), // Slate 100
        category: "Laboratorium Klinis",
        location: "Lab Terpadu • Lt. 1",
      );
    } else {
      return const PoliMeta(
        icon: Icons.medical_services_rounded,
        primaryColor: Color(0xFF6750A4), // MD3 Violet Primary
        backgroundColor: Color(0xFFF3EDF7), // MD3 Surface Container
        category: "Pelayanan Medis Umum",
        location: "Gedung A • Lt. 1",
      );
    }
  }
}
