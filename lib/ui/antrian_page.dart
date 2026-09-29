import 'package:flutter/material.dart';
import '../helpers/luxury_theme.dart';
import '../helpers/user_info.dart';
import '../model/antrian.dart';
import '../service/antrian_service.dart';
import '../widget/animated_pressable.dart';
import '../widget/smooth_page_route.dart';
import '../widget/staggered_entrance.dart';
import '../widget/aesthetic_background.dart';
import 'antrian_detail.dart';
import 'antrian_form.dart';

class AntrianPage extends StatefulWidget {
  const AntrianPage({super.key});

  @override
  State<AntrianPage> createState() => _AntrianPageState();
}

class _AntrianPageState extends State<AntrianPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final TextEditingController _searchCtrl = TextEditingController();
  List<Antrian> _allAntrian = [];
  List<Antrian> _filteredAntrian = [];
  bool _isLoading = true;
  String _activeFilter = "Semua";
  bool _isAdmin = true;
  String _currentUser = "";
  String _currentNama = "";
  bool _hasSetInitialFilter = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchCtrl.addListener(_applyFilter);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final isAdmin = await UserInfo().isAdmin();
      final username = (await UserInfo().getUsername() ?? "").toLowerCase().trim();
      final nama = (await UserInfo().getNama() ?? "").toLowerCase().trim();

      if (!_hasSetInitialFilter) {
        _hasSetInitialFilter = true;
        _activeFilter = isAdmin ? "Semua" : "Antrian Saya";
      }

      final data = await AntrianService().listData();
      if (mounted) {
        setState(() {
          _isAdmin = isAdmin;
          _currentUser = username;
          _currentNama = nama;
          _allAntrian = data;
          _isLoading = false;
        });
        _applyFilter();
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _applyFilter() {
    final query = _searchCtrl.text.toLowerCase().trim();
    setState(() {
      _filteredAntrian = _allAntrian.where((item) {
        final matchesQuery = item.namaPasien.toLowerCase().contains(query) ||
            item.nomorAntrian.toLowerCase().contains(query) ||
            item.namaPoli.toLowerCase().contains(query);

        final pName = item.namaPasien.toLowerCase().trim();
        final isMyTicket = (_currentUser.isNotEmpty && pName == _currentUser) ||
            (_currentNama.isNotEmpty && pName == _currentNama);

        if (_activeFilter == "Antrian Saya") {
          return matchesQuery && isMyTicket;
        }

        final matchesStatus = _activeFilter == "Semua" ||
            item.status.toLowerCase() == _activeFilter.toLowerCase();

        return matchesQuery && matchesStatus;
      }).toList();
    });
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'menunggu':
        return const Color(0xFFB8860B); // Metallic Amber/Gold
      case 'dipanggil':
        return LuxuryTheme.charcoal;
      case 'selesai':
        return LuxuryTheme.forestGreen;
      case 'batal':
        return LuxuryTheme.crimson;
      default:
        return LuxuryTheme.warmGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final currentlyCalled = _allAntrian.firstWhere(
      (a) => a.status.toLowerCase() == 'dipanggil',
      orElse: () => Antrian(
        nomorAntrian: "-",
        idPoli: "",
        namaPoli: "Belum Ada Panggilan",
        namaPasien: "-",
        nomorRm: "",
        nomorTelepon: "",
        tanggal: "",
        waktu: "",
        keluhan: "",
        status: "",
      ),
    );

    return Scaffold(
      backgroundColor: LuxuryTheme.alabaster,
      appBar: AppBar(
        title: const Text("Antrian Berobat"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: "Muat Ulang Antrian",
            onPressed: _loadData,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: LuxuryTheme.charcoal,
        foregroundColor: LuxuryTheme.pureWhite,
        elevation: 3,
        shape: const CircleBorder(),
        tooltip: "Ambil Antrian",
        onPressed: () async {
          await Navigator.push(
            context,
            SmoothPageRoute(page: const AntrianForm()),
          );
          _loadData();
        },
        child: const Icon(Icons.add, size: 24),
      ),
      body: AestheticBackground(
        child: RefreshIndicator(
          color: LuxuryTheme.charcoal,
          backgroundColor: LuxuryTheme.alabaster,
          onRefresh: _loadData,
          child: Column(
            children: [
              // Top Live Queue Monitor Card (Editorial Charcoal)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                child: StaggeredEntrance(
                  index: 0,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: LuxuryTheme.charcoal,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: LuxuryTheme.metallicGold.withValues(alpha: 0.35),
                        width: 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: LuxuryTheme.charcoal.withValues(alpha: 0.16),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: LuxuryTheme.pureWhite,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: LuxuryTheme.metallicGold,
                              width: 1.0,
                            ),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                "DIPANGGIL",
                                style: TextStyle(
                                  color: LuxuryTheme.charcoal,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                currentlyCalled.nomorAntrian,
                                style: const TextStyle(
                                  fontFamily: 'serif',
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: LuxuryTheme.charcoal,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 10,
                                    height: 1.0,
                                    color: LuxuryTheme.metallicGold,
                                  ),
                                  const SizedBox(width: 6),
                                  const Text(
                                    "Sedang Berlangsung",
                                    style: TextStyle(
                                      color: LuxuryTheme.warmGrey,
                                      fontSize: 11,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                currentlyCalled.namaPoli,
                                style: const TextStyle(
                                  fontFamily: 'serif',
                                  color: LuxuryTheme.pureWhite,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              if (currentlyCalled.namaPasien != "-") ...[
                                const SizedBox(height: 3),
                                Text(
                                  "Pasien: ${currentlyCalled.namaPasien}",
                                  style: TextStyle(
                                    color: LuxuryTheme.pureWhite.withValues(alpha: 0.8),
                                    fontSize: 12.5,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Search Bar (Modern Luxury)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                child: Container(
                  height: 48,
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
                  child: TextField(
                    controller: _searchCtrl,
                    style: const TextStyle(
                      fontSize: 14,
                      color: LuxuryTheme.charcoal,
                      letterSpacing: -0.2,
                    ),
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: "Cari nama pasien, no antrian, poli...",
                      hintStyle: const TextStyle(
                        fontFamily: 'serif',
                        fontStyle: FontStyle.italic,
                        color: LuxuryTheme.warmGrey,
                        fontSize: 13,
                        letterSpacing: -0.2,
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: LuxuryTheme.charcoal,
                        size: 19,
                      ),
                      suffixIcon: _searchCtrl.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                Icons.close_rounded,
                                color: LuxuryTheme.charcoal,
                                size: 17,
                              ),
                              onPressed: () => _searchCtrl.clear(),
                            )
                          : null,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                  ),
                ),
              ),

              // Status Filter Tabs (Modern Luxury)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(
                  children: (_isAdmin
                          ? ["Semua", "Menunggu", "Dipanggil", "Selesai", "Batal"]
                          : ["Antrian Saya", "Semua", "Menunggu", "Dipanggil", "Selesai"])
                      .map((filter) {
                    final isSelected = _activeFilter == filter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: AnimatedPressable(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () {
                          setState(() => _activeFilter = filter);
                          _applyFilter();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: isSelected ? LuxuryTheme.charcoal : LuxuryTheme.pureWhite,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                  ? LuxuryTheme.charcoal
                                  : LuxuryTheme.charcoal.withValues(alpha: 0.1),
                              width: 1.0,
                            ),
                          ),
                          child: Text(
                            filter,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              color: isSelected ? LuxuryTheme.pureWhite : LuxuryTheme.charcoal,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 6),

              // Main Queue List View
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: LuxuryTheme.charcoal, strokeWidth: 2),
                      )
                    : _filteredAntrian.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                            itemCount: _filteredAntrian.length,
                            itemBuilder: (context, index) {
                              final antrian = _filteredAntrian[index];
                              final statusColor = _getStatusColor(antrian.status);

                              return StaggeredEntrance(
                                index: index,
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  child: AnimatedPressable(
                                    borderRadius: BorderRadius.circular(16),
                                    onTap: () async {
                                      await Navigator.push(
                                        context,
                                        SmoothPageRoute(page: AntrianDetail(antrian: antrian)),
                                      );
                                      _loadData();
                                    },
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
                                          // Number Box
                                          Container(
                                            width: 52,
                                            height: 52,
                                            decoration: BoxDecoration(
                                              color: LuxuryTheme.paleTaupe.withValues(alpha: 0.7),
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(
                                                color: LuxuryTheme.charcoal.withValues(alpha: 0.08),
                                                width: 1.0,
                                              ),
                                            ),
                                            alignment: Alignment.center,
                                            child: Text(
                                              antrian.nomorAntrian,
                                              style: const TextStyle(
                                                fontFamily: 'serif',
                                                fontSize: 17,
                                                fontWeight: FontWeight.bold,
                                                color: LuxuryTheme.charcoal,
                                                letterSpacing: -0.3,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 14),

                                          // Information
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  antrian.namaPasien,
                                                  style: const TextStyle(
                                                    fontFamily: 'serif',
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w600,
                                                    color: LuxuryTheme.charcoal,
                                                    letterSpacing: -0.2,
                                                  ),
                                                ),
                                                const SizedBox(height: 3),
                                                Text(
                                                  "${antrian.namaPoli} • ${antrian.waktu} WIB",
                                                  style: const TextStyle(
                                                    fontSize: 11.5,
                                                    color: LuxuryTheme.warmGrey,
                                                    letterSpacing: 0.1,
                                                  ),
                                                ),
                                                const SizedBox(height: 6),
                                                Row(
                                                  children: [
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(
                                                          horizontal: 6, vertical: 2),
                                                      decoration: BoxDecoration(
                                                        color: statusColor.withValues(alpha: 0.08),
                                                        borderRadius: BorderRadius.circular(6),
                                                        border: Border.all(
                                                          color: statusColor.withValues(alpha: 0.4),
                                                          width: 1.0,
                                                        ),
                                                      ),
                                                      child: Text(
                                                        antrian.status,
                                                        style: TextStyle(
                                                          fontSize: 10.5,
                                                          fontWeight: FontWeight.w600,
                                                          color: statusColor,
                                                        ),
                                                      ),
                                                    ),
                                                    if (antrian.nomorRm.isNotEmpty) ...[
                                                      const SizedBox(width: 8),
                                                      Container(
                                                        padding: const EdgeInsets.symmetric(
                                                            horizontal: 6, vertical: 2),
                                                        decoration: BoxDecoration(
                                                          color: LuxuryTheme.paleTaupe.withValues(alpha: 0.5),
                                                          borderRadius: BorderRadius.circular(6),
                                                          border: Border.all(
                                                            color: LuxuryTheme.charcoal.withValues(alpha: 0.1),
                                                            width: 1.0,
                                                          ),
                                                        ),
                                                        child: Text(
                                                          antrian.nomorRm,
                                                          style: const TextStyle(
                                                            fontSize: 10.5,
                                                            fontWeight: FontWeight.w600,
                                                            color: LuxuryTheme.charcoal,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          const Icon(
                                            Icons.arrow_forward_ios_rounded,
                                            color: LuxuryTheme.charcoal,
                                            size: 13,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: LuxuryTheme.paleTaupe,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: LuxuryTheme.charcoal.withValues(alpha: 0.14),
                  width: 1.0,
                ),
              ),
              child: const Icon(
                Icons.confirmation_number_outlined,
                size: 28,
                color: LuxuryTheme.charcoal,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Belum Ada Antrian",
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: LuxuryTheme.charcoal,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Belum ada antrian pasien pada kriteria ini. Silakan klik tombol di bawah untuk mengambil nomor antrian baru.",
              textAlign: TextAlign.center,
              style: TextStyle(color: LuxuryTheme.warmGrey, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: LuxuryTheme.charcoal,
                foregroundColor: LuxuryTheme.pureWhite,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              icon: const Icon(Icons.add, size: 16),
              label: const Text(
                "Ambil Antrian Baru",
                style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.5),
              ),
              onPressed: () async {
                await Navigator.push(
                  context,
                  SmoothPageRoute(page: const AntrianForm()),
                );
                _loadData();
              },
            ),
          ],
        ),
      ),
    );
  }
}
