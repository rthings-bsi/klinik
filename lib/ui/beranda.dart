import 'package:flutter/material.dart';
import '../helpers/luxury_theme.dart';
import '../helpers/user_info.dart';
import '../helpers/poli_helper.dart';
import '../model/antrian.dart';
import '../model/poli.dart';
import '../model/pegawai.dart';
import '../model/pasien.dart';
import '../service/poli_service.dart';
import '../service/pegawai_service.dart';
import '../service/pasien_service.dart';
import '../service/antrian_service.dart';
import '../widget/animated_pressable.dart';
import '../widget/staggered_entrance.dart';
import '../widget/smooth_page_route.dart';
import '../widget/elegant_navbar.dart';
import '../widget/aesthetic_background.dart';
import 'login.dart';
import 'poli_page.dart';
import 'poli_detail.dart';
import 'pegawai_page.dart';
import 'pasien_page.dart';
import 'antrian_page.dart';
import 'antrian_detail.dart';
import 'antrian_form.dart';
import 'profile_view.dart';

class Beranda extends StatefulWidget {
  const Beranda({super.key});

  @override
  State<Beranda> createState() => _BerandaState();
}

class _BerandaState extends State<Beranda> {
  int _currentIndex = 0;
  late final PageController _pageController;
  bool _isAdmin = true;
  bool _isRoleLoaded = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
    _checkRole();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _checkRole() async {
    final isAdmin = await UserInfo().isAdmin();
    if (mounted) {
      setState(() {
        _isAdmin = isAdmin;
        _isRoleLoaded = true;
      });
    }
  }

  void _onTabTapped(int index) {
    if (_currentIndex == index) return;
    setState(() => _currentIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 350),
      curve: const Cubic(0.25, 0.46, 0.45, 0.94),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isRoleLoaded) {
      return const Scaffold(
        backgroundColor: LuxuryTheme.alabaster,
        body: Center(
          child: CircularProgressIndicator(color: LuxuryTheme.charcoal, strokeWidth: 2),
        ),
      );
    }

    final navItems = _isAdmin
        ? const [
            NavBarItem(
              icon: Icons.home_outlined,
              activeIcon: Icons.home_rounded,
              label: "Beranda",
            ),
            NavBarItem(
              icon: Icons.confirmation_number_outlined,
              activeIcon: Icons.confirmation_number_rounded,
              label: "Antrian",
            ),
            NavBarItem(
              icon: Icons.meeting_room_outlined,
              activeIcon: Icons.meeting_room_rounded,
              label: "Poli",
            ),
            NavBarItem(
              icon: Icons.badge_outlined,
              activeIcon: Icons.badge_rounded,
              label: "Pegawai",
            ),
            NavBarItem(
              icon: Icons.personal_injury_outlined,
              activeIcon: Icons.personal_injury_rounded,
              label: "Pasien",
            ),
          ]
        : const [
            NavBarItem(
              icon: Icons.home_outlined,
              activeIcon: Icons.home_rounded,
              label: "Beranda",
            ),
            NavBarItem(
              icon: Icons.confirmation_number_outlined,
              activeIcon: Icons.confirmation_number_rounded,
              label: "Antrian",
            ),
            NavBarItem(
              icon: Icons.meeting_room_outlined,
              activeIcon: Icons.meeting_room_rounded,
              label: "Poli",
            ),
            NavBarItem(
              icon: Icons.person_outline_rounded,
              activeIcon: Icons.person_rounded,
              label: "Akun",
            ),
          ];

    final pages = _isAdmin
        ? [
            BerandaDashboardView(onSelectTab: _onTabTapped),
            const AntrianPage(),
            const PoliPage(),
            const PegawaiPage(),
            const PasienPage(),
          ]
        : [
            BerandaDashboardView(onSelectTab: _onTabTapped),
            const AntrianPage(),
            const PoliPage(),
            const ProfileView(),
          ];

    return Scaffold(
      backgroundColor: LuxuryTheme.alabaster,
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: pages,
      ),
      bottomNavigationBar: ElegantNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: navItems,
      ),
    );
  }
}

class BerandaDashboardView extends StatefulWidget {
  final ValueChanged<int> onSelectTab;

  const BerandaDashboardView({
    super.key,
    required this.onSelectTab,
  });

  @override
  State<BerandaDashboardView> createState() => _BerandaDashboardViewState();
}

class _BerandaDashboardViewState extends State<BerandaDashboardView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  String _displayName = "Pengguna";
  String _role = "Admin";
  String _nomorRm = "-";
  bool _isAdmin = true;

  int _poliCount = 0;
  int _pegawaiCount = 0;
  int _pasienCount = 0;
  int _antrianCount = 0;
  int _myAntrianCount = 0;
  int _waitingCount = 0;
  int _completedCount = 0;
  bool _isLoading = true;

  List<Poli> _featuredPoli = [];
  Antrian? _myActiveTicket;
  Antrian? _currentlyCalledAntrian;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadStatistics();
  }

  Future<void> _loadUser() async {
    final role = await UserInfo().getRole();
    final isAdmin = await UserInfo().isAdmin();
    final nama = await UserInfo().getNama();
    final username = await UserInfo().getUsername();
    String? rm = await UserInfo().getNomorRm();

    if (!isAdmin && (rm == null || rm.isEmpty || rm == "-" || rm == "RM-BARU")) {
      final pasiens = await PasienService().listData();
      final match = pasiens.where((p) =>
          p.nama.toLowerCase().trim() == (nama ?? "").toLowerCase().trim()).firstOrNull;
      if (match != null && match.nomorRm.isNotEmpty) {
        rm = match.nomorRm;
        await UserInfo().setNomorRm(rm);
      }
    }

    final name = (nama != null && nama.isNotEmpty)
        ? nama
        : (username != null && username.isNotEmpty ? username : "Pengguna");

    if (mounted) {
      setState(() {
        _role = role;
        _isAdmin = isAdmin;
        _displayName = name;
        _nomorRm = (rm != null && rm.isNotEmpty) ? rm : "-";
      });
    }
  }

  Future<void> _loadStatistics() async {
    setState(() => _isLoading = true);
    final isAdmin = await UserInfo().isAdmin();
    final username = (await UserInfo().getUsername() ?? "").toLowerCase().trim();
    final nama = (await UserInfo().getNama() ?? "").toLowerCase().trim();

    try {
      if (isAdmin) {
        final results = await Future.wait([
          PoliService().listData(),
          PegawaiService().listData(),
          PasienService().listData(),
          AntrianService().listData(),
        ]);

        final poliList = results[0] as List<Poli>;
        final pegawaiList = results[1] as List<Pegawai>;
        final pasienList = results[2] as List<Pasien>;
        final antrianList = results[3] as List<Antrian>;

        Antrian? called;
        int waiting = 0;
        int completed = 0;

        for (final a in antrianList) {
          final st = a.status.toLowerCase();
          if (st.contains('panggil') || st.contains('proses') || st.contains('periksa')) {
            called ??= a;
          } else if (st.contains('selesai')) {
            completed++;
          } else {
            waiting++;
          }
        }
        called ??= antrianList.isNotEmpty ? antrianList.first : null;

        if (mounted) {
          setState(() {
            _poliCount = poliList.length;
            _pegawaiCount = pegawaiList.length;
            _pasienCount = pasienList.length;
            _antrianCount = antrianList.length;
            _waitingCount = waiting;
            _completedCount = completed;
            _featuredPoli = poliList.take(3).toList();
            _currentlyCalledAntrian = called;
            _isLoading = false;
          });
        }
      } else {
        final results = await Future.wait([
          PoliService().listData(),
          AntrianService().listData(),
          PegawaiService().listData(),
        ]);

        final poliList = results[0] as List<Poli>;
        final allAntrian = results[1] as List<Antrian>;
        final pegawaiList = results[2] as List<Pegawai>;

        final myAntrian = allAntrian.where((a) {
          final pName = a.namaPasien.toLowerCase().trim();
          return (username.isNotEmpty && pName == username) ||
              (nama.isNotEmpty && pName == nama);
        }).toList();

        Antrian? myTicket;
        for (final a in myAntrian) {
          final st = a.status.toLowerCase();
          if (st.contains('menunggu') || st.contains('panggil') || st.contains('proses')) {
            myTicket = a;
            break;
          }
        }
        myTicket ??= myAntrian.isNotEmpty ? myAntrian.first : null;

        if (mounted) {
          setState(() {
            _poliCount = poliList.length;
            _pegawaiCount = pegawaiList.length;
            _antrianCount = allAntrian.length;
            _myAntrianCount = myAntrian.length;
            _featuredPoli = poliList.take(3).toList();
            _myActiveTicket = myTicket;
            _isLoading = false;
          });
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getCurrentDateFormatted() {
    final now = DateTime.now();
    const days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];
    final dayName = days[now.weekday - 1];
    final monthName = months[now.month - 1];
    return '$dayName, ${now.day} $monthName ${now.year}';
  }

  void _showProfileModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: LuxuryTheme.pureWhite,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(
            top: BorderSide(color: LuxuryTheme.charcoal.withValues(alpha: 0.12), width: 1.0),
          ),
          boxShadow: [
            BoxShadow(
              color: LuxuryTheme.charcoal.withValues(alpha: 0.08),
              blurRadius: 24,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        padding: EdgeInsets.fromLTRB(
          24,
          20,
          24,
          24 + MediaQuery.of(ctx).padding.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4.0,
                decoration: BoxDecoration(
                  color: LuxuryTheme.charcoal.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
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
                    _displayName.isNotEmpty ? _displayName[0].toUpperCase() : "U",
                    style: const TextStyle(
                      fontFamily: 'serif',
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: LuxuryTheme.charcoal,
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
                          fontFamily: 'serif',
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: LuxuryTheme.charcoal,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
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
                        child: Text(
                          "PERAN: ${_role.toUpperCase()}",
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: LuxuryTheme.charcoal,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Divider(height: 1, thickness: 1, color: LuxuryTheme.charcoal.withValues(alpha: 0.1)),
            const SizedBox(height: 18),
            AnimatedPressable(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                Navigator.pop(ctx);
                _confirmLogout(context);
              },
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: LuxuryTheme.pureWhite,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: LuxuryTheme.crimson.withValues(alpha: 0.6),
                    width: 1.0,
                  ),
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
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
          "Apakah Anda yakin ingin keluar dari akun ini?",
          style: TextStyle(color: LuxuryTheme.warmGrey, fontSize: 13.5),
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
      body: AestheticBackground(
        child: SafeArea(
          bottom: false,
          child: RefreshIndicator(
            color: LuxuryTheme.charcoal,
            backgroundColor: LuxuryTheme.alabaster,
            onRefresh: () async {
              await _loadUser();
              await _loadStatistics();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 96.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top App Bar & Brand Row
                  StaggeredEntrance(
                    index: 0,
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: LuxuryTheme.pureWhite,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: LuxuryTheme.charcoal.withValues(alpha: 0.1),
                              width: 1.0,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(11),
                            child: Image.asset(
                              'assets/images/logo.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Klinik Pratama Medika",
                                style: TextStyle(
                                  fontFamily: 'serif',
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: LuxuryTheme.charcoal,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 2.5),
                              Row(
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      color: LuxuryTheme.forestGreen,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Text(
                                    "Pelayanan Aktif • 08:00 - 21:00",
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: LuxuryTheme.warmGrey,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: LuxuryTheme.pureWhite,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: LuxuryTheme.charcoal.withValues(alpha: 0.08),
                              width: 1.0,
                            ),
                          ),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: const Icon(Icons.refresh_rounded, size: 19, color: LuxuryTheme.charcoal),
                            tooltip: "Segarkan Data",
                            onPressed: _loadStatistics,
                          ),
                        ),
                        const SizedBox(width: 8),
                        AnimatedPressable(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => _showProfileModal(context),
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: LuxuryTheme.paleTaupe,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: LuxuryTheme.metallicGold,
                                width: 1.0,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              _displayName.isNotEmpty ? _displayName[0].toUpperCase() : "U",
                              style: const TextStyle(
                                fontFamily: 'serif',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: LuxuryTheme.charcoal,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Greeting & Date Section
                  StaggeredEntrance(
                    index: 1,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 1.0,
                                      color: LuxuryTheme.metallicGold,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      _getCurrentDateFormatted().toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: LuxuryTheme.warmGrey,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  _isAdmin ? "Selamat Bertugas, $_displayName" : "Halo Sehat, $_displayName",
                                  style: const TextStyle(
                                    fontFamily: 'serif',
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                    color: LuxuryTheme.charcoal,
                                    letterSpacing: -0.3,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: LuxuryTheme.paleTaupe,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: LuxuryTheme.charcoal.withValues(alpha: 0.12),
                                width: 1.0,
                              ),
                            ),
                            child: Text(
                              _role.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: LuxuryTheme.charcoal,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Hero Status / Live Antrian Card
                  StaggeredEntrance(
                    index: 2,
                    child: _isAdmin ? _buildAdminHeroCard() : _buildPasienHeroCard(),
                  ),

                  const SizedBox(height: 24),

                  // Quick Shortcuts Section
                  StaggeredEntrance(
                    index: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader("AKSI CEPAT"),
                        const SizedBox(height: 12),
                        _isAdmin ? _buildAdminQuickActions() : _buildPasienQuickActions(),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Health Bulletin / Clinic Notice
                  StaggeredEntrance(
                    index: 4,
                    child: Container(
                      padding: const EdgeInsets.all(16),
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
                      child: Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: LuxuryTheme.paleTaupe.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: LuxuryTheme.charcoal.withValues(alpha: 0.08),
                                width: 1.0,
                              ),
                            ),
                            child: const Icon(
                              Icons.verified_user_outlined,
                              size: 19,
                              color: LuxuryTheme.charcoal,
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Layanan Resep & Farmasi Siaga",
                                  style: TextStyle(
                                    fontFamily: 'serif',
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                    color: LuxuryTheme.charcoal,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  "Pengambilan obat resep & pemeriksaan tensi gratis setiap hari kerja.",
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: LuxuryTheme.warmGrey,
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

                  // Key Statistics (2x2 Grid)
                  StaggeredEntrance(
                    index: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildSectionHeader("RINGKASAN DATA"),
                            Text(
                              _isLoading ? "SINKRONISASI..." : "REAL-TIME",
                              style: const TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w600,
                                color: LuxuryTheme.warmGrey,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _isAdmin ? _buildAdminKpiGrid() : _buildPasienKpiGrid(),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Featured Poliklinik Preview
                  StaggeredEntrance(
                    index: 6,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildSectionHeader("UNIT POLIKLINIK"),
                            GestureDetector(
                              onTap: () => widget.onSelectTab(2),
                              child: const Row(
                                children: [
                                  Text(
                                    "LIHAT SEMUA",
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: LuxuryTheme.charcoal,
                                      letterSpacing: 1.4,
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Icon(Icons.arrow_forward, size: 12, color: LuxuryTheme.charcoal),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildFeaturedPoliList(),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Clinic Info Footer Card
                  StaggeredEntrance(
                    index: 7,
                    child: Container(
                      padding: const EdgeInsets.all(18),
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
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: LuxuryTheme.paleTaupe.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.support_agent_outlined, size: 21, color: LuxuryTheme.charcoal),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Hotline UGD & Ambulans",
                                  style: TextStyle(
                                    fontFamily: 'serif',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: LuxuryTheme.charcoal,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  "(0561) 734-567 • Jl. Ahmad Yani No. 12",
                                  style: TextStyle(fontSize: 11.5, color: LuxuryTheme.warmGrey),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: LuxuryTheme.alabaster,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: LuxuryTheme.metallicGold,
                                width: 1.0,
                              ),
                            ),
                            child: const Text(
                              "24 JAM",
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: LuxuryTheme.charcoal,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
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
            fontWeight: FontWeight.w700,
            color: LuxuryTheme.warmGrey,
            letterSpacing: 2.0,
          ),
        ),
      ],
    );
  }

  Widget _buildAdminHeroCard() {
    final hasCalled = _currentlyCalledAntrian != null;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: LuxuryTheme.charcoal,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: LuxuryTheme.metallicGold.withValues(alpha: 0.35),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: LuxuryTheme.charcoal.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: LuxuryTheme.charcoal.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: LuxuryTheme.metallicGold,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "MONITOR ANTRIAN KLINIK",
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: LuxuryTheme.paleTaupe,
                      letterSpacing: 1.8,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1.0),
                ),
                child: Text(
                  "$_antrianCount PASIEN HARI INI",
                  style: const TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(height: 1, thickness: 1, color: Colors.white.withValues(alpha: 0.12)),
          const SizedBox(height: 16),
          if (hasCalled) ...[
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: LuxuryTheme.pureWhite,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: LuxuryTheme.metallicGold, width: 1.0),
                  ),
                  child: Text(
                    _currentlyCalledAntrian!.nomorAntrian,
                    style: const TextStyle(
                      fontFamily: 'serif',
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: LuxuryTheme.charcoal,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _currentlyCalledAntrian!.namaPoli,
                        style: const TextStyle(
                          fontFamily: 'serif',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        "Pasien: ${_currentlyCalledAntrian!.namaPasien}",
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: LuxuryTheme.paleTaupe,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: LuxuryTheme.metallicGold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: LuxuryTheme.metallicGold.withValues(alpha: 0.6), width: 1.0),
                  ),
                  child: Text(
                    _currentlyCalledAntrian!.status.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: LuxuryTheme.metallicGold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Micro summary bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 1.0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: Center(child: _adminMicroStat("Menunggu", _waitingCount.toString())),
                  ),
                  Container(width: 1, height: 16, color: Colors.white.withValues(alpha: 0.15)),
                  Expanded(
                    child: Center(child: _adminMicroStat("Dipanggil", hasCalled ? "1" : "0")),
                  ),
                  Container(width: 1, height: 16, color: Colors.white.withValues(alpha: 0.15)),
                  Expanded(
                    child: Center(child: _adminMicroStat("Selesai", _completedCount.toString())),
                  ),
                ],
              ),
            ),
          ] else ...[
            const Row(
              children: [
                Icon(Icons.hourglass_empty_rounded, size: 20, color: LuxuryTheme.paleTaupe),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Belum ada nomor antrian yang dipanggil saat ini.",
                    style: TextStyle(fontSize: 13, color: LuxuryTheme.paleTaupe),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 18),
          AnimatedPressable(
            borderRadius: BorderRadius.circular(12),
            onTap: () => widget.onSelectTab(1),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 1.0),
              ),
              alignment: Alignment.center,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.dashboard_customize_outlined, size: 16, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    "BUKA MEJA ANTRIAN PASIEN",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _adminMicroStat(String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            "$label: ",
            style: const TextStyle(fontSize: 11, color: LuxuryTheme.paleTaupe),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildPasienHeroCard() {
    final hasTicket = _myActiveTicket != null;
    return Container(
      width: double.infinity,
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
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: hasTicket ? LuxuryTheme.forestGreen : LuxuryTheme.metallicGold,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    hasTicket ? "KARTU ANTRIAN DIGITAL" : "LAYANAN RAWAT JALAN",
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: LuxuryTheme.warmGrey,
                      letterSpacing: 1.8,
                    ),
                  ),
                ],
              ),
              if (hasTicket)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: LuxuryTheme.paleTaupe.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: LuxuryTheme.charcoal.withValues(alpha: 0.12), width: 1.0),
                  ),
                  child: Text(
                    _myActiveTicket!.status.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      color: LuxuryTheme.charcoal,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(height: 1, thickness: 1, color: LuxuryTheme.charcoal.withValues(alpha: 0.08)),
          const SizedBox(height: 16),
          if (hasTicket) ...[
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: LuxuryTheme.paleTaupe.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: LuxuryTheme.metallicGold, width: 1.0),
                  ),
                  child: Text(
                    _myActiveTicket!.nomorAntrian,
                    style: const TextStyle(
                      fontFamily: 'serif',
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: LuxuryTheme.charcoal,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _myActiveTicket!.namaPoli,
                        style: const TextStyle(
                          fontFamily: 'serif',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: LuxuryTheme.charcoal,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Tanggal: ${_myActiveTicket!.tanggal}",
                        style: const TextStyle(fontSize: 12, color: LuxuryTheme.warmGrey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AnimatedPressable(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                Navigator.push(
                  context,
                  SmoothPageRoute(page: AntrianDetail(antrian: _myActiveTicket!)),
                ).then((_) => _loadStatistics());
              },
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: LuxuryTheme.paleTaupe.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: LuxuryTheme.charcoal.withValues(alpha: 0.15), width: 1.0),
                ),
                alignment: Alignment.center,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.qr_code_rounded, size: 18, color: LuxuryTheme.charcoal),
                    SizedBox(width: 8),
                    Text(
                      "LIHAT KARTU ANTRIAN SAYA",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: LuxuryTheme.charcoal,
                        letterSpacing: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: LuxuryTheme.paleTaupe.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.add_task_rounded, size: 22, color: LuxuryTheme.charcoal),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Belum Memiliki Antrian",
                        style: TextStyle(
                          fontFamily: 'serif',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: LuxuryTheme.charcoal,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        "Daftar konsultasi dokter spesialis sekarang tanpa antre.",
                        style: TextStyle(fontSize: 12, color: LuxuryTheme.warmGrey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AnimatedPressable(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                Navigator.push(
                  context,
                  SmoothPageRoute(page: const AntrianForm()),
                ).then((_) => _loadStatistics());
              },
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: LuxuryTheme.charcoal,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, size: 18, color: LuxuryTheme.pureWhite),
                    SizedBox(width: 6),
                    Text(
                      "Ambil Nomor Antrian",
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: LuxuryTheme.pureWhite,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAdminQuickActions() {
    return Row(
      children: [
        _actionPill(
          label: "Antrian",
          icon: Icons.confirmation_number_outlined,
          onTap: () => widget.onSelectTab(1),
        ),
        const SizedBox(width: 8),
        _actionPill(
          label: "Poli",
          icon: Icons.meeting_room_outlined,
          onTap: () => widget.onSelectTab(2),
        ),
        const SizedBox(width: 8),
        _actionPill(
          label: "Pegawai",
          icon: Icons.badge_outlined,
          onTap: () => widget.onSelectTab(3),
        ),
        const SizedBox(width: 8),
        _actionPill(
          label: "Pasien",
          icon: Icons.personal_injury_outlined,
          onTap: () => widget.onSelectTab(4),
        ),
      ],
    );
  }

  Widget _buildPasienQuickActions() {
    return Row(
      children: [
        _actionPill(
          label: "Daftar",
          icon: Icons.add_circle_outline_rounded,
          onTap: () {
            Navigator.push(
              context,
              SmoothPageRoute(page: const AntrianForm()),
            ).then((_) => _loadStatistics());
          },
        ),
        const SizedBox(width: 8),
        _actionPill(
          label: "Tiket",
          icon: Icons.confirmation_number_outlined,
          onTap: () => widget.onSelectTab(1),
        ),
        const SizedBox(width: 8),
        _actionPill(
          label: "Poli",
          icon: Icons.meeting_room_outlined,
          onTap: () => widget.onSelectTab(2),
        ),
        const SizedBox(width: 8),
        _actionPill(
          label: "Profil",
          icon: Icons.person_outline_rounded,
          onTap: () => widget.onSelectTab(3),
        ),
      ],
    );
  }

  Widget _actionPill({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: AnimatedPressable(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
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
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: LuxuryTheme.paleTaupe.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: LuxuryTheme.charcoal, size: 21),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: LuxuryTheme.charcoal,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdminKpiGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _kpiCard(
                title: "Antrian",
                count: _antrianCount.toString(),
                subtitle: "Pasien Terdaftar",
                icon: Icons.confirmation_number_outlined,
                onTap: () => widget.onSelectTab(1),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _kpiCard(
                title: "Poli",
                count: _poliCount.toString(),
                subtitle: "Unit Poliklinik",
                icon: Icons.meeting_room_outlined,
                onTap: () => widget.onSelectTab(2),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _kpiCard(
                title: "Pegawai",
                count: _pegawaiCount.toString(),
                subtitle: "Tenaga Medis",
                icon: Icons.badge_outlined,
                onTap: () => widget.onSelectTab(3),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _kpiCard(
                title: "Pasien",
                count: _pasienCount.toString(),
                subtitle: "Rekam Medis",
                icon: Icons.personal_injury_outlined,
                onTap: () => widget.onSelectTab(4),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPasienKpiGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _kpiCard(
                title: "Tiket Saya",
                count: _myAntrianCount.toString(),
                subtitle: "Antrian Terdaftar",
                icon: Icons.confirmation_number_outlined,
                onTap: () => widget.onSelectTab(1),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _kpiCard(
                title: "Poli Buka",
                count: _poliCount.toString(),
                subtitle: "Spesialis Medis",
                icon: Icons.meeting_room_outlined,
                onTap: () => widget.onSelectTab(2),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _kpiCard(
                title: "Dokter & Staf",
                count: _pegawaiCount.toString(),
                subtitle: "Tenaga Medis",
                icon: Icons.badge_outlined,
                onTap: () {},
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _kpiCard(
                title: "No. RM",
                count: _nomorRm != "-" ? _nomorRm : "Aktif",
                subtitle: "Rekam Medis",
                icon: Icons.medical_information_outlined,
                onTap: () => widget.onSelectTab(3),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _kpiCard({
    required String title,
    required String count,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return AnimatedPressable(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
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
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: LuxuryTheme.paleTaupe.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(icon, color: LuxuryTheme.charcoal, size: 19),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: LuxuryTheme.paleTaupe.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      title.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: LuxuryTheme.warmGrey,
                        letterSpacing: 1.0,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _isLoading
                ? const SizedBox(
                    height: 26,
                    width: 26,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: LuxuryTheme.charcoal,
                    ),
                  )
                : Text(
                    count,
                    style: const TextStyle(
                      fontFamily: 'serif',
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: LuxuryTheme.charcoal,
                      letterSpacing: -0.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 11.5,
                color: LuxuryTheme.warmGrey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedPoliList() {
    if (_featuredPoli.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: LuxuryTheme.pureWhite,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: LuxuryTheme.charcoal.withValues(alpha: 0.08), width: 1.0),
        ),
        alignment: Alignment.center,
        child: const Text(
          "Memuat poliklinik...",
          style: TextStyle(color: LuxuryTheme.warmGrey, fontSize: 13),
        ),
      );
    }

    return Column(
      children: _featuredPoli.map((poli) {
        final meta = PoliHelper.getMeta(poli.namaPoli);
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: AnimatedPressable(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              Navigator.push(
                context,
                SmoothPageRoute(page: PoliDetail(poli: poli)),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: LuxuryTheme.pureWhite,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: LuxuryTheme.charcoal.withValues(alpha: 0.08),
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: LuxuryTheme.charcoal.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: LuxuryTheme.paleTaupe.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    alignment: Alignment.center,
                    child: Icon(meta.icon, color: LuxuryTheme.charcoal, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          poli.namaPoli,
                          style: const TextStyle(
                            fontFamily: 'serif',
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                            color: LuxuryTheme.charcoal,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          meta.category.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: LuxuryTheme.warmGrey,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 12,
                    color: LuxuryTheme.charcoal,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
