import 'package:flutter/material.dart';
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
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isRoleLoaded) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8FAFC),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF0F766E)),
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
      backgroundColor: const Color(0xFFF8FAFC),
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
    final rm = await UserInfo().getNomorRm();
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

  IconData _getTimeIcon() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 11) {
      return Icons.wb_sunny_rounded;
    } else if (hour >= 11 && hour < 15) {
      return Icons.wb_sunny_outlined;
    } else if (hour >= 15 && hour < 18) {
      return Icons.wb_twilight_rounded;
    } else {
      return Icons.nights_stay_rounded;
    }
  }

  Color _getTimeIconColor() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 15) {
      return const Color(0xFFD97706); // Amber
    } else if (hour >= 15 && hour < 18) {
      return const Color(0xFFEA580C); // Orange
    } else {
      return const Color(0xFF6366F1); // Indigo
    }
  }

  void _showProfileModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.fromLTRB(
          20,
          14,
          20,
          24 + MediaQuery.of(ctx).padding.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 38,
                height: 4.5,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F766E).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF0F766E).withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _displayName.isNotEmpty ? _displayName[0].toUpperCase() : "U",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F766E),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _displayName,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          "Peran: $_role",
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(height: 1, color: Color(0xFFE2E8F0)),
            const SizedBox(height: 16),
            AnimatedPressable(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                Navigator.pop(ctx);
                _confirmLogout(context);
              },
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFDC2626).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFDC2626).withValues(alpha: 0.2),
                    width: 0.8,
                  ),
                ),
                alignment: Alignment.center,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout_rounded, color: Color(0xFFDC2626), size: 19),
                    SizedBox(width: 8),
                    Text(
                      "Keluar dari Akun",
                      style: TextStyle(
                        color: Color(0xFFDC2626),
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          "Konfirmasi Keluar",
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: -0.4),
        ),
        content: const Text(
          "Apakah Anda yakin ingin keluar dari akun ini?",
          style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text(
              "Batal",
              style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
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
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: const Color(0xFF0F766E),
          onRefresh: () async {
            await _loadUser();
            await _loadStatistics();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 96.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top App Bar & Brand Row
                StaggeredEntrance(
                  index: 0,
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            'assets/images/logo.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Klinik Pratama Medika",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 2.5),
                            Row(
                              children: [
                                Container(
                                  width: 7,
                                  height: 7,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF10B981),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF10B981).withValues(alpha: 0.4),
                                        blurRadius: 4,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  "Pelayanan Aktif • 08:00 - 21:00",
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.refresh_rounded, size: 19, color: Color(0xFF64748B)),
                          tooltip: "Segarkan Data",
                          onPressed: _loadStatistics,
                        ),
                      ),
                      const SizedBox(width: 8),
                      AnimatedPressable(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () => _showProfileModal(context),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0F766E), Color(0xFF115E59)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0F766E).withValues(alpha: 0.2),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            _displayName.isNotEmpty ? _displayName[0].toUpperCase() : "U",
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
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
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
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
                                  Icon(_getTimeIcon(), size: 13.5, color: _getTimeIconColor()),
                                  const SizedBox(width: 5),
                                  Text(
                                    _getCurrentDateFormatted(),
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                _isAdmin ? "Selamat Bertugas, $_displayName" : "Halo Sehat, $_displayName",
                                style: const TextStyle(
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F172A),
                                  letterSpacing: -0.3,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F766E).withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFF0F766E).withValues(alpha: 0.2), width: 0.6),
                          ),
                          child: Text(
                            _role,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F766E),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Hero Status / Live Antrian Card
                StaggeredEntrance(
                  index: 2,
                  child: _isAdmin ? _buildAdminHeroCard() : _buildPasienHeroCard(),
                ),

                const SizedBox(height: 20),

                // Quick Shortcuts Row
                StaggeredEntrance(
                  index: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "AKSI CEPAT",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF64748B),
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _isAdmin ? _buildAdminQuickActions() : _buildPasienQuickActions(),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Health Bulletin / Clinic Notice
                StaggeredEntrance(
                  index: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF0FDFA), Color(0xFFF8FAFC)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFCCFBF1), width: 0.9),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F766E).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.verified_user_rounded,
                            size: 18,
                            color: Color(0xFF0F766E),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Layanan Resep & Farmasi Siaga",
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              SizedBox(height: 1.5),
                              Text(
                                "Pengambilan obat resep & cek tensi gratis setiap hari kerja.",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Key Statistics (2x2 Grid)
                StaggeredEntrance(
                  index: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "RINGKASAN DATA",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF64748B),
                              letterSpacing: 0.8,
                            ),
                          ),
                          Text(
                            _isLoading ? "Sinkronisasi..." : "Real-time",
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _isAdmin ? _buildAdminKpiGrid() : _buildPasienKpiGrid(),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                // Featured Poliklinik Preview
                StaggeredEntrance(
                  index: 6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "UNIT POLIKLINIK",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF64748B),
                              letterSpacing: 0.8,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => widget.onSelectTab(2),
                            child: const Row(
                              children: [
                                Text(
                                  "Lihat Semua",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF0F766E),
                                  ),
                                ),
                                SizedBox(width: 2),
                                Icon(Icons.chevron_right_rounded, size: 16, color: Color(0xFF0F766E)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _buildFeaturedPoliList(),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Minimalist Clinic Info Footer Card
                StaggeredEntrance(
                  index: 7,
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F766E).withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.support_agent_rounded, size: 20, color: Color(0xFF0F766E)),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Hotline UGD & Ambulans",
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                              ),
                              SizedBox(height: 1),
                              Text(
                                "(0561) 734-567 • Jl. Ahmad Yani No. 12",
                                style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            "24 Jam",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F766E),
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
    );
  }

  Widget _buildAdminHeroCard() {
    final hasCalled = _currentlyCalledAntrian != null;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.16),
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
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 7),
                  const Text(
                    "MONITOR ANTRIAN KLINIK",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF94A3B8),
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.12), width: 0.6),
                ),
                child: Text(
                  "$_antrianCount Pasien Hari Ini",
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFF334155)),
          const SizedBox(height: 14),
          if (hasCalled) ...[
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F766E).withValues(alpha: 0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Text(
                    _currentlyCalledAntrian!.nomorAntrian,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _currentlyCalledAntrian!.namaPoli,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Pasien: ${_currentlyCalledAntrian!.namaPasien}",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF94A3B8),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3), width: 0.6),
                  ),
                  child: Text(
                    _currentlyCalledAntrian!.status,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF34D399),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Micro summary bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _adminMicroStat("Menunggu", _waitingCount.toString(), const Color(0xFFFBBF24)),
                  Container(width: 1, height: 16, color: const Color(0xFF334155)),
                  _adminMicroStat("Dipanggil", hasCalled ? "1" : "0", const Color(0xFF34D399)),
                  Container(width: 1, height: 16, color: const Color(0xFF334155)),
                  _adminMicroStat("Selesai", _completedCount.toString(), const Color(0xFF94A3B8)),
                ],
              ),
            ),
          ] else ...[
            const Row(
              children: [
                Icon(Icons.hourglass_empty_rounded, size: 24, color: Color(0xFF94A3B8)),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Belum ada nomor antrian yang dipanggil saat ini.",
                    style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          AnimatedPressable(
            borderRadius: BorderRadius.circular(12),
            onTap: () => widget.onSelectTab(1),
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.12), width: 0.8),
              ),
              alignment: Alignment.center,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.dashboard_customize_outlined, size: 16, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    "Buka Meja Antrian Pasien",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
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

  Widget _adminMicroStat(String label, String value, Color valueColor) {
    return Row(
      children: [
        Text(
          "$label: ",
          style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
        ),
        Text(
          value,
          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: valueColor),
        ),
      ],
    );
  }

  Widget _buildPasienHeroCard() {
    final hasTicket = _myActiveTicket != null;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 16,
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
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: hasTicket ? const Color(0xFF10B981) : const Color(0xFF0F766E),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 7),
                  Text(
                    hasTicket ? "KARTU ANTRIAN DIGITAL" : "LAYANAN RAWAT JALAN",
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF64748B),
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              if (hasTicket)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F766E).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF0F766E).withValues(alpha: 0.2), width: 0.6),
                  ),
                  child: Text(
                    _myActiveTicket!.status,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F766E),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          const SizedBox(height: 14),
          if (hasTicket) ...[
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F766E), Color(0xFF115E59)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _myActiveTicket!.nomorAntrian,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _myActiveTicket!.namaPoli,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Tanggal: ${_myActiveTicket!.tanggal}",
                        style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            AnimatedPressable(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                Navigator.push(
                  context,
                  SmoothPageRoute(page: AntrianDetail(antrian: _myActiveTicket!)),
                ).then((_) => _loadStatistics());
              },
              child: Container(
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
                ),
                alignment: Alignment.center,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.qr_code_rounded, size: 16, color: Color(0xFF0F766E)),
                    SizedBox(width: 8),
                    Text(
                      "Lihat Kartu Antrian Saya",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F766E),
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
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F766E).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.add_task_rounded, size: 24, color: Color(0xFF0F766E)),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Belum Memiliki Antrian",
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        "Daftar konsultasi dokter spesialis sekarang tanpa antre.",
                        style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            AnimatedPressable(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                Navigator.push(
                  context,
                  SmoothPageRoute(page: const AntrianForm()),
                ).then((_) => _loadStatistics());
              },
              child: Container(
                height: 42,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F766E), Color(0xFF115E59)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F766E).withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_rounded, size: 18, color: Colors.white),
                    SizedBox(width: 6),
                    Text(
                      "Ambil Nomor Antrian",
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
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
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _actionPill(
          label: "Antrian",
          icon: Icons.confirmation_number_rounded,
          color: const Color(0xFFD97706),
          bgColor: const Color(0xFFFFFBEB),
          onTap: () => widget.onSelectTab(1),
        ),
        _actionPill(
          label: "Poli",
          icon: Icons.meeting_room_rounded,
          color: const Color(0xFF0F766E),
          bgColor: const Color(0xFFF0FDFA),
          onTap: () => widget.onSelectTab(2),
        ),
        _actionPill(
          label: "Pegawai",
          icon: Icons.badge_rounded,
          color: const Color(0xFF0284C7),
          bgColor: const Color(0xFFF0F9FF),
          onTap: () => widget.onSelectTab(3),
        ),
        _actionPill(
          label: "Pasien",
          icon: Icons.personal_injury_rounded,
          color: const Color(0xFF10B981),
          bgColor: const Color(0xFFECFDF5),
          onTap: () => widget.onSelectTab(4),
        ),
      ],
    );
  }

  Widget _buildPasienQuickActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _actionPill(
          label: "Daftar",
          icon: Icons.add_circle_outline_rounded,
          color: const Color(0xFF0F766E),
          bgColor: const Color(0xFFF0FDFA),
          onTap: () {
            Navigator.push(
              context,
              SmoothPageRoute(page: const AntrianForm()),
            ).then((_) => _loadStatistics());
          },
        ),
        _actionPill(
          label: "Tiket",
          icon: Icons.confirmation_number_rounded,
          color: const Color(0xFFD97706),
          bgColor: const Color(0xFFFFFBEB),
          onTap: () => widget.onSelectTab(1),
        ),
        _actionPill(
          label: "Poli",
          icon: Icons.meeting_room_rounded,
          color: const Color(0xFF0284C7),
          bgColor: const Color(0xFFF0F9FF),
          onTap: () => widget.onSelectTab(2),
        ),
        _actionPill(
          label: "Profil",
          icon: Icons.person_rounded,
          color: const Color(0xFF4F46E5),
          bgColor: const Color(0xFFEEF2FF),
          onTap: () => widget.onSelectTab(3),
        ),
      ],
    );
  }

  Widget _actionPill({
    required String label,
    required IconData icon,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: AnimatedPressable(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: bgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 21),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF334155),
                  ),
                ),
              ],
            ),
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
                icon: Icons.confirmation_number_rounded,
                color: const Color(0xFFD97706),
                bgColor: const Color(0xFFFFFBEB),
                onTap: () => widget.onSelectTab(1),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _kpiCard(
                title: "Poli",
                count: _poliCount.toString(),
                subtitle: "Unit Poliklinik",
                icon: Icons.meeting_room_rounded,
                color: const Color(0xFF0F766E),
                bgColor: const Color(0xFFF0FDFA),
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
                icon: Icons.badge_rounded,
                color: const Color(0xFF0284C7),
                bgColor: const Color(0xFFF0F9FF),
                onTap: () => widget.onSelectTab(3),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _kpiCard(
                title: "Pasien",
                count: _pasienCount.toString(),
                subtitle: "Rekam Medis",
                icon: Icons.personal_injury_rounded,
                color: const Color(0xFF10B981),
                bgColor: const Color(0xFFECFDF5),
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
                icon: Icons.confirmation_number_rounded,
                color: const Color(0xFFD97706),
                bgColor: const Color(0xFFFFFBEB),
                onTap: () => widget.onSelectTab(1),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _kpiCard(
                title: "Poli Buka",
                count: _poliCount.toString(),
                subtitle: "Spesialis Medis",
                icon: Icons.meeting_room_rounded,
                color: const Color(0xFF0F766E),
                bgColor: const Color(0xFFF0FDFA),
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
                icon: Icons.badge_rounded,
                color: const Color(0xFF0284C7),
                bgColor: const Color(0xFFF0F9FF),
                onTap: () {},
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _kpiCard(
                title: "No. RM",
                count: _nomorRm != "-" ? _nomorRm : "Aktif",
                subtitle: "Rekam Medis",
                icon: Icons.medical_information_rounded,
                color: const Color(0xFF10B981),
                bgColor: const Color(0xFFECFDF5),
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
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return AnimatedPressable(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.02),
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
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 19),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF0F766E),
                    ),
                  )
                : Text(
                    count,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF94A3B8),
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
        ),
        alignment: Alignment.center,
        child: const Text(
          "Memuat poliklinik...",
          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
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
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.02),
                    blurRadius: 6,
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
                      color: meta.backgroundColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Icon(meta.icon, color: meta.primaryColor, size: 21),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          poli.namaPoli,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              meta.category,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: meta.primaryColor,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text("•", style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 10)),
                            const SizedBox(width: 6),
                            Text(
                              meta.location,
                              style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 13,
                    color: Color(0xFF94A3B8),
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
