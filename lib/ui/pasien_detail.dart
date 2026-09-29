import 'package:flutter/material.dart';
import '../helpers/luxury_theme.dart';
import '../model/pasien.dart';
import '../service/pasien_service.dart';
import '../widget/animated_pressable.dart';
import '../widget/smooth_page_route.dart';
import '../widget/aesthetic_background.dart';
import 'pasien_page.dart';
import 'pasien_update_form.dart';

class PasienDetail extends StatefulWidget {
  final Pasien pasien;

  const PasienDetail({super.key, required this.pasien});

  @override
  State<PasienDetail> createState() => _PasienDetailState();
}

class _PasienDetailState extends State<PasienDetail> {
  late Future<Pasien> _pasienFuture;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  void _loadDetail() {
    setState(() {
      if (widget.pasien.id != null) {
        _pasienFuture = PasienService().getById(widget.pasien.id!);
      } else {
        _pasienFuture = Future.value(widget.pasien);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LuxuryTheme.alabaster,
      appBar: AppBar(
        title: const Text("Detail Pasien"),
      ),
      body: AestheticBackground(
        child: FutureBuilder<Pasien>(
          future: _pasienFuture,
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
                        "Gagal memuat detail: ${snapshot.error}",
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: LuxuryTheme.warmGrey, fontSize: 13),
                      ),
                      const SizedBox(height: 18),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: LuxuryTheme.charcoal,
                          foregroundColor: LuxuryTheme.pureWhite,
                          minimumSize: const Size(130, 44),
                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                        ),
                        onPressed: _loadDetail,
                        child: const Text("COBA LAGI"),
                      ),
                    ],
                  ),
                ),
              );
            }
            if (!snapshot.hasData) {
              return const Center(child: Text("Data Pasien Tidak Ditemukan"));
            }

            final pasien = snapshot.data!;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24.0),
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
                                  width: 12,
                                  height: 1.0,
                                  color: LuxuryTheme.metallicGold,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  "BERKAS REKAM MEDIS",
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: LuxuryTheme.warmGrey,
                                    letterSpacing: 2.0,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: LuxuryTheme.paleTaupe,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: LuxuryTheme.charcoal.withValues(alpha: 0.12),
                                  width: 1.0,
                                ),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.check, size: 12, color: LuxuryTheme.forestGreen),
                                  SizedBox(width: 4),
                                  Text(
                                    "Terverifikasi",
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w600,
                                      color: LuxuryTheme.charcoal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Divider(height: 1, thickness: 1, color: LuxuryTheme.charcoal.withValues(alpha: 0.1)),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Container(
                              width: 54,
                              height: 54,
                              decoration: BoxDecoration(
                                color: LuxuryTheme.paleTaupe,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: LuxuryTheme.charcoal.withValues(alpha: 0.1),
                                  width: 1.0,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.person_outline_rounded,
                                size: 26,
                                color: LuxuryTheme.charcoal,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    pasien.nama,
                                    style: const TextStyle(
                                      fontFamily: 'serif',
                                      fontSize: 19,
                                      fontWeight: FontWeight.w600,
                                      color: LuxuryTheme.charcoal,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: LuxuryTheme.paleTaupe.withValues(alpha: 0.5),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: LuxuryTheme.charcoal.withValues(alpha: 0.1),
                                        width: 1.0,
                                      ),
                                    ),
                                    child: Text(
                                      "No. RM: ${pasien.nomorRm}",
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: LuxuryTheme.charcoal,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 20),
                        Divider(height: 1, thickness: 1, color: LuxuryTheme.charcoal.withValues(alpha: 0.1)),
                        const SizedBox(height: 16),
                        _infoRow(Icons.calendar_today_outlined, "TANGGAL LAHIR", pasien.tanggalLahir),
                        const SizedBox(height: 14),
                        _infoRow(Icons.phone_outlined, "NOMOR TELEPON", pasien.nomorTelepon),
                        const SizedBox(height: 14),
                        _infoRow(Icons.home_outlined, "ALAMAT TEMPAT TINGGAL", pasien.alamat),
                        if (pasien.id != null) ...[
                          const SizedBox(height: 14),
                          _infoRow(Icons.tag_rounded, "ID DATA", pasien.id!),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(child: _tombolUbah(pasien)),
                      const SizedBox(width: 14),
                      Expanded(child: _tombolHapus(pasien)),
                    ],
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: LuxuryTheme.paleTaupe,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: LuxuryTheme.charcoal.withValues(alpha: 0.08),
              width: 1.0,
            ),
          ),
          child: Icon(icon, size: 16, color: LuxuryTheme.charcoal),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: LuxuryTheme.warmGrey,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: LuxuryTheme.charcoal,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _tombolUbah(Pasien pasien) {
    return AnimatedPressable(
      borderRadius: BorderRadius.circular(14),
      onTap: () async {
        await Navigator.push(
          context,
          SmoothPageRoute(page: PasienUpdateForm(pasien: pasien)),
        );
        _loadDetail();
      },
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: LuxuryTheme.charcoal,
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.center,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.edit_outlined, size: 17, color: LuxuryTheme.pureWhite),
            SizedBox(width: 8),
            Text(
              "Ubah",
              style: TextStyle(
                color: LuxuryTheme.pureWhite,
                fontWeight: FontWeight.w600,
                fontSize: 13,
                letterSpacing: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tombolHapus(Pasien pasien) {
    return AnimatedPressable(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        showDialog(
          context: context,
          builder: (dialogContext) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              "Konfirmasi Hapus",
              style: TextStyle(
                fontFamily: 'serif',
                fontWeight: FontWeight.w600,
                letterSpacing: -0.3,
              ),
            ),
            content: Text(
              "Yakin ingin menghapus data pasien \"${pasien.nama}\"?",
              style: const TextStyle(color: LuxuryTheme.warmGrey, fontSize: 13.5),
            ),
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: LuxuryTheme.charcoal,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text("BATAL"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: LuxuryTheme.crimson,
                  foregroundColor: LuxuryTheme.pureWhite,
                  elevation: 0,
                  minimumSize: const Size(90, 40),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () async {
                  Navigator.pop(dialogContext);
                  try {
                    await PasienService().hapus(pasien);
                    if (!mounted) return;
                    Navigator.pushAndRemoveUntil(
                      context,
                      SmoothPageRoute(page: const PasienPage()),
                      (route) => route.isFirst,
                    );
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: LuxuryTheme.crimson,
                        content: Text("Gagal menghapus: $e"),
                      ),
                    );
                  }
                },
                child: const Text("HAPUS"),
              ),
            ],
          ),
        );
      },
      child: Container(
        height: 50,
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
            Icon(Icons.delete_outline_rounded, size: 17, color: LuxuryTheme.crimson),
            SizedBox(width: 8),
            Text(
              "Hapus",
              style: TextStyle(
                color: LuxuryTheme.crimson,
                fontWeight: FontWeight.w600,
                fontSize: 13,
                letterSpacing: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
