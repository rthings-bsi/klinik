import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../helpers/luxury_theme.dart';
import '../helpers/user_info.dart';
import '../service/pasien_service.dart';
import '../widget/animated_pressable.dart';
import '../widget/smooth_page_route.dart';
import '../widget/staggered_entrance.dart';
import '../widget/aesthetic_background.dart';
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
    String? rm = await UserInfo().getNomorRm();
    final phone = await UserInfo().getNomorTelepon();

    if (!isAdmin && (rm == null || rm.isEmpty || rm == "-" || rm == "RM-BARU")) {
      final pasiens = await PasienService().listData();
      final match = pasiens.where((p) =>
          p.nama.toLowerCase().trim() == (nama ?? "").toLowerCase().trim() ||
          p.nomorTelepon.trim() == (phone ?? "").trim()).firstOrNull;
      final assignedRm = match?.nomorRm ?? await PasienService().generateNomorRm();
      await UserInfo().setNomorRm(assignedRm);
      rm = assignedRm;
    }

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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          "Konfirmasi Keluar",
          style: TextStyle(
            fontFamily: 'serif',
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
          ),
        ),
        content: const Text(
          "Apakah Anda yakin ingin mengakhiri sesi dan keluar dari akun ini?",
          style: TextStyle(
            color: LuxuryTheme.warmGrey,
            fontSize: 13.5,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: LuxuryTheme.charcoal,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text("BATAL"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: LuxuryTheme.crimson,
              foregroundColor: LuxuryTheme.pureWhite,
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
            child: const Text("KELUAR"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: LuxuryTheme.alabaster,
      appBar: AppBar(
        title: const Text("Akun & Profil"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 20),
            tooltip: "Segarkan",
            onPressed: _loadProfile,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: LuxuryTheme.charcoal, strokeWidth: 2),
            )
          : AestheticBackground(
              child: RefreshIndicator(
                color: LuxuryTheme.charcoal,
                backgroundColor: LuxuryTheme.alabaster,
                onRefresh: _loadProfile,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Avatar & Editorial Identity Card
                      StaggeredEntrance(
                        index: 0,
                        child: Container(
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: LuxuryTheme.pureWhite,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: LuxuryTheme.charcoal.withValues(alpha: 0.08),
                              width: 1.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: LuxuryTheme.charcoal.withValues(alpha: 0.04),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Initial Avatar with 1px Metallic Gold Border
                              Container(
                                width: 62,
                                height: 62,
                                decoration: BoxDecoration(
                                  color: LuxuryTheme.paleTaupe,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: LuxuryTheme.metallicGold,
                                    width: 1.2,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  _displayName.isNotEmpty
                                      ? _displayName[0].toUpperCase()
                                      : "U",
                                  style: const TextStyle(
                                    fontFamily: 'serif',
                                    fontSize: 26,
                                    fontWeight: FontWeight.w500,
                                    color: LuxuryTheme.charcoal,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 18),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _displayName,
                                      style: const TextStyle(
                                        fontFamily: 'serif',
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: LuxuryTheme.charcoal,
                                        letterSpacing: -0.3,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      "@$_username",
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: LuxuryTheme.warmGrey,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: LuxuryTheme.paleTaupe,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: LuxuryTheme.charcoal.withValues(alpha: 0.12),
                                          width: 1.0,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            _isAdmin
                                                ? Icons.admin_panel_settings_outlined
                                                : Icons.verified_user_outlined,
                                            size: 13,
                                            color: LuxuryTheme.charcoal,
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            _isAdmin ? "ADMINISTRATOR KLINIK" : "PASIEN TERDAFTAR",
                                            style: const TextStyle(
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.w700,
                                              color: LuxuryTheme.charcoal,
                                              letterSpacing: 1.0,
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

                      const SizedBox(height: 24),

                      // Section Header: Data Personal
                      _sectionHeader("DATA PERSONAL & MEDIS"),

                      const SizedBox(height: 8),

                      StaggeredEntrance(
                        index: 1,
                        child: Container(
                          decoration: BoxDecoration(
                            color: LuxuryTheme.pureWhite,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: LuxuryTheme.charcoal.withValues(alpha: 0.08),
                              width: 1.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: LuxuryTheme.charcoal.withValues(alpha: 0.03),
                                blurRadius: 12,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              _infoTile(
                                icon: Icons.medical_information_outlined,
                                label: "Nomor Rekam Medis (RM)",
                                value: _nomorRm,
                                canCopy: _nomorRm != "-",
                              ),
                              Divider(
                                height: 1,
                                thickness: 1,
                                indent: 56,
                                color: LuxuryTheme.charcoal.withValues(alpha: 0.08),
                              ),
                              _infoTile(
                                icon: Icons.phone_outlined,
                                label: "Nomor Telepon / WhatsApp",
                                value: _nomorTelepon,
                                canCopy: _nomorTelepon != "-",
                              ),
                              Divider(
                                height: 1,
                                thickness: 1,
                                indent: 56,
                                color: LuxuryTheme.charcoal.withValues(alpha: 0.08),
                              ),
                              _infoTile(
                                icon: Icons.shield_outlined,
                                label: "Tingkat Hak Akses",
                                value: _role,
                                canCopy: false,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Section Header: Informasi Klinik
                      _sectionHeader("INFORMASI KLINIK"),

                      const SizedBox(height: 8),

                      StaggeredEntrance(
                        index: 2,
                        child: Container(
                          decoration: BoxDecoration(
                            color: LuxuryTheme.pureWhite,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: LuxuryTheme.charcoal.withValues(alpha: 0.08),
                              width: 1.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: LuxuryTheme.charcoal.withValues(alpha: 0.03),
                                blurRadius: 12,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              _infoTile(
                                icon: Icons.access_time_rounded,
                                label: "Jam Operasional",
                                value: "Senin - Sabtu: 08:00 - 21:00 WIB",
                                canCopy: false,
                              ),
                              Divider(
                                height: 1,
                                thickness: 1,
                                indent: 56,
                                color: LuxuryTheme.charcoal.withValues(alpha: 0.08),
                              ),
                              _infoTile(
                                icon: Icons.location_on_outlined,
                                label: "Lokasi Layanan",
                                value: "Jl. Ahmad Yani No. 12, Pontianak",
                                canCopy: false,
                              ),
                              Divider(
                                height: 1,
                                thickness: 1,
                                indent: 56,
                                color: LuxuryTheme.charcoal.withValues(alpha: 0.08),
                              ),
                              _infoTile(
                                icon: Icons.emergency_outlined,
                                label: "Hotline Darurat",
                                value: "(0561) 734-567 / 119",
                                canCopy: true,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Logout Button
                      StaggeredEntrance(
                        index: 3,
                        child: AnimatedPressable(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () => _confirmLogout(context),
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: LuxuryTheme.pureWhite,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: LuxuryTheme.crimson.withValues(alpha: 0.6),
                                width: 1.0,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: LuxuryTheme.charcoal.withValues(alpha: 0.02),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.logout_rounded, color: LuxuryTheme.crimson, size: 18),
                                SizedBox(width: 8),
                                Text(
                                  "KELUAR DARI AKUN",
                                  style: TextStyle(
                                    color: LuxuryTheme.crimson,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.6,
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
            ),
    );
  }

  Widget _sectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 1.0,
          color: LuxuryTheme.metallicGold,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            color: LuxuryTheme.warmGrey,
            letterSpacing: 2.0,
          ),
        ),
      ],
    );
  }

  Widget _infoTile({
    required IconData icon,
    required String label,
    required String value,
    required bool canCopy,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: LuxuryTheme.paleTaupe,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: LuxuryTheme.charcoal.withValues(alpha: 0.08),
                width: 1.0,
              ),
            ),
            child: Icon(icon, color: LuxuryTheme.charcoal, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: LuxuryTheme.warmGrey,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    color: LuxuryTheme.charcoal,
                    letterSpacing: -0.1,
                  ),
                ),
              ],
            ),
          ),
          if (canCopy)
            IconButton(
              icon: const Icon(Icons.copy_rounded, size: 16, color: LuxuryTheme.warmGrey),
              tooltip: "Salin",
              onPressed: () {
                Clipboard.setData(ClipboardData(text: value));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: LuxuryTheme.charcoal,
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
