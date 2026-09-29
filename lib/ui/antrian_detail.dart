import 'package:flutter/material.dart';
import '../helpers/luxury_theme.dart';
import '../helpers/user_info.dart';
import '../model/antrian.dart';
import '../service/antrian_service.dart';
import '../widget/animated_pressable.dart';
import '../widget/staggered_entrance.dart';
import '../widget/aesthetic_background.dart';

class AntrianDetail extends StatefulWidget {
  final Antrian antrian;

  const AntrianDetail({super.key, required this.antrian});

  @override
  State<AntrianDetail> createState() => _AntrianDetailState();
}

class _AntrianDetailState extends State<AntrianDetail> {
  late Antrian _currentAntrian;
  bool _isUpdating = false;
  bool _isAdmin = false;
  String _currentUser = "";
  String _currentNama = "";

  @override
  void initState() {
    super.initState();
    _currentAntrian = widget.antrian;
    _checkRole();
    _refreshDetail();
  }

  Future<void> _checkRole() async {
    final isAdmin = await UserInfo().isAdmin();
    final username = (await UserInfo().getUsername() ?? "").toLowerCase().trim();
    final nama = (await UserInfo().getNama() ?? "").toLowerCase().trim();
    if (mounted) {
      setState(() {
        _isAdmin = isAdmin;
        _currentUser = username;
        _currentNama = nama;
      });
    }
  }

  bool get _isMyTicket {
    final pName = _currentAntrian.namaPasien.toLowerCase().trim();
    return (_currentUser.isNotEmpty && pName == _currentUser) ||
        (_currentNama.isNotEmpty && pName == _currentNama);
  }

  Future<void> _refreshDetail() async {
    if (_currentAntrian.id == null) return;
    try {
      final updated = await AntrianService().getById(_currentAntrian.id!);
      if (mounted) {
        setState(() => _currentAntrian = updated);
      }
    } catch (_) {}
  }

  Future<void> _updateStatus(String newStatus) async {
    if (_currentAntrian.id == null) return;
    setState(() => _isUpdating = true);
    try {
      final updated = await AntrianService().ubahStatus(_currentAntrian.id!, newStatus);
      if (mounted) {
        setState(() {
          _currentAntrian = updated;
          _isUpdating = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: LuxuryTheme.forestGreen,
            content: Text("Status antrian diperbarui menjadi: $newStatus"),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUpdating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: LuxuryTheme.crimson,
            content: Text("Gagal memperbarui status: $e"),
          ),
        );
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'menunggu':
        return const Color(0xFFB8860B); // Amber / Gold
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
    final statusColor = _getStatusColor(_currentAntrian.status);

    return Scaffold(
      backgroundColor: LuxuryTheme.alabaster,
      appBar: AppBar(
        title: const Text("Tiket Antrian Digital"),
      ),
      body: AestheticBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Digital Ticket Card (Editorial Architectural)
                StaggeredEntrance(
                  index: 0,
                  child: Container(
                    clipBehavior: Clip.antiAlias,
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
                      children: [
                        // Ticket Header (Charcoal Luxury)
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: const BoxDecoration(
                            color: LuxuryTheme.charcoal,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: LuxuryTheme.alabaster,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: LuxuryTheme.metallicGold,
                                    width: 1.0,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
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
                                    const Text(
                                      "Klinik Pratama Medika",
                                      style: TextStyle(
                                        fontFamily: 'serif',
                                        color: LuxuryTheme.pureWhite,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        letterSpacing: -0.2,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      "Sistem Antrian Rawat Jalan",
                                      style: TextStyle(
                                        color: LuxuryTheme.pureWhite.withValues(alpha: 0.75),
                                        fontSize: 11.5,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Queue Number Section
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 12,
                                    height: 1.0,
                                    color: LuxuryTheme.metallicGold,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    "NOMOR ANTRIAN ANDA",
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700,
                                      color: LuxuryTheme.warmGrey,
                                      letterSpacing: 2.0,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    width: 12,
                                    height: 1.0,
                                    color: LuxuryTheme.metallicGold,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                _currentAntrian.nomorAntrian,
                                style: const TextStyle(
                                  fontFamily: 'serif',
                                  fontSize: 54,
                                  fontWeight: FontWeight.bold,
                                  color: LuxuryTheme.charcoal,
                                  letterSpacing: -1.5,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                                decoration: BoxDecoration(
                                  color: LuxuryTheme.paleTaupe.withValues(alpha: 0.7),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: LuxuryTheme.charcoal.withValues(alpha: 0.08),
                                    width: 1.0,
                                  ),
                                ),
                                child: Text(
                                  _currentAntrian.namaPoli,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: LuxuryTheme.charcoal,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: statusColor.withValues(alpha: 0.5),
                                    width: 1.0,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      color: statusColor,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      "Status: ${_currentAntrian.status}",
                                      style: TextStyle(
                                        color: statusColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Perforated Line Effect (Architectural Rectangular Cutouts)
                        Row(
                          children: [
                            Container(
                              width: 12,
                              height: 24,
                              decoration: BoxDecoration(
                                color: LuxuryTheme.alabaster,
                                border: Border(
                                  top: BorderSide(color: LuxuryTheme.charcoal.withValues(alpha: 0.16)),
                                  bottom: BorderSide(color: LuxuryTheme.charcoal.withValues(alpha: 0.16)),
                                  right: BorderSide(color: LuxuryTheme.charcoal.withValues(alpha: 0.16)),
                                ),
                              ),
                            ),
                            Expanded(
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: List.generate(
                                      (constraints.constrainWidth() / 12).floor(),
                                      (index) => Container(
                                        width: 6,
                                        height: 1.0,
                                        color: LuxuryTheme.charcoal.withValues(alpha: 0.18),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            Container(
                              width: 12,
                              height: 24,
                              decoration: BoxDecoration(
                                color: LuxuryTheme.alabaster,
                                border: Border(
                                  top: BorderSide(color: LuxuryTheme.charcoal.withValues(alpha: 0.16)),
                                  bottom: BorderSide(color: LuxuryTheme.charcoal.withValues(alpha: 0.16)),
                                  left: BorderSide(color: LuxuryTheme.charcoal.withValues(alpha: 0.16)),
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Ticket Details Section
                        Padding(
                          padding: const EdgeInsets.all(22),
                          child: Column(
                            children: [
                              _ticketRow("Nama Pasien", _currentAntrian.namaPasien),
                              const SizedBox(height: 12),
                              _ticketRow("Nomor Rekam Medis", _currentAntrian.nomorRm),
                              const SizedBox(height: 12),
                              _ticketRow("Nomor Telepon", _currentAntrian.nomorTelepon),
                              const SizedBox(height: 12),
                              _ticketRow("Tanggal Kunjungan", _currentAntrian.tanggal),
                              const SizedBox(height: 12),
                              _ticketRow("Waktu Pendaftaran", "${_currentAntrian.waktu} WIB"),
                              const SizedBox(height: 12),
                              _ticketRow("Keluhan / Gejala", _currentAntrian.keluhan),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Administrative Controls or Patient Information
                if (_isAdmin) ...[
                  // Status Change Action Bar for Admin/Staff
                  StaggeredEntrance(
                    index: 1,
                    child: Container(
                      padding: const EdgeInsets.all(20),
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
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Kelola Status Antrian (Admin)",
                            style: TextStyle(
                              fontFamily: 'serif',
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: LuxuryTheme.charcoal,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "Perbarui status panggilan antrian pasien secara berurutan.",
                            style: TextStyle(
                              fontSize: 11.5,
                              color: LuxuryTheme.warmGrey,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _statusButton(
                                label: "Panggil",
                                targetStatus: "Dipanggil",
                                color: LuxuryTheme.charcoal,
                                icon: Icons.campaign_rounded,
                              ),
                              _statusButton(
                                label: "Selesai",
                                targetStatus: "Selesai",
                                color: LuxuryTheme.forestGreen,
                                icon: Icons.check_circle_outline,
                              ),
                              _statusButton(
                                label: "Tunggu",
                                targetStatus: "Menunggu",
                                color: const Color(0xFFB8860B),
                                icon: Icons.schedule_rounded,
                              ),
                              _statusButton(
                                label: "Batalkan",
                                targetStatus: "Batal",
                                color: LuxuryTheme.crimson,
                                icon: Icons.cancel_outlined,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Delete button for Admin
                  StaggeredEntrance(
                    index: 2,
                    child: AnimatedPressable(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        final rootNav = Navigator.of(context);
                        showDialog(
                          context: context,
                          builder: (dCtx) => AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            title: const Text(
                              "Hapus Antrian",
                              style: TextStyle(
                                fontFamily: 'serif',
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.3,
                              ),
                            ),
                            content: Text(
                              "Hapus tiket antrian nomor ${_currentAntrian.nomorAntrian} atas nama ${_currentAntrian.namaPasien}?",
                              style: const TextStyle(color: LuxuryTheme.warmGrey, fontSize: 13.5),
                            ),
                            actions: [
                              TextButton(
                                style: TextButton.styleFrom(
                                  foregroundColor: LuxuryTheme.charcoal,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                onPressed: () => Navigator.pop(dCtx),
                                child: const Text("BATAL"),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: LuxuryTheme.crimson,
                                  foregroundColor: LuxuryTheme.pureWhite,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                onPressed: () async {
                                  Navigator.pop(dCtx);
                                  await AntrianService().hapus(_currentAntrian);
                                  if (!mounted) return;
                                  rootNav.pop(true);
                                },
                                child: const Text("HAPUS"),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Container(
                        height: 48,
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
                              "Hapus Tiket Antrian Ini",
                              style: TextStyle(
                                color: LuxuryTheme.crimson,
                                fontWeight: FontWeight.w600,
                                fontSize: 12.5,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  // Patient Notification & Self-Service
                  if (_currentAntrian.status.toLowerCase() == 'dipanggil')
                    StaggeredEntrance(
                      index: 1,
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: LuxuryTheme.charcoal,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: LuxuryTheme.metallicGold,
                            width: 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.campaign_rounded, color: LuxuryTheme.metallicGold, size: 26),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Nomor Antrian Sedang Dipanggil!",
                                    style: TextStyle(
                                      fontFamily: 'serif',
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w600,
                                      color: LuxuryTheme.pureWhite,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    "Silakan segera menuju ke ${_currentAntrian.namaPoli} untuk pemeriksaan.",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: LuxuryTheme.pureWhite.withValues(alpha: 0.8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  if (_currentAntrian.status.toLowerCase() == 'selesai')
                    StaggeredEntrance(
                      index: 1,
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: LuxuryTheme.pureWhite,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: LuxuryTheme.forestGreen,
                            width: 1.0,
                          ),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.check_circle_outline, color: LuxuryTheme.forestGreen, size: 24),
                            SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                "Pemeriksaan kesehatan telah selesai. Semoga lekas sembuh.",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: LuxuryTheme.charcoal,
                                  letterSpacing: 0.1,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Patient can cancel their own waiting queue ticket
                  if (_isMyTicket && _currentAntrian.status.toLowerCase() == 'menunggu')
                    StaggeredEntrance(
                      index: 1,
                      child: AnimatedPressable(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (dCtx) => AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              title: const Text(
                                "Batalkan Antrian?",
                                style: TextStyle(
                                  fontFamily: 'serif',
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              content: const Text(
                                "Apakah Anda yakin ingin membatalkan antrian periksa Anda?",
                                style: TextStyle(color: LuxuryTheme.warmGrey, fontSize: 13.5),
                              ),
                              actions: [
                                TextButton(
                                  style: TextButton.styleFrom(
                                    foregroundColor: LuxuryTheme.charcoal,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  onPressed: () => Navigator.pop(dCtx),
                                  child: const Text("TIDAK"),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: LuxuryTheme.crimson,
                                    foregroundColor: LuxuryTheme.pureWhite,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  onPressed: () {
                                    Navigator.pop(dCtx);
                                    _updateStatus("Batal");
                                  },
                                  child: const Text("YA, BATALKAN"),
                                ),
                              ],
                            ),
                          );
                        },
                        child: Container(
                          height: 48,
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
                              Icon(Icons.cancel_outlined, size: 17, color: LuxuryTheme.crimson),
                              SizedBox(width: 8),
                              Text(
                                "Batalkan Antrian Saya",
                                style: TextStyle(
                                  color: LuxuryTheme.crimson,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12.5,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _ticketRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11.5,
            color: LuxuryTheme.warmGrey,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: LuxuryTheme.charcoal,
              letterSpacing: -0.2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _statusButton({
    required String label,
    required String targetStatus,
    required Color color,
    required IconData icon,
  }) {
    final isSelected = _currentAntrian.status.toLowerCase() == targetStatus.toLowerCase();

    return AnimatedPressable(
      borderRadius: BorderRadius.circular(10),
      onTap: _isUpdating ? null : () => _updateStatus(targetStatus),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : LuxuryTheme.pureWhite,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? color : color.withValues(alpha: 0.35),
            width: 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected ? LuxuryTheme.pureWhite : color,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? LuxuryTheme.pureWhite : color,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
