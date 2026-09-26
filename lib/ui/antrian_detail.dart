import 'package:flutter/material.dart';
import '../helpers/user_info.dart';
import '../model/antrian.dart';
import '../service/antrian_service.dart';
import '../widget/animated_pressable.dart';
import '../widget/staggered_entrance.dart';

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
            backgroundColor: const Color(0xFF34C759),
            content: Text("Status antrian diperbarui menjadi: $newStatus"),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUpdating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFFFF3B30),
            content: Text("Gagal memperbarui status: $e"),
          ),
        );
      }
    }
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
    final statusColor = _getStatusColor(_currentAntrian.status);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        title: const Text("Tiket Antrian Digital"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Digital Ticket Card
              StaggeredEntrance(
                index: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFE5E5EA), width: 0.8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Ticket Header
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: const BoxDecoration(
                          color: Color(0xFF0F766E),
                          borderRadius: BorderRadius.vertical(top: Radius.circular(23)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.asset(
                                  'assets/images/logo.png',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    "Klinik Pratama Sehat",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    "Sistem Antrian Rawat Jalan",
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                      letterSpacing: -0.2,
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
                            Text(
                              "NOMOR ANTRIAN ANDA",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF8E8E93),
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _currentAntrian.nomorAntrian,
                              style: const TextStyle(
                                fontSize: 52,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F766E),
                                letterSpacing: -1.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F766E).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                _currentAntrian.namaPoli,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F766E),
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.circle, color: statusColor, size: 8),
                                  const SizedBox(width: 6),
                                  Text(
                                    "Status: ${_currentAntrian.status}",
                                    style: TextStyle(
                                      color: statusColor,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Perforated Line Effect
                      Row(
                        children: [
                          Container(
                            width: 14,
                            height: 28,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF2F2F7),
                              borderRadius: BorderRadius.horizontal(right: Radius.circular(14)),
                            ),
                          ),
                          Expanded(
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: List.generate(
                                    (constraints.constrainWidth() / 10).floor(),
                                    (index) => Container(
                                      width: 5,
                                      height: 1.2,
                                      color: const Color(0xFFE5E5EA),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          Container(
                            width: 14,
                            height: 28,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF2F2F7),
                              borderRadius: BorderRadius.horizontal(left: Radius.circular(14)),
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
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
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
                        const Text(
                          "Kelola Status Antrian (Admin)",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1C1C1E),
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _statusButton(
                              label: "Panggil",
                              targetStatus: "Dipanggil",
                              color: const Color(0xFF007AFF),
                              icon: Icons.campaign_rounded,
                            ),
                            _statusButton(
                              label: "Selesai",
                              targetStatus: "Selesai",
                              color: const Color(0xFF34C759),
                              icon: Icons.check_circle_rounded,
                            ),
                            _statusButton(
                              label: "Tunggu",
                              targetStatus: "Menunggu",
                              color: const Color(0xFFFF9500),
                              icon: Icons.schedule_rounded,
                            ),
                            _statusButton(
                              label: "Batalkan",
                              targetStatus: "Batal",
                              color: const Color(0xFFFF3B30),
                              icon: Icons.cancel_rounded,
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
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFFF3B30),
                      side: const BorderSide(color: Color(0xFFFF3B30), width: 1),
                      minimumSize: const Size(double.infinity, 46),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () {
                      final rootNav = Navigator.of(context);
                      showDialog(
                        context: context,
                        builder: (dCtx) => AlertDialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          title: const Text(
                            "Hapus Antrian",
                            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: -0.4),
                          ),
                          content: Text(
                            "Hapus tiket antrian nomor ${_currentAntrian.nomorAntrian} atas nama ${_currentAntrian.namaPasien}?",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(dCtx),
                              child: const Text("Batal", style: TextStyle(color: Color(0xFF8E8E93))),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF3B30),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: () async {
                                Navigator.pop(dCtx);
                                await AntrianService().hapus(_currentAntrian);
                                if (!mounted) return;
                                rootNav.pop(true);
                              },
                              child: const Text("Hapus"),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.delete_outline_rounded, size: 18),
                        SizedBox(width: 6),
                        Text("Hapus Tiket Antrian Ini"),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                // Patient Notification & Self-Service
                if (_currentAntrian.status.toLowerCase() == 'dipanggil')
                  StaggeredEntrance(
                    index: 1,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF007AFF).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF007AFF).withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.campaign_rounded, color: Color(0xFF007AFF), size: 28),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Nomor Antrian Sedang Dipanggil!",
                                  style: TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF007AFF),
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  "Silakan segera menuju ke ${_currentAntrian.namaPoli} untuk pemeriksaan.",
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    color: Color(0xFF1C1C1E),
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
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF34C759).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF34C759).withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.check_circle_rounded, color: Color(0xFF34C759), size: 28),
                          SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              "Pemeriksaan kesehatan telah selesai. Semoga lekas sembuh.",
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1C1C1E),
                                letterSpacing: -0.2,
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
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFFF3B30),
                        side: const BorderSide(color: Color(0xFFFF3B30), width: 1),
                        minimumSize: const Size(double.infinity, 46),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (dCtx) => AlertDialog(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                            title: const Text(
                              "Batalkan Antrian?",
                              style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: -0.4),
                            ),
                            content: const Text(
                              "Apakah Anda yakin ingin membatalkan antrian periksa Anda?",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(dCtx),
                                child: const Text("Tidak", style: TextStyle(color: Color(0xFF8E8E93))),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFF3B30),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                                onPressed: () {
                                  Navigator.pop(dCtx);
                                  _updateStatus("Batal");
                                },
                                child: const Text("Ya, Batalkan"),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.cancel_outlined, size: 18),
                          SizedBox(width: 6),
                          Text("Batalkan Antrian Saya"),
                        ],
                      ),
                    ),
                  ),
              ],
            ],
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
            fontSize: 13,
            color: Color(0xFF8E8E93),
            letterSpacing: -0.2,
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
              color: Color(0xFF1C1C1E),
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : color,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : color,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
