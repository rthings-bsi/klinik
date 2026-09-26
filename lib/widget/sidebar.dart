import 'package:flutter/material.dart';
import '../helpers/user_info.dart';
import '../ui/beranda.dart';
import '../ui/login.dart';
import '../ui/poli_page.dart';
import '../ui/pegawai_page.dart';
import '../ui/pasien_page.dart';
import '../ui/antrian_page.dart';
import 'animated_pressable.dart';
import 'smooth_page_route.dart';

class Sidebar extends StatelessWidget {
  final String activeMenu;

  const Sidebar({super.key, this.activeMenu = ""});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFFF2F2F7),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 52, 20, 22),
            decoration: const BoxDecoration(
              color: Color(0xFF0F766E),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(13),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(13),
                        child: Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Klinik App',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.4,
                          ),
                        ),
                        Text(
                          'Sistem Manajemen Layanan',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 12,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 16),
                FutureBuilder<Map<String, String>>(
                  future: () async {
                    final role = await UserInfo().getRole();
                    final username = await UserInfo().getUsername() ?? "User";
                    final nama = await UserInfo().getNama();
                    return {
                      'role': role,
                      'username': username,
                      'displayName': (nama != null && nama.isNotEmpty) ? nama : username,
                    };
                  }(),
                  builder: (context, snapshot) {
                    final data = snapshot.data ?? {'role': 'Pasien', 'username': 'User', 'displayName': 'User'};
                    final role = data['role'] ?? 'Pasien';
                    final displayName = data['displayName'] ?? 'User';
                    final isAdmin = role.toLowerCase() == 'admin';

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: isAdmin
                                ? const Color(0xFFFF9500).withValues(alpha: 0.25)
                                : Colors.black.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isAdmin
                                  ? const Color(0xFFFF9500).withValues(alpha: 0.5)
                                  : Colors.white.withValues(alpha: 0.2),
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isAdmin ? Icons.admin_panel_settings_rounded : Icons.verified_user_rounded,
                                color: isAdmin ? const Color(0xFFFFCC00) : const Color(0xFF34C759),
                                size: 13,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "Role: ${isAdmin ? 'Administrator' : 'Pasien'}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<bool>(
              future: UserInfo().isAdmin(),
              builder: (context, snapshot) {
                final isAdmin = snapshot.data ?? true;

                return ListView(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                  children: [
                    _navItem(
                      context: context,
                      title: "Beranda",
                      icon: Icons.home_rounded,
                      iconBgColor: const Color(0xFF0F766E),
                      isActive: activeMenu == "beranda",
                      onTap: () {
                        Navigator.pop(context);
                        if (activeMenu != "beranda") {
                          Navigator.pushReplacement(
                            context,
                            SmoothPageRoute(page: const Beranda()),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 4),
                    _navItem(
                      context: context,
                      title: isAdmin ? "Antrian Berobat" : "Antrian Saya",
                      icon: Icons.confirmation_number_rounded,
                      iconBgColor: const Color(0xFFFF9500),
                      isActive: activeMenu == "antrian",
                      onTap: () {
                        Navigator.pop(context);
                        if (activeMenu != "antrian") {
                          Navigator.push(
                            context,
                            SmoothPageRoute(page: const AntrianPage()),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 4),
                    _navItem(
                      context: context,
                      title: isAdmin ? "Data Poli" : "Info Poliklinik",
                      icon: Icons.meeting_room_rounded,
                      iconBgColor: const Color(0xFF0F766E),
                      isActive: activeMenu == "poli",
                      onTap: () {
                        Navigator.pop(context);
                        if (activeMenu != "poli") {
                          Navigator.push(
                            context,
                            SmoothPageRoute(page: const PoliPage()),
                          );
                        }
                      },
                    ),
                    if (isAdmin) ...[
                      const SizedBox(height: 4),
                      _navItem(
                        context: context,
                        title: "Data Pegawai",
                        icon: Icons.badge_rounded,
                        iconBgColor: const Color(0xFF007AFF),
                        isActive: activeMenu == "pegawai",
                        onTap: () {
                          Navigator.pop(context);
                          if (activeMenu != "pegawai") {
                            Navigator.push(
                              context,
                              SmoothPageRoute(page: const PegawaiPage()),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 4),
                      _navItem(
                        context: context,
                        title: "Data Pasien",
                        icon: Icons.personal_injury_rounded,
                        iconBgColor: const Color(0xFF34C759),
                        isActive: activeMenu == "pasien",
                        onTap: () {
                          Navigator.pop(context);
                          if (activeMenu != "pasien") {
                            Navigator.push(
                              context,
                              SmoothPageRoute(page: const PasienPage()),
                            );
                          }
                        },
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE5E5EA)),
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: AnimatedPressable(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (dialogCtx) => AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    title: const Text(
                      "Konfirmasi Keluar",
                      style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: -0.4),
                    ),
                    content: const Text(
                      "Apakah Anda yakin ingin keluar dari akun ini?",
                      style: TextStyle(color: Color(0xFF8E8E93), fontSize: 14),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogCtx),
                        child: const Text(
                          "Batal",
                          style: TextStyle(color: Color(0xFF8E8E93), fontWeight: FontWeight.w600),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF3B30),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          minimumSize: const Size(90, 40),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () async {
                          await UserInfo().logout();
                          if (context.mounted) {
                            Navigator.pushAndRemoveUntil(
                              context,
                              SmoothPageRoute(page: const Login()),
                              (Route<dynamic> route) => false,
                            );
                          }
                        },
                        child: const Text("Keluar"),
                      ),
                    ],
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFE5E5EA), width: 0.8),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.logout_rounded, color: Color(0xFFFF3B30), size: 20),
                    SizedBox(width: 12),
                    Text(
                      "Keluar Akun",
                      style: TextStyle(
                        color: Color(0xFFFF3B30),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _navItem({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color iconBgColor,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return AnimatedPressable(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isActive
              ? Border.all(color: const Color(0xFFE5E5EA), width: 0.8)
              : null,
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: isActive ? const Color(0xFF1C1C1E) : const Color(0xFF3A3A3C),
                  fontSize: 14.5,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            if (isActive)
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFFC7C7CC),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
