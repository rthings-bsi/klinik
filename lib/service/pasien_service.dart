import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helpers/api_client.dart';
import '../model/pasien.dart';
import 'antrian_service.dart';
import 'user_service.dart';

const String _kLocalPasienKey = 'local_pasien_records';

class PasienService {
  final ApiClient _api = ApiClient();

  Future<List<Pasien>> listData() async {
    List<Pasien> result = [];

    try {
      final Response response = await _api.get('pasien');
      if (response.data is List) {
        final List data = response.data as List;
        result = data.map((json) => Pasien.fromJson(json)).toList();
      }
    } catch (_) {}

    final localList = await _getLocalPasien();
    for (final lp in localList) {
      final idx = result.indexWhere((item) =>
          item.id == lp.id ||
          (item.nomorRm.isNotEmpty && item.nomorRm.toLowerCase() == lp.nomorRm.toLowerCase()));
      if (idx != -1) {
        result[idx] = lp;
      } else {
        result.add(lp);
      }
    }

    // Sync registered patients from user accounts into patient records
    try {
      final users = await UserService().listData();
      for (final u in users) {
        if (u.role.toLowerCase() == 'pasien') {
          final exists = result.any((p) =>
              (u.nomorRm != null && u.nomorRm!.isNotEmpty && p.nomorRm.toLowerCase() == u.nomorRm!.toLowerCase()) ||
              (p.nama.toLowerCase().trim() == u.nama.toLowerCase().trim() &&
                  p.nomorTelepon.trim() == u.nomorTelepon.trim()));
          if (!exists && u.nama.isNotEmpty) {
            String rm = u.nomorRm ?? '';
            if (rm.isEmpty || rm == 'RM-BARU') {
              rm = _calculateNextNomorRm(result);
            }
            final newPasien = Pasien(
              id: u.id ?? DateTime.now().millisecondsSinceEpoch.toString().substring(7),
              nomorRm: rm,
              nama: u.nama.isNotEmpty ? u.nama : u.username,
              tanggalLahir: (u.createdAt != null && u.createdAt!.isNotEmpty)
                  ? u.createdAt!
                  : DateTime.now().toIso8601String().substring(0, 10),
              nomorTelepon: u.nomorTelepon,
              alamat: '-',
            );
            result.add(newPasien);
            await _saveLocalPasien(newPasien);
          }
        }
      }
    } catch (_) {}

    // Sync queue tickets into patient records
    try {
      final antrianList = await AntrianService().listData();
      for (final a in antrianList) {
        final exists = result.any((p) =>
            (a.nomorRm.isNotEmpty && a.nomorRm != 'RM-BARU' && p.nomorRm.toLowerCase() == a.nomorRm.toLowerCase()) ||
            (p.nama.toLowerCase().trim() == a.namaPasien.toLowerCase().trim() &&
                p.nomorTelepon.trim() == a.nomorTelepon.trim()));
        if (!exists && a.namaPasien.isNotEmpty) {
          String rm = a.nomorRm;
          if (rm.isEmpty || rm == 'RM-BARU') {
            rm = _calculateNextNomorRm(result);
          }
          final newPasien = Pasien(
            id: DateTime.now().millisecondsSinceEpoch.toString().substring(7),
            nomorRm: rm,
            nama: a.namaPasien,
            tanggalLahir: a.tanggal.isNotEmpty ? a.tanggal : DateTime.now().toIso8601String().substring(0, 10),
            nomorTelepon: a.nomorTelepon,
            alamat: '-',
          );
          result.add(newPasien);
          await _saveLocalPasien(newPasien);
        }
      }
    } catch (_) {}

    return result;
  }

  String _calculateNextNomorRm(List<Pasien> currentList) {
    final currentYear = DateTime.now().year.toString();
    int maxSeq = 0;
    for (final p in currentList) {
      final match = RegExp(r'RM-\d{4}-(\d+)').firstMatch(p.nomorRm.trim());
      if (match != null) {
        final num = int.tryParse(match.group(1)!) ?? 0;
        if (num > maxSeq) maxSeq = num;
      }
    }
    if (maxSeq == 0) {
      maxSeq = currentList.length;
    }
    final nextSeq = (maxSeq + 1).toString().padLeft(3, '0');
    return "RM-$currentYear-$nextSeq";
  }

  Future<String> generateNomorRm() async {
    final list = await listData();
    return _calculateNextNomorRm(list);
  }

  Future<Pasien> simpan(Pasien pasien) async {
    if (pasien.nomorRm.isEmpty || pasien.nomorRm == 'RM-BARU') {
      pasien.nomorRm = await generateNomorRm();
    }

    try {
      final Response response = await _api.post('pasien', pasien.toJson());
      if (response.data is Map) {
        final saved = Pasien.fromJson(Map<String, dynamic>.from(response.data as Map));
        await _saveLocalPasien(saved);
        return saved;
      }
    } catch (_) {}

    pasien.id ??= DateTime.now().millisecondsSinceEpoch.toString().substring(7);
    await _saveLocalPasien(pasien);
    return pasien;
  }

  Future<Pasien> ubah(Pasien pasien, String id) async {
    pasien.id = id;
    try {
      final Response response = await _api.put('pasien/$id', pasien.toJson());
      if (response.data is Map) {
        final updated = Pasien.fromJson(Map<String, dynamic>.from(response.data as Map));
        await _saveLocalPasien(updated);
        return updated;
      }
    } catch (_) {}

    await _saveLocalPasien(pasien);
    return pasien;
  }

  Future<Pasien> getById(String id) async {
    final all = await listData();
    return all.firstWhere(
      (element) => element.id == id,
      orElse: () => throw Exception('Pasien dengan ID $id tidak ditemukan'),
    );
  }

  Future<Pasien> hapus(Pasien pasien) async {
    try {
      await _api.delete('pasien/${pasien.id}');
    } catch (_) {}

    await _removeLocalPasien(pasien.id ?? '');
    return pasien;
  }

  Future<List<Pasien>> _getLocalPasien() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kLocalPasienKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final List decoded = jsonDecode(raw);
      return decoded.map((e) => Pasien.fromJson(Map<String, dynamic>.from(e as Map))).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveLocalPasien(Pasien pasien) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await _getLocalPasien();
    final index = list.indexWhere((p) =>
        (pasien.id != null && p.id == pasien.id) ||
        (pasien.nomorRm.isNotEmpty && p.nomorRm.toLowerCase() == pasien.nomorRm.toLowerCase()));
    if (index != -1) {
      list[index] = pasien;
    } else {
      list.add(pasien);
    }
    await prefs.setString(_kLocalPasienKey, jsonEncode(list.map((e) => e.toJson()).toList()));
  }

  Future<void> _removeLocalPasien(String id) async {
    if (id.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final list = await _getLocalPasien();
    list.removeWhere((p) => p.id == id);
    await prefs.setString(_kLocalPasienKey, jsonEncode(list.map((e) => e.toJson()).toList()));
  }
}
