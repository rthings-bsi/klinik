import 'package:flutter/material.dart';
import '../helpers/luxury_theme.dart';
import '../model/pasien.dart';
import '../service/pasien_service.dart';
import '../widget/animated_pressable.dart';
import '../widget/smooth_page_route.dart';
import '../widget/aesthetic_background.dart';
import 'pasien_detail.dart';

class PasienForm extends StatefulWidget {
  const PasienForm({super.key});

  @override
  State<PasienForm> createState() => _PasienFormState();
}

class _PasienFormState extends State<PasienForm> {
  final _formKey = GlobalKey<FormState>();
  final _nomorRmCtrl = TextEditingController();
  final _namaCtrl = TextEditingController();
  final _tanggalLahirCtrl = TextEditingController();
  final _nomorTeleponCtrl = TextEditingController();
  final _alamatCtrl = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initNomorRm();
  }

  Future<void> _initNomorRm() async {
    final autoRm = await PasienService().generateNomorRm();
    if (mounted && _nomorRmCtrl.text.isEmpty) {
      setState(() {
        _nomorRmCtrl.text = autoRm;
      });
    }
  }

  @override
  void dispose() {
    _nomorRmCtrl.dispose();
    _namaCtrl.dispose();
    _tanggalLahirCtrl.dispose();
    _nomorTeleponCtrl.dispose();
    _alamatCtrl.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: LuxuryTheme.charcoal,
              onPrimary: LuxuryTheme.pureWhite,
              surface: LuxuryTheme.alabaster,
              onSurface: LuxuryTheme.charcoal,
            ),
            datePickerTheme: const DatePickerThemeData(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
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
        _tanggalLahirCtrl.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LuxuryTheme.alabaster,
      appBar: AppBar(
        title: const Text("Tambah Pasien"),
      ),
      body: AestheticBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: LuxuryTheme.alabaster,
              border: Border.all(
                color: LuxuryTheme.charcoal.withValues(alpha: 0.14),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: LuxuryTheme.charcoal.withValues(alpha: 0.03),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "Formulir Pendaftaran Pasien",
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: LuxuryTheme.charcoal,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Catat data identitas dan nomor rekam medis pasien baru.",
                    style: TextStyle(
                      fontSize: 12.5,
                      color: LuxuryTheme.warmGrey,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Divider(height: 1, thickness: 1, color: LuxuryTheme.charcoal.withValues(alpha: 0.1)),
                  const SizedBox(height: 22),
                  _fieldNomorRm(),
                  const SizedBox(height: 18),
                  _fieldNama(),
                  const SizedBox(height: 18),
                  _fieldTanggalLahir(),
                  const SizedBox(height: 18),
                  _fieldNomorTelepon(),
                  const SizedBox(height: 18),
                  _fieldAlamat(),
                  const SizedBox(height: 30),
                  _tombolSimpan(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _fieldNomorRm() {
    return TextFormField(
      controller: _nomorRmCtrl,
      readOnly: true,
      style: const TextStyle(
        color: LuxuryTheme.charcoal,
        fontSize: 14.5,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        labelText: "Nomor Rekam Medis (RM Otomatis)",
        hintText: "Otomatis di-generate sistem",
        prefixIcon: const Icon(Icons.assignment_outlined, color: LuxuryTheme.charcoal, size: 20),
        suffixIcon: IconButton(
          icon: const Icon(Icons.refresh_rounded, color: LuxuryTheme.charcoal, size: 20),
          tooltip: "Generate Ulang No. RM",
          onPressed: () async {
            final autoRm = await PasienService().generateNomorRm();
            setState(() {
              _nomorRmCtrl.text = autoRm;
            });
          },
        ),
      ),
      validator: (val) => val == null || val.trim().isEmpty ? "Nomor RM wajib diisi" : null,
    );
  }

  Widget _fieldNama() {
    return TextFormField(
      controller: _namaCtrl,
      style: const TextStyle(color: LuxuryTheme.charcoal, fontSize: 14.5),
      decoration: const InputDecoration(
        labelText: "Nama Lengkap Pasien",
        hintText: "Contoh: Siti Aisyah",
        prefixIcon: Icon(Icons.person_outline_rounded, color: LuxuryTheme.charcoal, size: 20),
      ),
      validator: (val) => val == null || val.trim().isEmpty ? "Nama pasien wajib diisi" : null,
    );
  }

  Widget _fieldTanggalLahir() {
    return TextFormField(
      controller: _tanggalLahirCtrl,
      readOnly: true,
      onTap: _selectDate,
      style: const TextStyle(color: LuxuryTheme.charcoal, fontSize: 14.5),
      decoration: InputDecoration(
        labelText: "Tanggal Lahir",
        hintText: "YYYY-MM-DD",
        prefixIcon: const Icon(Icons.calendar_today_outlined, color: LuxuryTheme.charcoal, size: 20),
        suffixIcon: IconButton(
          icon: const Icon(Icons.date_range_outlined, color: LuxuryTheme.charcoal, size: 20),
          onPressed: _selectDate,
        ),
      ),
      validator: (val) => val == null || val.trim().isEmpty ? "Tanggal lahir wajib diisi" : null,
    );
  }

  Widget _fieldNomorTelepon() {
    return TextFormField(
      controller: _nomorTeleponCtrl,
      keyboardType: TextInputType.phone,
      style: const TextStyle(color: LuxuryTheme.charcoal, fontSize: 14.5),
      decoration: const InputDecoration(
        labelText: "Nomor Telepon / WhatsApp",
        hintText: "Contoh: 081234567890",
        prefixIcon: Icon(Icons.phone_outlined, color: LuxuryTheme.charcoal, size: 20),
      ),
      validator: (val) => val == null || val.trim().isEmpty ? "Nomor telepon wajib diisi" : null,
    );
  }

  Widget _fieldAlamat() {
    return TextFormField(
      controller: _alamatCtrl,
      maxLines: 2,
      style: const TextStyle(color: LuxuryTheme.charcoal, fontSize: 14.5),
      decoration: const InputDecoration(
        labelText: "Alamat Tempat Tinggal",
        hintText: "Contoh: Jl. Gajah Mada No. 12, Pontianak",
        prefixIcon: Icon(Icons.home_outlined, color: LuxuryTheme.charcoal, size: 20),
      ),
      validator: (val) => val == null || val.trim().isEmpty ? "Alamat wajib diisi" : null,
    );
  }

  Widget _tombolSimpan() {
    return AnimatedPressable(
      borderRadius: BorderRadius.zero,
      onTap: _isLoading
          ? null
          : () async {
              if (_formKey.currentState!.validate()) {
                setState(() => _isLoading = true);

                try {
                  final pasien = Pasien(
                    nomorRm: _nomorRmCtrl.text.trim(),
                    nama: _namaCtrl.text.trim(),
                    tanggalLahir: _tanggalLahirCtrl.text.trim(),
                    nomorTelepon: _nomorTeleponCtrl.text.trim(),
                    alamat: _alamatCtrl.text.trim(),
                  );

                  final saved = await PasienService().simpan(pasien);

                  if (!mounted) return;
                  Navigator.pushReplacement(
                    context,
                    SmoothPageRoute(page: PasienDetail(pasien: saved)),
                  );
                } catch (e) {
                  setState(() => _isLoading = false);
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: LuxuryTheme.crimson,
                      content: Text("Gagal menyimpan data pasien: $e"),
                    ),
                  );
                }
              }
            },
      child: Container(
        height: 50,
        decoration: const BoxDecoration(
          color: LuxuryTheme.charcoal,
        ),
        alignment: Alignment.center,
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(color: LuxuryTheme.pureWhite, strokeWidth: 2),
              )
            : const Text(
                "SIMPAN DATA",
                style: TextStyle(
                  color: LuxuryTheme.pureWhite,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.8,
                ),
              ),
      ),
    );
  }
}
