import 'package:flutter/material.dart';
import '../helpers/user_info.dart';
import '../model/antrian.dart';
import '../service/antrian_service.dart';
import '../widget/animated_pressable.dart';
import '../widget/smooth_page_route.dart';
import '../widget/staggered_entrance.dart';
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
        return const Color(0xFFFF9500);
      case 'dipanggil':
        return const Color(0xFF007AFF);
      case 'selesai':
        return const Color(0xFF34C759);
      case 'batal':
        return const Color(0xFFFF3B30);
      default:
        return const Color(0xFF8E8E93);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // Find currently active called queue
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
      backgroundColor: const Color(0xFFF2F2F7),
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
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF0F766E),
        foregroundColor: Colors.white,
        elevation: 3,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          "Ambil Antrian",
          style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: -0.2),
        ),
        onPressed: () async {
          await Navigator.push(
            context,
            SmoothPageRoute(page: const AntrianForm()),
          );
          _loadData();
        },
      ),
      body: RefreshIndicator(
        color: const Color(0xFF0F766E),
        onRefresh: _loadData,
        child: Column(
          children: [
            // Top Live Queue Monitor Card
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: StaggeredEntrance(
                index: 0,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F766E),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F766E).withValues(alpha: 0.25),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              "DIPANGGIL",
                              style: TextStyle(
                                color: Color(0xFF0F766E),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              currentlyCalled.nomorAntrian,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F766E),
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Sedang Berlangsung",
                              style: TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              currentlyCalled.namaPoli,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.3,
                              ),
                            ),
                            if (currentlyCalled.namaPasien != "-") ...[
                              const SizedBox(height: 2),
                              Text(
                                "Pasien: ${currentlyCalled.namaPasien}",
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.9),
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

            // Search Bar (iOS Cupertino style)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFE3E3E8),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: TextField(
                  controller: _searchCtrl,
                  style: const TextStyle(
                    fontSize: 14.5,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.2,
                  ),
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: "Cari nama pasien, no antrian, poli...",
                    hintStyle: const TextStyle(
                      color: Color(0xFF8E8E93),
                      fontSize: 13.5,
                      letterSpacing: -0.2,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: Color(0xFF8E8E93),
                      size: 20,
                    ),
                    suffixIcon: _searchCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Icons.cancel_rounded,
                              color: Color(0xFF8E8E93),
                              size: 18,
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

            // Status Filter Tabs
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
                          color: isSelected ? const Color(0xFF0F766E) : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF0F766E)
                                : const Color(0xFFE5E5EA),
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          filter,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? Colors.white : const Color(0xFF1C1C1E),
                            letterSpacing: -0.2,
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
                      child: CircularProgressIndicator(color: Color(0xFF0F766E)),
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
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                          color: const Color(0xFFE5E5EA), width: 0.8),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.03),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        // Number Pill
                                        Container(
                                          width: 54,
                                          height: 54,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF0F766E).withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(14),
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            antrian.nomorAntrian,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF0F766E),
                                              letterSpacing: -0.5,
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
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF1C1C1E),
                                                  letterSpacing: -0.3,
                                                ),
                                              ),
                                              const SizedBox(height: 3),
                                              Text(
                                                "${antrian.namaPoli} • ${antrian.waktu} WIB",
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Color(0xFF8E8E93),
                                                  letterSpacing: -0.2,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Row(
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(
                                                        horizontal: 8, vertical: 3),
                                                    decoration: BoxDecoration(
                                                      color: statusColor.withValues(alpha: 0.12),
                                                      borderRadius: BorderRadius.circular(6),
                                                    ),
                                                    child: Text(
                                                      antrian.status,
                                                      style: TextStyle(
                                                        fontSize: 11.5,
                                                        fontWeight: FontWeight.w600,
                                                        color: statusColor,
                                                        letterSpacing: -0.2,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    antrian.nomorRm,
                                                    style: const TextStyle(
                                                      fontSize: 11.5,
                                                      color: Color(0xFF8E8E93),
                                                    ),
                                                  ),
                                                ],
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
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
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
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFF0F766E).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.confirmation_number_outlined,
                size: 32,
                color: Color(0xFF0F766E),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Belum Ada Antrian",
              style: TextStyle(
                fontSize: 16.5,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1C1C1E),
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Belum ada antrian pasien pada kriteria ini. Silakan klik tombol di bawah untuk mengambil nomor antrian baru.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF8E8E93), fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F766E),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text("Ambil Antrian Baru"),
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
