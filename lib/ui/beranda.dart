import 'package:flutter/material.dart';
import '../helpers/user_info.dart';
import '../model/antrian.dart';
import '../service/poli_service.dart';
import '../service/pegawai_service.dart';
import '../service/pasien_service.dart';
import '../service/antrian_service.dart';
import '../widget/sidebar.dart';
import '../widget/animated_pressable.dart';
import '../widget/staggered_entrance.dart';
import '../widget/smooth_page_route.dart';
import 'poli_page.dart';
import 'pegawai_page.dart';
import 'pasien_page.dart';
import 'antrian_page.dart';
import 'antrian_form.dart';

class Beranda extends StatefulWidget {
  const Beranda({super.key});

  @override
  State<Beranda> createState() => _BerandaState();
}

class _BerandaState extends State<Beranda> {
  String _displayName = "Admin";
  String _role = "Admin";
  bool _isAdmin = true;
  int _poliCount = 0;
  int _pegawaiCount = 0;
  int _pasienCount = 0;
  int _antrianCount = 0;
  int _myAntrianCount = 0;
  bool _isLoadingCounts = true;

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
    final name = (nama != null && nama.isNotEmpty)
        ? nama
        : (username != null && username.isNotEmpty ? username : "Pengguna");

    if (mounted) {
      setState(() {
        _role = role;
        _isAdmin = isAdmin;
        _displayName = name;
      });
    }
  }

  Future<void> _loadStatistics() async {
    setState(() => _isLoadingCounts = true);
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

        if (mounted) {
          setState(() {
            _poliCount = results[0].length;
            _pegawaiCount = results[1].length;
            _pasienCount = results[2].length;
            _antrianCount = results[3].length;
            _isLoadingCounts = false;
          });
        }
      } else {
        final results = await Future.wait([
          PoliService().listData(),
          AntrianService().listData(),
        ]);

        final allAntrian = results[1] as List<Antrian>;
        final myAntrian = allAntrian.where((a) {
          final pName = a.namaPasien.toLowerCase().trim();
          return (username.isNotEmpty && pName == username) ||
              (nama.isNotEmpty && pName == nama);
        }).toList();

        if (mounted) {
          setState(() {
            _poliCount = results[0].length;
            _antrianCount = allAntrian.length;
            _myAntrianCount = myAntrian.length;
            _isLoadingCounts = false;
          });
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingCounts = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      drawer: const Sidebar(activeMenu: "beranda"),
      appBar: AppBar(
        title: const Text("Beranda"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: "Muat Ulang Statistik",
            onPressed: _loadStatistics,
          ),
        ],
      ),
      body: RefreshIndicator(
        color: const Color(0xFF0F766E),
        onRefresh: () async {
          await _loadUser();
          await _loadStatistics();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Welcome Card with Staggered Entrance
              StaggeredEntrance(
                index: 0,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F766E),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F766E).withValues(alpha: 0.2),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(13),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
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
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _isAdmin ? "Selamat Bertugas," : "Halo Sehat,",
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontSize: 13,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _displayName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 21,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: -0.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Divider(color: Colors.white.withValues(alpha: 0.15), height: 1),
                      const SizedBox(height: 12),
                      Text(
                        _isAdmin
                            ? "Kelola operasional rawat jalan, pendaftaran pasien, serta tenaga medis secara terpusat."
                            : "Ambil nomor antrian berobat dan pantau status panggilan poliklinik secara langsung dari aplikasi.",
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 13,
                          height: 1.4,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // KPI Statistics (Grid)
              StaggeredEntrance(
                index: 1,
                child: _isAdmin
                    ? Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _kpiCard(
                                  title: "Antrian",
                                  count: _antrianCount,
                                  icon: Icons.confirmation_number_rounded,
                                  color: const Color(0xFFFF9500),
                                  isLoading: _isLoadingCounts,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      SmoothPageRoute(page: const AntrianPage()),
                                    ).then((_) => _loadStatistics());
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _kpiCard(
                                  title: "Poli",
                                  count: _poliCount,
                                  icon: Icons.meeting_room_rounded,
                                  color: const Color(0xFF0F766E),
                                  isLoading: _isLoadingCounts,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      SmoothPageRoute(page: const PoliPage()),
                                    ).then((_) => _loadStatistics());
                                  },
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
                                  count: _pegawaiCount,
                                  icon: Icons.badge_rounded,
                                  color: const Color(0xFF007AFF),
                                  isLoading: _isLoadingCounts,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      SmoothPageRoute(page: const PegawaiPage()),
                                    ).then((_) => _loadStatistics());
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _kpiCard(
                                  title: "Pasien",
                                  count: _pasienCount,
                                  icon: Icons.personal_injury_rounded,
                                  color: const Color(0xFF34C759),
                                  isLoading: _isLoadingCounts,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      SmoothPageRoute(page: const PasienPage()),
                                    ).then((_) => _loadStatistics());
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: _kpiCard(
                              title: "Antrian Saya",
                              count: _myAntrianCount,
                              icon: Icons.confirmation_number_rounded,
                              color: const Color(0xFFFF9500),
                              isLoading: _isLoadingCounts,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  SmoothPageRoute(page: const AntrianPage()),
                                ).then((_) => _loadStatistics());
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _kpiCard(
                              title: "Poli Tersedia",
                              count: _poliCount,
                              icon: Icons.meeting_room_rounded,
                              color: const Color(0xFF0F766E),
                              isLoading: _isLoadingCounts,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  SmoothPageRoute(page: const PoliPage()),
                                ).then((_) => _loadStatistics());
                              },
                            ),
                          ),
                        ],
                      ),
              ),

              const SizedBox(height: 24),

              // Inset Grouped Section Header (Apple HIG style)
              Padding(
                padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
                child: Text(
                  _isAdmin ? "LAYANAN MANAJEMEN" : "LAYANAN PASIEN",
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF8E8E93),
                    letterSpacing: 0.4,
                  ),
                ),
              ),

              // Menu Cards (Grouped list style)
              if (_isAdmin) ...[
                StaggeredEntrance(
                  index: 2,
                  child: _serviceMenuCard(
                    title: "Antrian Berobat Pasien",
                    subtitle: "Ambil nomor antrian, panggil pasien, & pantau status",
                    icon: Icons.confirmation_number_rounded,
                    color: const Color(0xFFFF9500),
                    badgeText: "$_antrianCount Antrian Terdaftar",
                    onTap: () {
                      Navigator.push(
                        context,
                        SmoothPageRoute(page: const AntrianPage()),
                      ).then((_) => _loadStatistics());
                    },
                  ),
                ),
                const SizedBox(height: 10),
                StaggeredEntrance(
                  index: 3,
                  child: _serviceMenuCard(
                    title: "Data Poli Klinik",
                    subtitle: "Kelola daftar ruangan dan poliklinik spesialis",
                    icon: Icons.meeting_room_rounded,
                    color: const Color(0xFF0F766E),
                    badgeText: "$_poliCount Poli Terdaftar",
                    onTap: () {
                      Navigator.push(
                        context,
                        SmoothPageRoute(page: const PoliPage()),
                      ).then((_) => _loadStatistics());
                    },
                  ),
                ),
                const SizedBox(height: 10),
                StaggeredEntrance(
                  index: 4,
                  child: _serviceMenuCard(
                    title: "Data Pegawai Medis",
                    subtitle: "Kelola biodata dokter, perawat, dan staf medis",
                    icon: Icons.badge_rounded,
                    color: const Color(0xFF007AFF),
                    badgeText: "$_pegawaiCount Pegawai Aktif",
                    onTap: () {
                      Navigator.push(
                        context,
                        SmoothPageRoute(page: const PegawaiPage()),
                      ).then((_) => _loadStatistics());
                    },
                  ),
                ),
                const SizedBox(height: 10),
                StaggeredEntrance(
                  index: 5,
                  child: _serviceMenuCard(
                    title: "Data Pasien & RM",
                    subtitle: "Kelola nomor rekam medis dan kontak pasien klinik",
                    icon: Icons.personal_injury_rounded,
                    color: const Color(0xFF34C759),
                    badgeText: "$_pasienCount Pasien Terdaftar",
                    onTap: () {
                      Navigator.push(
                        context,
                        SmoothPageRoute(page: const PasienPage()),
                      ).then((_) => _loadStatistics());
                    },
                  ),
                ),
              ] else ...[
                StaggeredEntrance(
                  index: 2,
                  child: _serviceMenuCard(
                    title: "Ambil Antrian Berobat",
                    subtitle: "Daftar antrian kunjungan dokter atau poli hari ini",
                    icon: Icons.add_circle_outline_rounded,
                    color: const Color(0xFF0F766E),
                    badgeText: "Buka Pendaftaran",
                    onTap: () {
                      Navigator.push(
                        context,
                        SmoothPageRoute(page: const AntrianForm()),
                      ).then((_) => _loadStatistics());
                    },
                  ),
                ),
                const SizedBox(height: 10),
                StaggeredEntrance(
                  index: 3,
                  child: _serviceMenuCard(
                    title: "Tiket & Antrian Saya",
                    subtitle: "Lihat status antrian dan tiket digital Anda",
                    icon: Icons.confirmation_number_rounded,
                    color: const Color(0xFFFF9500),
                    badgeText: "$_myAntrianCount Tiket Anda",
                    onTap: () {
                      Navigator.push(
                        context,
                        SmoothPageRoute(page: const AntrianPage()),
                      ).then((_) => _loadStatistics());
                    },
                  ),
                ),
                const SizedBox(height: 10),
                StaggeredEntrance(
                  index: 4,
                  child: _serviceMenuCard(
                    title: "Informasi Poliklinik",
                    subtitle: "Daftar poliklinik dan dokter spesialis yang tersedia",
                    icon: Icons.meeting_room_rounded,
                    color: const Color(0xFF007AFF),
                    badgeText: "$_poliCount Poli Tersedia",
                    onTap: () {
                      Navigator.push(
                        context,
                        SmoothPageRoute(page: const PoliPage()),
                      ).then((_) => _loadStatistics());
                    },
                  ),
                ),
              ],
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _kpiCard({
    required String title,
    required int count,
    required IconData icon,
    required Color color,
    required bool isLoading,
    required VoidCallback onTap,
  }) {
    return AnimatedPressable(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E5EA), width: 0.8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF8E8E93),
                    ),
                  )
                : Text(
                    "$count",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                      color: color,
                    ),
                  ),
            const SizedBox(height: 2),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: Color(0xFF8E8E93),
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _serviceMenuCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String badgeText,
    required VoidCallback onTap,
  }) {
    return AnimatedPressable(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E5EA), width: 0.8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1C1C1E),
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: Color(0xFF8E8E93),
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      badgeText,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: color,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFFC7C7CC),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
