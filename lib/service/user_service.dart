import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helpers/api_client.dart';
import '../model/user.dart';

const String _kLocalUsersKey = 'local_registered_users';

class UserService {
  final ApiClient _api = ApiClient();

  Future<List<User>> listData() async {
    List<User> users = [];

    try {
      final Response response = await _api.get('users');
      if (response.data is List) {
        users = (response.data as List)
            .map((item) => User.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList();
      }
    } catch (_) {
      // Fallback
    }

    // Merge with locally stored users from SharedPreferences
    final localUsers = await _getLocalUsers();
    for (final lu in localUsers) {
      if (!users.any((u) => u.username.toLowerCase() == lu.username.toLowerCase())) {
        users.add(lu);
      }
    }

    return users;
  }

  Future<User> register(User user) async {
    // Check if username is already taken
    final existingUsers = await listData();
    final isTaken = existingUsers.any(
      (u) => u.username.toLowerCase().trim() == user.username.toLowerCase().trim(),
    );

    if (isTaken || user.username.toLowerCase().trim() == 'admin') {
      throw Exception('Username "${user.username}" sudah digunakan');
    }

    user.createdAt = DateTime.now().toIso8601String().substring(0, 10);

    try {
      final Response response = await _api.post('users', user.toJson());
      if (response.data is Map) {
        final saved = User.fromJson(Map<String, dynamic>.from(response.data as Map));
        await _saveLocalUser(saved);
        return saved;
      }
    } catch (_) {
      // Fallback: save locally
    }

    user.id ??= DateTime.now().millisecondsSinceEpoch.toString().substring(7);
    await _saveLocalUser(user);
    return user;
  }

  Future<void> updateUser(User user) async {
    await _saveLocalUser(user);
    try {
      if (user.id != null) {
        await _api.put('users/${user.id}', user.toJson());
      }
    } catch (_) {}
  }

  Future<User?> authenticate(String username, String password) async {
    final allUsers = await listData();
    for (final u in allUsers) {
      if (u.username.trim() == username.trim() && u.password.trim() == password.trim()) {
        return u;
      }
    }
    return null;
  }

  Future<List<User>> _getLocalUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kLocalUsersKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final List decoded = jsonDecode(raw);
      return decoded.map((e) => User.fromJson(Map<String, dynamic>.from(e as Map))).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveLocalUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await _getLocalUsers();
    final index = list.indexWhere((u) => u.username.toLowerCase() == user.username.toLowerCase());
    if (index != -1) {
      list[index] = user;
    } else {
      list.add(user);
    }
    await prefs.setString(_kLocalUsersKey, jsonEncode(list.map((e) => e.toJson()).toList()));
  }
}
