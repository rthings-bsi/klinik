import 'package:flutter/material.dart';
import '../helpers/luxury_theme.dart';
import '../helpers/poli_helper.dart';
import '../helpers/user_info.dart';
import '../model/poli.dart';
import '../service/poli_service.dart';
import '../widget/animated_pressable.dart';
import '../widget/smooth_page_route.dart';
import '../widget/aesthetic_background.dart';
import 'antrian_form.dart';
import 'poli_page.dart';
import 'poli_update_form.dart';

class PoliDetail extends StatefulWidget {
  final Poli poli;

  const PoliDetail({super.key, required this.poli});

  @override
  State<PoliDetail> createState() => _PoliDetailState();
}

class _PoliDetailState extends State<PoliDetail> {
  late Future<Poli> _poliFuture;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    final isAdmin = await UserInfo().isAdmin();
    if (mounted) {
      setState(() {
        _isAdmin = isAdmin;
        if (widget.poli.id != null) {
          _poliFuture = PoliService().getById(widget.poli.id!);
        } else {
          _poliFuture = Future.value(widget.poli);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LuxuryTheme.alabaster,
      appBar: AppBar(
        title: const Text("Detail Poli"),
      ),
      body: AestheticBackground(
        child: FutureBuilder<Poli>(
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
              return const Center(child: Text("Data Poli Tidak Ditemukan"));
            }

            final poli = snapshot.data!;
            final meta = PoliHelper.getMeta(poli.namaPoli);
            return Padding(
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
                                  "INFORMASI POLIKLINIK",
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
                                    "Pelayanan Aktif",
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
                              child: Icon(
                                meta.icon,
                                color: LuxuryTheme.charcoal,
                                size: 26,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    poli.namaPoli,
                                    style: const TextStyle(
                                      fontFamily: 'serif',
                                      fontSize: 19,
                                      fontWeight: FontWeight.w600,
                                      color: LuxuryTheme.charcoal,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    meta.category,
                                    style: const TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w500,
                                      color: LuxuryTheme.warmGrey,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (poli.id != null) ...[
                          const SizedBox(height: 18),
                          Divider(height: 1, thickness: 1, color: LuxuryTheme.charcoal.withValues(alpha: 0.1)),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: LuxuryTheme.paleTaupe.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: LuxuryTheme.charcoal.withValues(alpha: 0.1),
                                    width: 1.0,
                                  ),
                                ),
                                child: Text(
                                  "Kode Poli: #${poli.id}",
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: LuxuryTheme.charcoal,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_isAdmin)
                    Row(
                      children: [
                        Expanded(child: _tombolUbah(poli)),
                        const SizedBox(width: 14),
                        Expanded(child: _tombolHapus(poli)),
                      ],
                    )
                  else
                    AnimatedPressable(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        Navigator.push(
                          context,
                          SmoothPageRoute(page: const AntrianForm()),
                        );
                      },
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: LuxuryTheme.charcoal,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.confirmation_number_outlined, color: LuxuryTheme.pureWhite, size: 18),
                            SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                "AMBIL ANTRIAN DI POLI INI",
                                style: TextStyle(
                                  color: LuxuryTheme.pureWhite,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _tombolUbah(Poli poli) {
    return AnimatedPressable(
      borderRadius: BorderRadius.circular(14),
      onTap: () async {
        await Navigator.push(
          context,
          SmoothPageRoute(page: PoliUpdateForm(poli: poli)),
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

  Widget _tombolHapus(Poli poli) {
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
              "Yakin ingin menghapus data poli \"${poli.namaPoli}\"?",
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
                    await PoliService().hapus(poli);
                    if (!mounted) return;
                    Navigator.pushAndRemoveUntil(
                      context,
                      SmoothPageRoute(page: const PoliPage()),
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
