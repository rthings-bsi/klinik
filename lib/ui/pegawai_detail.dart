import 'package:flutter/material.dart';
import '../model/pegawai.dart';
import '../service/pegawai_service.dart';
import '../widget/animated_pressable.dart';
import '../widget/smooth_page_route.dart';
import 'pegawai_page.dart';
import 'pegawai_update_form.dart';

class PegawaiDetail extends StatefulWidget {
  final Pegawai pegawai;

  const PegawaiDetail({super.key, required this.pegawai});

  @override
  State<PegawaiDetail> createState() => _PegawaiDetailState();
}

class _PegawaiDetailState extends State<PegawaiDetail> {
  late Future<Pegawai> _pegawaiFuture;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  void _loadDetail() {
    setState(() {
      if (widget.pegawai.id != null) {
        _pegawaiFuture = PegawaiService().getById(widget.pegawai.id!);
      } else {
        _pegawaiFuture = Future.value(widget.pegawai);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        title: const Text("Detail Pegawai"),
      ),
      body: FutureBuilder<Pegawai>(
        future: _pegawaiFuture,
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
                    const Icon(Icons.error_outline_rounded, size: 48, color: Color(0xFFFF3B30)),
                    const SizedBox(height: 12),
                    Text(
                      "Gagal memuat detail: ${snapshot.error}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F766E),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(130, 44),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _loadDetail,
                      child: const Text("Coba Lagi"),
                    ),
                  ],
                ),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: Text("Data Pegawai Tidak Ditemukan"));
          }

          final pegawai = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
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
                      Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: const Color(0xFF007AFF).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.badge_rounded,
                              size: 28,
                              color: Color(0xFF007AFF),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  pegawai.nama,
                                  style: const TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1C1C1E),
                                    letterSpacing: -0.4,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF007AFF).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    "NIP: ${pegawai.nip}",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF007AFF),
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 18),
                      const Divider(height: 1, color: Color(0xFFE5E5EA)),
                      const SizedBox(height: 16),
                      _infoRow(Icons.cake_rounded, "Tanggal Lahir", pegawai.tanggalLahir),
                      const SizedBox(height: 14),
                      _infoRow(Icons.phone_rounded, "Nomor Telepon", pegawai.nomorTelepon),
                      const SizedBox(height: 14),
                      _infoRow(Icons.email_rounded, "Alamat Email", pegawai.email),
                      if (pegawai.id != null) ...[
                        const SizedBox(height: 14),
                        _infoRow(Icons.tag_rounded, "ID Data", pegawai.id!),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(child: _tombolUbah(pegawai)),
                    const SizedBox(width: 14),
                    Expanded(child: _tombolHapus(pegawai)),
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFF007AFF).withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: const Color(0xFF007AFF)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Color(0xFF8E8E93), letterSpacing: -0.2),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1C1C1E),
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _tombolUbah(Pegawai pegawai) {
    return AnimatedPressable(
      borderRadius: BorderRadius.circular(14),
      onTap: () async {
        await Navigator.push(
          context,
          SmoothPageRoute(page: PegawaiUpdateForm(pegawai: pegawai)),
        );
        _loadDetail();
      },
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: const Color(0xFF007AFF),
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.edit_rounded, size: 18, color: Colors.white),
            SizedBox(width: 8),
            Text(
              "Ubah",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 15,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tombolHapus(Pegawai pegawai) {
    return AnimatedPressable(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        showDialog(
          context: context,
          builder: (dialogContext) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            title: const Text(
              "Konfirmasi Hapus",
              style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: -0.4),
            ),
            content: Text(
              "Yakin ingin menghapus data pegawai \"${pegawai.nama}\"?",
              style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 14),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text(
                  "Batal",
                  style: TextStyle(color: Color(0xFF8E8E93), fontWeight: FontWeight.w600),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF3B30),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  minimumSize: const Size(90, 40),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () async {
                  Navigator.pop(dialogContext);
                  try {
                    await PegawaiService().hapus(pegawai);
                    if (!mounted) return;
                    Navigator.pushAndRemoveUntil(
                      context,
                      SmoothPageRoute(page: const PegawaiPage()),
                      (route) => route.isFirst,
                    );
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Gagal menghapus: $e")),
                    );
                  }
                },
                child: const Text("Hapus"),
              ),
            ],
          ),
        );
      },
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: const Color(0xFFFF3B30),
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.delete_outline_rounded, size: 18, color: Colors.white),
            SizedBox(width: 8),
            Text(
              "Hapus",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 15,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
