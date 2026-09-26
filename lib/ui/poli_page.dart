import 'package:flutter/material.dart';
import '../helpers/user_info.dart';
import '../model/poli.dart';
import '../service/poli_service.dart';
import '../widget/staggered_entrance.dart';
import '../widget/smooth_page_route.dart';
import 'poli_form.dart';
import 'poli_item.dart';

class PoliPage extends StatefulWidget {
  const PoliPage({super.key});

  @override
  State<PoliPage> createState() => _PoliPageState();
}

class _PoliPageState extends State<PoliPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late Future<List<Poli>> _poliFuture;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final isAdmin = await UserInfo().isAdmin();
    if (mounted) {
      setState(() {
        _isAdmin = isAdmin;
        _poliFuture = PoliService().listData();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(_isAdmin ? "Data Poli" : "Info Poliklinik"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: "Segarkan",
            onPressed: _loadData,
          ),
        ],
      ),
      floatingActionButton: _isAdmin
          ? FloatingActionButton.extended(
              backgroundColor: const Color(0xFF0F766E),
              foregroundColor: Colors.white,
              elevation: 2.5,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              icon: const Icon(Icons.add_rounded, size: 20),
              label: const Text(
                "Tambah Poli",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13.5,
                  letterSpacing: -0.2,
                ),
              ),
              onPressed: () async {
                await Navigator.push(
                  context,
                  SmoothPageRoute(page: const PoliForm()),
                );
                _loadData();
              },
            )
          : null,
      body: Column(
        children: [
          // Sleek Minimalist Search Bar Container
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFFE2E8F0),
                  width: 1.0,
                ),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(
                  fontSize: 14.5,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.2,
                ),
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                  isDense: true,
                  hintText: "Cari nama poli atau spesialis medis...",
                  hintStyle: const TextStyle(
                    fontSize: 13.5,
                    color: Color(0xFF94A3B8),
                    letterSpacing: -0.2,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: Color(0xFF0F766E),
                    size: 20,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.cancel_rounded,
                            size: 18,
                            color: Color(0xFF94A3B8),
                          ),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = "");
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase().trim();
                  });
                },
              ),
            ),
          ),
          const Divider(height: 0.8, color: Color(0xFFE2E8F0)),

          // Main List View
          Expanded(
            child: RefreshIndicator(
              color: const Color(0xFF0F766E),
              onRefresh: () async {
                _loadData();
              },
              child: FutureBuilder<List<Poli>>(
                future: _poliFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: Color(0xFF0F766E)),
                    );
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline_rounded, size: 48, color: Color(0xFFDC2626)),
                            const SizedBox(height: 12),
                            Text(
                              "Terjadi kesalahan saat memuat data:\n${snapshot.error}",
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Color(0xFF475569), fontSize: 13),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0F766E),
                                foregroundColor: Colors.white,
                                minimumSize: const Size(140, 44),
                              ),
                              onPressed: _loadData,
                              icon: const Icon(Icons.refresh_rounded, size: 18),
                              label: const Text("Coba Lagi"),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F766E).withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.local_hospital_outlined,
                              size: 44,
                              color: Color(0xFF0F766E),
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            "Belum Ada Data Poli",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            "Daftar ruangan poli belum tersedia di sistem.",
                            style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                          ),
                          const SizedBox(height: 18),
                          if (_isAdmin)
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0F766E),
                                foregroundColor: Colors.white,
                                minimumSize: const Size(150, 44),
                              ),
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  SmoothPageRoute(page: const PoliForm()),
                                );
                                _loadData();
                              },
                              icon: const Icon(Icons.add_rounded, size: 18),
                              label: const Text("Tambah Poli"),
                            ),
                        ],
                      ),
                    );
                  }

                  final filteredList = snapshot.data!.where((item) {
                    if (_searchQuery.isEmpty) return true;
                    return item.namaPoli.toLowerCase().contains(_searchQuery);
                  }).toList();

                  if (filteredList.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: const BoxDecoration(
                              color: Color(0xFFF1F5F9),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.search_off_rounded,
                              size: 40,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            "Poli Tidak Ditemukan",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Tidak ada poliklinik dengan kata kunci '$_searchQuery'",
                            style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                          ),
                          const SizedBox(height: 14),
                          TextButton.icon(
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = "");
                            },
                            icon: const Icon(Icons.refresh_rounded, size: 16),
                            label: const Text("Reset Pencarian"),
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF0F766E),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: [
                      // Section Header Bar
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  "UNIT POLIKLINIK",
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.8,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0F766E).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    "${filteredList.length} Layanan",
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF0F766E),
                                    ),
                                  ),
                                ),
                              ],
                            ),
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
                                const SizedBox(width: 5),
                                const Text(
                                  "Pelayanan Aktif",
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF10B981),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Card List
                      Expanded(
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.only(top: 4, bottom: 96),
                          itemCount: filteredList.length,
                          itemBuilder: (context, index) {
                            return StaggeredEntrance(
                              index: index,
                              child: PoliItem(
                                poli: filteredList[index],
                                onRefresh: _loadData,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
