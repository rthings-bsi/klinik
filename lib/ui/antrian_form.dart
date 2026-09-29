import 'package:flutter/material.dart';
import '../helpers/luxury_theme.dart';
import '../helpers/user_info.dart';
import '../model/antrian.dart';
import '../model/pasien.dart';
import '../model/poli.dart';
import '../service/antrian_service.dart';
import '../service/pasien_service.dart';
import '../service/poli_service.dart';
import '../widget/animated_pressable.dart';
import '../widget/smooth_page_route.dart';
import '../widget/staggered_entrance.dart';
import '../widget/aesthetic_background.dart';
import 'antrian_detail.dart';

class AntrianForm extends StatefulWidget {
  const AntrianForm({super.key});

  @override
  State<AntrianForm> createState() => _AntrianFormState();
}

class _AntrianFormState extends State<AntrianForm> {
  final _formKey = GlobalKey<FormState>();
  final _namaPasienCtrl = TextEditingController();
  final _nomorRmCtrl = TextEditingController();
  final _nomorTeleponCtrl = TextEditingController();
  final _tanggalCtrl = TextEditingController();
  final _keluhanCtrl = TextEditingController();

  List<Poli> _poliList = [];
  Poli? _selectedPoli;
  bool _isLoadingPoli = true;
  bool _isSubmitting = false;
  String _estimatedNomor = "";

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _tanggalCtrl.text =
        "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
    _loadInitialData();
  }

  @override
  void dispose() {
    _namaPasienCtrl.dispose();
    _nomorRmCtrl.dispose();
    _nomorTeleponCtrl.dispose();
    _tanggalCtrl.dispose();
    _keluhanCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    final isAdmin = await UserInfo().isAdmin();
    if (!isAdmin) {
      final nama = await UserInfo().getNama();
      final username = await UserInfo().getUsername();
      final phone = await UserInfo().getNomorTelepon();
      final rm = await UserInfo().getNomorRm();

      if (nama != null && nama.isNotEmpty) {
        _namaPasienCtrl.text = nama;
      } else if (username != null && username.isNotEmpty) {
        _namaPasienCtrl.text = username;
      }

      if (phone != null && phone.isNotEmpty) {
        _nomorTeleponCtrl.text = phone;
      }

      if (rm != null && rm.isNotEmpty && rm != "RM-BARU") {
        _nomorRmCtrl.text = rm;
      } else {
        final autoRm = await PasienService().generateNomorRm();
        _nomorRmCtrl.text = autoRm;
        await UserInfo().setNomorRm(autoRm);
      }
    } else {
      if (_nomorRmCtrl.text.isEmpty) {
        final autoRm = await PasienService().generateNomorRm();
        _nomorRmCtrl.text = autoRm;
      }
    }

    try {
      final polis = await PoliService().listData();
      if (mounted) {
        setState(() {
          _poliList = polis;
          _isLoadingPoli = false;
          if (polis.isNotEmpty) {
            _selectedPoli = polis.first;
            _updateEstimatedNumber();
          }
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingPoli = false);
      }
    }
  }

  Future<void> _updateEstimatedNumber() async {
    if (_selectedPoli?.id != null && _tanggalCtrl.text.isNotEmpty) {
      final nextNumber = await AntrianService().generateNomorAntrian(
        _selectedPoli!.id!,
        _tanggalCtrl.text.trim(),
      );
      if (mounted) {
        setState(() => _estimatedNomor = nextNumber);
      }
    }
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: LuxuryTheme.charcoal,
              onPrimary: LuxuryTheme.pureWhite,
              surface: LuxuryTheme.alabaster,
              onSurface: LuxuryTheme.charcoal,
            ),
            datePickerTheme: DatePickerThemeData(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              headerBackgroundColor: LuxuryTheme.charcoal,
              headerForegroundColor: LuxuryTheme.pureWhite,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _tanggalCtrl.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
      _updateEstimatedNumber();
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPoli == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: LuxuryTheme.crimson,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: const Text("Silakan pilih poliklinik tujuan."),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final now = TimeOfDay.now();
      final timeStr =
          "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

      String finalRm = _nomorRmCtrl.text.trim();
      if (finalRm.isEmpty || finalRm == "RM-BARU") {
        finalRm = await PasienService().generateNomorRm();
        _nomorRmCtrl.text = finalRm;
      }

      // Verify and register patient in directory
      final pasienService = PasienService();
      final allPasien = await pasienService.listData();
      final exists = allPasien.any((p) =>
          (p.nomorRm.isNotEmpty && p.nomorRm.toLowerCase() == finalRm.toLowerCase()) ||
          (p.nama.toLowerCase().trim() == _namaPasienCtrl.text.toLowerCase().trim() &&
              p.nomorTelepon.trim() == _nomorTeleponCtrl.text.trim()));

      if (!exists) {
        final newPasien = Pasien(
          nomorRm: finalRm,
          nama: _namaPasienCtrl.text.trim(),
          tanggalLahir: DateTime.now().toIso8601String().substring(0, 10),
          nomorTelepon: _nomorTeleponCtrl.text.trim(),
          alamat: "-",
        );
        await pasienService.simpan(newPasien);

        final currentRm = await UserInfo().getNomorRm();
        if (currentRm == null || currentRm.isEmpty || currentRm == "RM-BARU") {
          await UserInfo().setNomorRm(finalRm);
        }
      }

      final antrianBaru = Antrian(
        nomorAntrian: "", // will be generated by service
        idPoli: _selectedPoli!.id ?? "1",
        namaPoli: _selectedPoli!.namaPoli,
        namaPasien: _namaPasienCtrl.text.trim(),
        nomorRm: finalRm,
        nomorTelepon: _nomorTeleponCtrl.text.trim(),
        tanggal: _tanggalCtrl.text.trim(),
        waktu: timeStr,
        keluhan: _keluhanCtrl.text.trim(),
        status: "Menunggu",
      );

      final saved = await AntrianService().simpan(antrianBaru);

      if (!mounted) return;
      setState(() => _isSubmitting = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: LuxuryTheme.forestGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Text("Nomor antrian berhasil diambil: ${saved.nomorAntrian}"),
        ),
      );

      // Navigate to digital ticket detail
      Navigator.pushReplacement(
        context,
        SmoothPageRoute(page: AntrianDetail(antrian: saved)),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: LuxuryTheme.crimson,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Text("Gagal mengambil antrian: $e"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LuxuryTheme.alabaster,
      appBar: AppBar(
        title: const Text("Ambil Antrian Berobat"),
      ),
      body: AestheticBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Ticket Preview Banner (Charcoal Editorial)
                if (_estimatedNomor.isNotEmpty)
                  StaggeredEntrance(
                    index: 0,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 18),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: LuxuryTheme.charcoal,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: LuxuryTheme.charcoal.withValues(alpha: 0.16),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: LuxuryTheme.pureWhite,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: LuxuryTheme.metallicGold,
                                width: 1.5,
                              ),
                            ),
                            child: Text(
                              _estimatedNomor,
                              style: const TextStyle(
                                fontFamily: 'serif',
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: LuxuryTheme.charcoal,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 10,
                                      height: 1.0,
                                      color: LuxuryTheme.metallicGold,
                                    ),
                                    const SizedBox(width: 6),
                                    const Text(
                                      "Perkiraan Nomor Antrian",
                                      style: TextStyle(
                                        color: LuxuryTheme.paleTaupe,
                                        fontSize: 11,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _selectedPoli?.namaPoli ?? "Poliklinik",
                                  style: const TextStyle(
                                    fontFamily: 'serif',
                                    color: LuxuryTheme.pureWhite,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Form Container
                StaggeredEntrance(
                  index: 1,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: LuxuryTheme.pureWhite,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: LuxuryTheme.charcoal.withValues(alpha: 0.08),
                        width: 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: LuxuryTheme.charcoal.withValues(alpha: 0.04),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                        BoxShadow(
                          color: LuxuryTheme.charcoal.withValues(alpha: 0.02),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            "Pilih Poliklinik & Jadwal",
                            style: TextStyle(
                              fontFamily: 'serif',
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: LuxuryTheme.charcoal,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "Tentukan poli tujuan dan tanggal kunjungan periksa.",
                            style: TextStyle(
                              fontSize: 12,
                              color: LuxuryTheme.warmGrey,
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Poli Dropdown
                          _isLoadingPoli
                              ? const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(12),
                                    child: CircularProgressIndicator(color: LuxuryTheme.charcoal, strokeWidth: 2),
                                  ),
                                )
                              : DropdownButtonFormField<Poli>(
                                  value: _selectedPoli,
                                  dropdownColor: LuxuryTheme.pureWhite,
                                  borderRadius: BorderRadius.circular(16),
                                  decoration: _inputDecoration(
                                    label: "Poliklinik Spesialis",
                                    icon: Icons.meeting_room_outlined,
                                  ),
                                  items: _poliList.map((p) {
                                    return DropdownMenuItem<Poli>(
                                      value: p,
                                      child: Text(
                                        p.namaPoli,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: LuxuryTheme.charcoal,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    setState(() => _selectedPoli = val);
                                    _updateEstimatedNumber();
                                  },
                                  validator: (val) => val == null ? "Pilih poliklinik" : null,
                                ),

                          const SizedBox(height: 18),

                          // Date field
                          TextFormField(
                            controller: _tanggalCtrl,
                            readOnly: true,
                            onTap: _selectDate,
                            style: const TextStyle(color: LuxuryTheme.charcoal, fontSize: 14.5),
                            decoration: _inputDecoration(
                              label: "Tanggal Kunjungan",
                              icon: Icons.calendar_today_outlined,
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.date_range_outlined,
                                    color: LuxuryTheme.charcoal, size: 20),
                                onPressed: _selectDate,
                              ),
                            ),
                            validator: (val) =>
                                val == null || val.trim().isEmpty ? "Tanggal wajib diisi" : null,
                          ),

                          const SizedBox(height: 22),
                          Divider(height: 1, thickness: 1, color: LuxuryTheme.charcoal.withValues(alpha: 0.08)),
                          const SizedBox(height: 20),

                          const Text(
                            "Informasi Pasien",
                            style: TextStyle(
                              fontFamily: 'serif',
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: LuxuryTheme.charcoal,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "Data identitas pasien yang akan melakukan konsultasi medis.",
                            style: TextStyle(
                              fontSize: 12,
                              color: LuxuryTheme.warmGrey,
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Nama Pasien
                          TextFormField(
                            controller: _namaPasienCtrl,
                            style: const TextStyle(color: LuxuryTheme.charcoal, fontSize: 14.5),
                            decoration: _inputDecoration(
                              label: "Nama Lengkap Pasien",
                              hint: "Contoh: Budi Santoso",
                              icon: Icons.person_outline_rounded,
                            ),
                            validator: (val) =>
                                val == null || val.trim().isEmpty ? "Nama pasien wajib diisi" : null,
                          ),
                          const SizedBox(height: 18),

                          // Nomor RM
                          TextFormField(
                            controller: _nomorRmCtrl,
                            readOnly: true,
                            style: const TextStyle(
                              color: LuxuryTheme.charcoal,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: _inputDecoration(
                              label: "Nomor Rekam Medis (No. RM)",
                              hint: "Otomatis di-generate sistem",
                              icon: Icons.assignment_outlined,
                            ),
                          ),
                          const SizedBox(height: 18),

                          // Nomor Telepon
                          TextFormField(
                            controller: _nomorTeleponCtrl,
                            keyboardType: TextInputType.phone,
                            style: const TextStyle(color: LuxuryTheme.charcoal, fontSize: 14.5),
                            decoration: _inputDecoration(
                              label: "Nomor Telepon",
                              hint: "Contoh: 081234567890",
                              icon: Icons.phone_outlined,
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return "Nomor telepon wajib diisi";
                              }
                              if (val.trim().length < 8) {
                                return "Nomor telepon minimal 8 digit";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 18),

                          // Keluhan
                          TextFormField(
                            controller: _keluhanCtrl,
                            maxLines: 3,
                            style: const TextStyle(color: LuxuryTheme.charcoal, fontSize: 14.5),
                            decoration: _inputDecoration(
                              label: "Keluhan / Gejala",
                              hint: "Jelaskan secara singkat gejala yang dialami...",
                              icon: Icons.chat_bubble_outline_rounded,
                              alignLabelWithHint: true,
                            ),
                            validator: (val) =>
                                val == null || val.trim().isEmpty ? "Keluhan wajib diisi" : null,
                          ),

                          const SizedBox(height: 30),

                          // Submit Button
                          AnimatedPressable(
                            borderRadius: BorderRadius.circular(14),
                            onTap: _isSubmitting ? null : _handleSubmit,
                            child: Container(
                              height: 52,
                              decoration: BoxDecoration(
                                color: LuxuryTheme.charcoal,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: LuxuryTheme.charcoal.withValues(alpha: 0.18),
                                    blurRadius: 14,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: _isSubmitting
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: LuxuryTheme.pureWhite,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.confirmation_number_outlined,
                                            color: LuxuryTheme.pureWhite, size: 18),
                                        SizedBox(width: 8),
                                        Text(
                                          "KONFIRMASI & AMBIL ANTRIAN",
                                          style: TextStyle(
                                            color: LuxuryTheme.pureWhite,
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 1.6,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    String? hint,
    required IconData icon,
    Widget? suffixIcon,
    bool alignLabelWithHint = false,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: LuxuryTheme.charcoal, size: 20),
      suffixIcon: suffixIcon,
      alignLabelWithHint: alignLabelWithHint,
      filled: true,
      fillColor: LuxuryTheme.alabaster.withValues(alpha: 0.7),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: LuxuryTheme.charcoal.withValues(alpha: 0.1), width: 1.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: LuxuryTheme.charcoal.withValues(alpha: 0.12), width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: LuxuryTheme.charcoal, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: LuxuryTheme.crimson, width: 1.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: LuxuryTheme.crimson, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}
