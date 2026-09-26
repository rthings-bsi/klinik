import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../helpers/user_info.dart';
import '../widget/animated_pressable.dart';
import '../widget/smooth_page_route.dart';
import '../widget/staggered_entrance.dart';
import 'login.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  String _displayName = "Pengguna";
  String _username = "user";
  String _role = "Pasien";
  String _nomorRm = "-";
  String _nomorTelepon = "-";
  bool _isAdmin = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    final role = await UserInfo().getRole();
    final isAdmin = await UserInfo().isAdmin();
    final username = await UserInfo().getUsername() ?? "user";
    final nama = await UserInfo().getNama();
    final rm = await UserInfo().getNomorRm();
    final phone = await UserInfo().getNomorTelepon();

    if (mounted) {
      setState(() {
        _role = role;
        _isAdmin = isAdmin;
        _username = username;
        _displayName = (nama != null && nama.isNotEmpty) ? nama : username;
        _nomorRm = (rm != null && rm.isNotEmpty) ? rm : "-";
        _nomorTelepon = (phone != null && phone.isNotEmpty) ? phone : "-";
        _isLoading = false;
      });
    }
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          "Konfirmasi Keluar",
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: -0.4),
        ),
        content: const Text(
          "Apakah Anda yakin ingin mengakhiri sesi dan keluar dari akun ini?",
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            onPressed: () async {
              Navigator.pop(dialogCtx);
              await UserInfo().logout();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  SmoothPageRoute(page: const Login()),
                  (route) => false,
                );
              }
            },
            child: const Text(
              "Keluar",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        title: const Text("Akun & Profil"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: "Segarkan",
            onPressed: _loadProfile,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF0F766E)),
            )
          : RefreshIndicator(
              color: const Color(0xFF0F766E),
              onRefresh: _loadProfile,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Avatar & Hero Card
                    StaggeredEntrance(
                      index: 0,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFE5E5EA), width: 0.8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
                                ),
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF0F766E).withValues(alpha: 0.25),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                _displayName.isNotEmpty
                                    ? _displayName[0].toUpperCase()
                                    : "U",
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _displayName,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1C1C1E),
                                      letterSpacing: -0.4,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "@$_username",
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF8E8E93),
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _isAdmin
                                          ? const Color(0xFFFF9500).withValues(alpha: 0.12)
                                          : const Color(0xFF0F766E).withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          _isAdmin
                                              ? Icons.admin_panel_settings_rounded
                                              : Icons.verified_user_rounded,
                                          size: 13,
                                          color: _isAdmin
                                              ? const Color(0xFFFF9500)
                                              : const Color(0xFF0F766E),
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          _isAdmin ? "Administrator Klinik" : "Pasien Terdaftar",
                                          style: TextStyle(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w600,
                                            color: _isAdmin
                                                ? const Color(0xFFFF9500)
                                                : const Color(0xFF0F766E),
                                            letterSpacing: -0.2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Section: Data Personal
                    const Padding(
                      padding: EdgeInsets.only(left: 4, bottom: 8),
                      child: Text(
                        "DATA PERSONAL & MEDIS",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF8E8E93),
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),

                    StaggeredEntrance(
                      index: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE5E5EA), width: 0.8),
                        ),
                        child: Column(
                          children: [
                            _infoTile(
                              icon: Icons.medical_information_rounded,
                              iconColor: const Color(0xFF0F766E),
                              label: "Nomor Rekam Medis (RM)",
                              value: _nomorRm,
                              canCopy: _nomorRm != "-",
                            ),
                            const Divider(height: 1, indent: 52, color: Color(0xFFE5E5EA)),
                            _infoTile(
                              icon: Icons.phone_rounded,
                              iconColor: const Color(0xFF34C759),
                              label: "Nomor Telepon / WA",
                              value: _nomorTelepon,
                              canCopy: _nomorTelepon != "-",
                            ),
                            const Divider(height: 1, indent: 52, color: Color(0xFFE5E5EA)),
                            _infoTile(
                              icon: Icons.shield_rounded,
                              iconColor: const Color(0xFF007AFF),
                              label: "Tingkat Hak Akses",
                              value: _role,
                              canCopy: false,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Section: Layanan & Informasi Klinik
                    const Padding(
                      padding: EdgeInsets.only(left: 4, bottom: 8),
                      child: Text(
                        "INFORMASI KLINIK",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF8E8E93),
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),

                    StaggeredEntrance(
                      index: 2,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE5E5EA), width: 0.8),
                        ),
                        child: Column(
                          children: [
                            _infoTile(
                              icon: Icons.access_time_rounded,
                              iconColor: const Color(0xFFFF9500),
                              label: "Jam Operasional",
                              value: "Senin - Sabtu: 08:00 - 20:00 WIB",
                              canCopy: false,
                            ),
                            const Divider(height: 1, indent: 52, color: Color(0xFFE5E5EA)),
                            _infoTile(
                              icon: Icons.location_on_rounded,
                              iconColor: const Color(0xFFFF3B30),
                              label: "Lokasi Layanan",
                              value: "Gedung Rawat Jalan Terpadu Lt. 1 & 2",
                              canCopy: false,
                            ),
                            const Divider(height: 1, indent: 52, color: Color(0xFFE5E5EA)),
                            _infoTile(
                              icon: Icons.emergency_rounded,
                              iconColor: const Color(0xFFFF2D55),
                              label: "Hotline Darurat",
                              value: "021-555-0199 / 119",
                              canCopy: true,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Logout Button
                    StaggeredEntrance(
                      index: 3,
                      child: AnimatedPressable(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => _confirmLogout(context),
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF3B30).withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: const Color(0xFFFF3B30).withValues(alpha: 0.25),
                              width: 0.8,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.logout_rounded, color: Color(0xFFFF3B30), size: 20),
                              SizedBox(width: 8),
                              Text(
                                "Keluar dari Akun",
                                style: TextStyle(
                                  color: Color(0xFFFF3B30),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _infoTile({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required bool canCopy,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 19),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF8E8E93),
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1C1C1E),
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
          if (canCopy)
            IconButton(
              icon: const Icon(Icons.copy_rounded, size: 17, color: Color(0xFF8E8E93)),
              tooltip: "Salin",
              onPressed: () {
                Clipboard.setData(ClipboardData(text: value));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: const Color(0xFF0F766E),
                    duration: const Duration(seconds: 2),
                    content: Text("$label berhasil disalin."),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
