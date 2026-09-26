import 'package:shared_preferences/shared_preferences.dart';

const String kToken = "token";
const String kUserId = "userID";
const String kUsername = "username";
const String kRole = "role";
const String kNama = "nama";
const String kNomorTelepon = "nomorTelepon";
const String kNomorRm = "nomorRm";

class UserInfo {
  Future<bool> setToken(String value) async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.setString(kToken, value);
  }

  Future<String?> getToken() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString(kToken);
  }

  Future<bool> setUserID(String value) async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.setString(kUserId, value);
  }

  Future<String?> getUserID() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString(kUserId);
  }

  Future<bool> setUsername(String value) async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.setString(kUsername, value);
  }

  Future<String?> getUsername() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString(kUsername);
  }

  Future<bool> setRole(String value) async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.setString(kRole, value);
  }

  Future<String> getRole() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    final role = pref.getString(kRole);
    if (role != null && role.isNotEmpty) {
      return role;
    }
    final username = pref.getString(kUsername);
    if (username != null && username.toLowerCase() == "admin") {
      return "Admin";
    }
    return "Pasien";
  }

  Future<bool> setNama(String value) async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.setString(kNama, value);
  }

  Future<String?> getNama() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString(kNama);
  }

  Future<bool> setNomorTelepon(String value) async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.setString(kNomorTelepon, value);
  }

  Future<String?> getNomorTelepon() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString(kNomorTelepon);
  }

  Future<bool> setNomorRm(String value) async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.setString(kNomorRm, value);
  }

  Future<String?> getNomorRm() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString(kNomorRm);
  }

  Future<bool> isAdmin() async {
    final role = await getRole();
    final username = await getUsername();
    return role.toLowerCase() == "admin" ||
        (username != null && username.toLowerCase() == "admin");
  }

  Future<bool> isPasien() async {
    return !(await isAdmin());
  }

  Future<void> logout() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.clear();
  }
}
