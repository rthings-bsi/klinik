import '../helpers/user_info.dart';
import 'user_service.dart';

class LoginService {
  Future<bool> login(String username, String password) async {
    final cleanUsername = username.trim();
    final cleanPassword = password.trim();

    // 1. Superuser admin check
    if (cleanUsername == 'admin' && cleanPassword == 'admin') {
      await UserInfo().setToken("admin_session_token");
      await UserInfo().setUserID("1");
      await UserInfo().setUsername("admin");
      await UserInfo().setRole("Admin");
      await UserInfo().setNama("Administrator");
      return true;
    }

    // 2. Check registered users in database / local cache
    try {
      final user = await UserService().authenticate(cleanUsername, cleanPassword);
      if (user != null) {
        await UserInfo().setToken("user_token_${user.id ?? 'session'}");
        await UserInfo().setUserID(user.id ?? '99');
        await UserInfo().setUsername(user.username);
        await UserInfo().setRole(user.role.isNotEmpty ? user.role : 'Pasien');
        await UserInfo().setNama(user.nama.isNotEmpty ? user.nama : user.username);
        await UserInfo().setNomorTelepon(user.nomorTelepon);
        if (user.nomorRm != null && user.nomorRm!.isNotEmpty) {
          await UserInfo().setNomorRm(user.nomorRm!);
        }
        return true;
      }
    } catch (_) {
      // Fallback
    }

    return false;
  }
}
