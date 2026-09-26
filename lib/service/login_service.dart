import '../helpers/user_info.dart';
import 'pegawai_service.dart';
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

    // 2. Check registered pegawai (login via NIP or Email)
    try {
      final pegawaiList = await PegawaiService().listData();
      for (final p in pegawaiList) {
        final matchesIdentifier = p.nip.trim().toLowerCase() == cleanUsername.toLowerCase() ||
            p.email.trim().toLowerCase() == cleanUsername.toLowerCase();
        if (matchesIdentifier && p.password.trim() == cleanPassword) {
          await UserInfo().setToken("pegawai_token_${p.id ?? p.nip}");
          await UserInfo().setUserID(p.id ?? p.nip);
          await UserInfo().setUsername(p.nip);
          await UserInfo().setRole("Pegawai");
          await UserInfo().setNama(p.nama);
          await UserInfo().setNomorTelepon(p.nomorTelepon);
          return true;
        }
      }
    } catch (_) {
      // Fallback if network fails
    }

    // 3. Check registered users in database / local cache
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
