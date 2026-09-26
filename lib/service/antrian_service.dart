import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helpers/api_client.dart';
import '../model/antrian.dart';

const String _kLocalAntrianKey = 'local_antrian_records';

class AntrianService {
  final ApiClient _api = ApiClient();

  Future<List<Antrian>> listData() async {
    List<Antrian> list = [];

    try {
      final Response response = await _api.get('antrian');
      if (response.data is List) {
        list = (response.data as List)
            .map((item) => Antrian.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList();
      }
    } catch (_) {
      // Fallback
    }

    // Merge with locally stored antrian
    final localList = await _getLocalAntrian();
    for (final la in localList) {
      final idx = list.indexWhere((item) => item.id == la.id);
      if (idx != -1) {
        list[idx] = la;
      } else {
        list.add(la);
      }
    }

    return list;
  }

  Future<Antrian> getById(String id) async {
    final all = await listData();
    final item = all.firstWhere(
      (element) => element.id == id,
      orElse: () => throw Exception('Antrian dengan ID $id tidak ditemukan'),
    );
    return item;
  }

  Future<String> generateNomorAntrian(String idPoli, String tanggal) async {
    final all = await listData();
    final samePoliAndDate = all.where((a) => a.idPoli == idPoli && a.tanggal == tanggal).toList();
    final count = samePoliAndDate.length + 1;
    final prefix = _getPoliPrefix(idPoli);
    return "$prefix-${count.toString().padLeft(2, '0')}";
  }

  String _getPoliPrefix(String idPoli) {
    switch (idPoli) {
      case '1':
        return 'A'; // Poli Saraf
      case '2':
        return 'B'; // Poli Gigi
      case '3':
        return 'C'; // Poli Anak
      case '4':
        return 'D'; // Poli Umum
      default:
        return 'Q';
    }
  }

  Future<Antrian> simpan(Antrian antrian) async {
    if (antrian.nomorAntrian.isEmpty) {
      antrian.nomorAntrian = await generateNomorAntrian(antrian.idPoli, antrian.tanggal);
    }

    try {
      final Response response = await _api.post('antrian', antrian.toJson());
      if (response.data is Map) {
        final saved = Antrian.fromJson(Map<String, dynamic>.from(response.data as Map));
        await _saveLocalAntrian(saved);
        return saved;
      }
    } catch (_) {
      // Local fallback
    }

    antrian.id ??= DateTime.now().millisecondsSinceEpoch.toString().substring(7);
    await _saveLocalAntrian(antrian);
    return antrian;
  }

  Future<Antrian> ubahStatus(String id, String newStatus) async {
    final antrian = await getById(id);
    antrian.status = newStatus;
    return ubah(antrian, id);
  }

  Future<Antrian> ubah(Antrian antrian, String id) async {
    antrian.id = id;
    try {
      final Response response = await _api.put('antrian/$id', antrian.toJson());
      if (response.data is Map) {
        final updated = Antrian.fromJson(Map<String, dynamic>.from(response.data as Map));
        await _saveLocalAntrian(updated);
        return updated;
      }
    } catch (_) {
      // Local fallback
    }

    await _saveLocalAntrian(antrian);
    return antrian;
  }

  Future<bool> hapus(Antrian antrian) async {
    final id = antrian.id ?? '';
    try {
      await _api.delete('antrian/$id');
    } catch (_) {
      // Local fallback
    }
    await _removeLocalAntrian(id);
    return true;
  }

  Future<List<Antrian>> _getLocalAntrian() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kLocalAntrianKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final List decoded = jsonDecode(raw);
      return decoded.map((e) => Antrian.fromJson(Map<String, dynamic>.from(e as Map))).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveLocalAntrian(Antrian antrian) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await _getLocalAntrian();
    final index = list.indexWhere((a) => a.id == antrian.id);
    if (index != -1) {
      list[index] = antrian;
    } else {
      list.add(antrian);
    }
    await prefs.setString(_kLocalAntrianKey, jsonEncode(list.map((e) => e.toJson()).toList()));
  }

  Future<void> _removeLocalAntrian(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await _getLocalAntrian();
    list.removeWhere((a) => a.id == id);
    await prefs.setString(_kLocalAntrianKey, jsonEncode(list.map((e) => e.toJson()).toList()));
  }
}
