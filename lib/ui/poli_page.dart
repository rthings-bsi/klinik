import 'package:flutter/material.dart';
import '../helpers/user_info.dart';
import '../model/poli.dart';
import '../service/poli_service.dart';
import '../widget/sidebar.dart';
import '../widget/staggered_entrance.dart';
import '../widget/smooth_page_route.dart';
import 'poli_form.dart';
import 'poli_item.dart';

class PoliPage extends StatefulWidget {
  const PoliPage({super.key});

  @override
  State<PoliPage> createState() => _PoliPageState();
}

class _PoliPageState extends State<PoliPage> {
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
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      drawer: const Sidebar(activeMenu: "poli"),
      appBar: AppBar(
        title: Text(_isAdmin ? "Data Poli" : "Info Poliklinik"),
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
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              icon: const Icon(Icons.add_rounded),
              label: const Text("Tambah Poli",
                  style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: -0.2)),
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
          // iOS Search Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Cari nama poli...",
                hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF8E8E93)),
                prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF0F766E), size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18, color: Color(0xFF8E8E93)),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = "");
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                filled: true,
                fillColor: const Color(0xFFF2F2F7),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF0F766E), width: 1.2),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase().trim();
                });
              },
            ),
          ),
          const Divider(height: 0.8, color: Color(0xFFE5E5EA)),

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
                              Icons.meeting_room_outlined,
                              size: 48,
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
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            "Daftar ruangan poli belum tersedia di sistem.",
                            style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                          ),
                          const SizedBox(height: 18),
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
                          const Icon(Icons.search_off_rounded, size: 48, color: Color(0xFF94A3B8)),
                          const SizedBox(height: 12),
                          Text(
                            "Tidak ditemukan poli dengan nama '$_searchQuery'",
                            style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.only(top: 10, bottom: 80),
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
