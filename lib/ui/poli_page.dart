import 'package:flutter/material.dart';
import '../helpers/luxury_theme.dart';
import '../helpers/user_info.dart';
import '../model/poli.dart';
import '../service/poli_service.dart';
import '../widget/staggered_entrance.dart';
import '../widget/smooth_page_route.dart';
import '../widget/aesthetic_background.dart';
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
      backgroundColor: LuxuryTheme.alabaster,
      appBar: AppBar(
        title: Text(_isAdmin ? "Data Poli" : "Info Poliklinik"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 20),
            tooltip: "Segarkan",
            onPressed: _loadData,
          ),
        ],
      ),
      floatingActionButton: _isAdmin
          ? FloatingActionButton(
              backgroundColor: LuxuryTheme.charcoal,
              foregroundColor: LuxuryTheme.pureWhite,
              elevation: 3,
              shape: const CircleBorder(),
              tooltip: "Tambah Poli",
              onPressed: () async {
                await Navigator.push(
                  context,
                  SmoothPageRoute(page: const PoliForm()),
                );
                _loadData();
              },
              child: const Icon(Icons.add, size: 24),
            )
          : null,
      body: AestheticBackground(
        child: Column(
          children: [
            // Editorial Luxury Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 10),
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
                      color: LuxuryTheme.charcoal.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(
                    fontSize: 14,
                    color: LuxuryTheme.charcoal,
                  ),
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: "Cari nama poli atau spesialis medis...",
                    hintStyle: const TextStyle(
                      fontFamily: 'serif',
                      fontStyle: FontStyle.italic,
                      fontSize: 13,
                      color: LuxuryTheme.warmGrey,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: LuxuryTheme.charcoal,
                      size: 20,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Icons.close_rounded,
                              size: 16,
                              color: LuxuryTheme.charcoal,
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
                    filled: false,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase().trim();
                    });
                  },
                ),
              ),
            ),

            // Main List View
            Expanded(
              child: RefreshIndicator(
                color: LuxuryTheme.charcoal,
                backgroundColor: LuxuryTheme.alabaster,
                onRefresh: () async {
                  _loadData();
                },
                child: FutureBuilder<List<Poli>>(
                  future: _poliFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: LuxuryTheme.charcoal, strokeWidth: 2),
                      );
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(28.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline_rounded, size: 40, color: LuxuryTheme.crimson),
                              const SizedBox(height: 14),
                              Text(
                                "Terjadi kesalahan saat memuat data:\n${snapshot.error}",
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: LuxuryTheme.warmGrey, fontSize: 13),
                              ),
                              const SizedBox(height: 18),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: LuxuryTheme.charcoal,
                                  foregroundColor: LuxuryTheme.pureWhite,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  minimumSize: const Size(140, 44),
                                ),
                                onPressed: _loadData,
                                icon: const Icon(Icons.refresh_rounded, size: 16),
                                label: const Text("COBA LAGI"),
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
                              width: 54,
                              height: 54,
                              decoration: BoxDecoration(
                                color: LuxuryTheme.paleTaupe,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: LuxuryTheme.charcoal.withValues(alpha: 0.12),
                                  width: 1.0,
                                ),
                              ),
                              child: const Icon(
                                Icons.local_hospital_outlined,
                                size: 26,
                                color: LuxuryTheme.charcoal,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              "Belum Ada Data Poli",
                              style: TextStyle(
                                fontFamily: 'serif',
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: LuxuryTheme.charcoal,
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              "Daftar ruangan poli belum tersedia di sistem.",
                              style: TextStyle(fontSize: 12.5, color: LuxuryTheme.warmGrey),
                            ),
                            const SizedBox(height: 20),
                            if (_isAdmin)
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: LuxuryTheme.charcoal,
                                  foregroundColor: LuxuryTheme.pureWhite,
                                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                                  minimumSize: const Size(150, 44),
                                ),
                                onPressed: () async {
                                  await Navigator.push(
                                    context,
                                    SmoothPageRoute(page: const PoliForm()),
                                  );
                                  _loadData();
                                },
                                icon: const Icon(Icons.add, size: 16),
                                label: const Text("TAMBAH POLI"),
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
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: LuxuryTheme.paleTaupe,
                                border: Border.all(
                                  color: LuxuryTheme.charcoal.withValues(alpha: 0.12),
                                  width: 1.0,
                                ),
                              ),
                              child: const Icon(
                                Icons.search_off_rounded,
                                size: 24,
                                color: LuxuryTheme.charcoal,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              "Poli Tidak Ditemukan",
                              style: TextStyle(
                                fontFamily: 'serif',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: LuxuryTheme.charcoal,
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Tidak ada poliklinik dengan kata kunci '$_searchQuery'",
                              style: const TextStyle(color: LuxuryTheme.warmGrey, fontSize: 12.5),
                            ),
                            const SizedBox(height: 16),
                            TextButton.icon(
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = "");
                              },
                              icon: const Icon(Icons.refresh_rounded, size: 16),
                              label: const Text("RESET PENCARIAN"),
                              style: TextButton.styleFrom(
                                foregroundColor: LuxuryTheme.charcoal,
                                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
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
                          padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 14,
                                    height: 1.0,
                                    color: LuxuryTheme.metallicGold,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    "UNIT POLIKLINIK",
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 2.0,
                                      color: LuxuryTheme.warmGrey,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: LuxuryTheme.paleTaupe,
                                      border: Border.all(
                                        color: LuxuryTheme.charcoal.withValues(alpha: 0.1),
                                        width: 1.0,
                                      ),
                                    ),
                                    child: Text(
                                      "${filteredList.length} LAYANAN",
                                      style: const TextStyle(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w700,
                                        color: LuxuryTheme.charcoal,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    color: LuxuryTheme.forestGreen,
                                  ),
                                  const SizedBox(width: 5),
                                  const Text(
                                    "Pelayanan Aktif",
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: LuxuryTheme.warmGrey,
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
      ),
    );
  }
}
