import 'package:flutter/material.dart';
import '../helpers/user_info.dart';
import '../model/pasien.dart';
import '../service/pasien_service.dart';
import '../widget/staggered_entrance.dart';
import '../widget/smooth_page_route.dart';
import 'pasien_form.dart';
import 'pasien_item.dart';

class PasienPage extends StatefulWidget {
  const PasienPage({super.key});

  @override
  State<PasienPage> createState() => _PasienPageState();
}

class _PasienPageState extends State<PasienPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late Future<List<Pasien>> _pasienFuture;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  bool _isAdmin = true;

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
        if (isAdmin) {
          _pasienFuture = PasienService().listData();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (!_isAdmin) {
      return Scaffold(
        backgroundColor: const Color(0xFFF2F2F7),
        appBar: AppBar(title: const Text("Data Pasien")),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF9500).withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.lock_person_rounded, size: 48, color: Color(0xFFFF9500)),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Akses Terbatas",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: -0.3),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Halaman ini hanya dapat diakses oleh Administrator klinik.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF8E8E93), fontSize: 13.5),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F766E),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Kembali ke Beranda"),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        title: const Text("Data Pasien"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: "Segarkan",
            onPressed: _loadData,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF0F766E),
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.add_rounded),
        label: const Text("Tambah Pasien", style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: -0.2)),
        onPressed: () async {
          await Navigator.push(
            context,
            SmoothPageRoute(page: const PasienForm()),
          );
          _loadData();
        },
      ),
      body: Column(
        children: [
          // iOS Search Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFE3E3E8),
                borderRadius: BorderRadius.circular(11),
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
                  hintText: "Cari nama pasien atau No. RM...",
                  hintStyle: const TextStyle(
                    fontSize: 13.5,
                    color: Color(0xFF8E8E93),
                    letterSpacing: -0.2,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: Color(0xFF8E8E93),
                    size: 20,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.cancel_rounded,
                            size: 18,
                            color: Color(0xFF8E8E93),
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
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase().trim();
                  });
                },
              ),
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
              child: FutureBuilder<List<Pasien>>(
                future: _pasienFuture,
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
                              color: const Color(0xFF059669).withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.personal_injury_outlined,
                              size: 48,
                              color: Color(0xFF059669),
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            "Belum Ada Data Pasien",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            "Pendaftaran pasien klinik belum ada di sistem.",
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
                                SmoothPageRoute(page: const PasienForm()),
                              );
                              _loadData();
                            },
                            icon: const Icon(Icons.add_rounded, size: 18),
                            label: const Text("Tambah Pasien"),
                          ),
                        ],
                      ),
                    );
                  }

                  final filteredList = snapshot.data!.where((item) {
                    if (_searchQuery.isEmpty) return true;
                    return item.nama.toLowerCase().contains(_searchQuery) ||
                        item.nomorRm.toLowerCase().contains(_searchQuery);
                  }).toList();

                  if (filteredList.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.search_off_rounded, size: 48, color: Color(0xFF94A3B8)),
                          const SizedBox(height: 12),
                          Text(
                            "Tidak ditemukan pasien dengan kata kunci '$_searchQuery'",
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
                        child: PasienItem(
                          pasien: filteredList[index],
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
