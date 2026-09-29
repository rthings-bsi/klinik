import 'package:flutter/material.dart';
import '../helpers/luxury_theme.dart';
import '../model/pasien.dart';
import '../service/pasien_service.dart';
import '../widget/animated_pressable.dart';
import '../widget/aesthetic_background.dart';

class PasienUpdateForm extends StatefulWidget {
  final Pasien pasien;

  const PasienUpdateForm({super.key, required this.pasien});

  @override
  State<PasienUpdateForm> createState() => _PasienUpdateFormState();
}

class _PasienUpdateFormState extends State<PasienUpdateForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomorRmCtrl;
  late TextEditingController _namaCtrl;
  late TextEditingController _tanggalLahirCtrl;
  late TextEditingController _nomorTeleponCtrl;
  late TextEditingController _alamatCtrl;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nomorRmCtrl = TextEditingController(text: widget.pasien.nomorRm);
    _namaCtrl = TextEditingController(text: widget.pasien.nama);
    _tanggalLahirCtrl = TextEditingController(text: widget.pasien.tanggalLahir);
    _nomorTeleponCtrl = TextEditingController(text: widget.pasien.nomorTelepon);
    _alamatCtrl = TextEditingController(text: widget.pasien.alamat);
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
      initialDate: DateTime.tryParse(widget.pasien.tanggalLahir) ?? DateTime(2000, 1, 1),
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
        title: const Text("Ubah Pasien"),
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
                    "Perbarui Data Pasien",
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
                    "Ubah informasi identitas atau kontak pasien.",
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
                  _tombolSimpanPerubahan(),
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
      decoration: const InputDecoration(
        labelText: "Nomor Rekam Medis (RM)",
        prefixIcon: Icon(Icons.assignment_outlined, color: LuxuryTheme.charcoal, size: 20),
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
        labelText: "Nomor Telepon",
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
        labelText: "Alamat",
        prefixIcon: Icon(Icons.home_outlined, color: LuxuryTheme.charcoal, size: 20),
      ),
      validator: (val) => val == null || val.trim().isEmpty ? "Alamat wajib diisi" : null,
    );
  }

  Widget _tombolSimpanPerubahan() {
    return AnimatedPressable(
      borderRadius: BorderRadius.zero,
      onTap: _isLoading
          ? null
          : () async {
              if (_formKey.currentState!.validate()) {
                setState(() => _isLoading = true);

                try {
                  final updated = Pasien(
                    id: widget.pasien.id,
                    nomorRm: _nomorRmCtrl.text.trim(),
                    nama: _namaCtrl.text.trim(),
                    tanggalLahir: _tanggalLahirCtrl.text.trim(),
                    nomorTelepon: _nomorTeleponCtrl.text.trim(),
                    alamat: _alamatCtrl.text.trim(),
                  );

                  await PasienService().ubah(updated, widget.pasien.id ?? '');

                  if (!mounted) return;
                  Navigator.pop(context, true);
                } catch (e) {
                  setState(() => _isLoading = false);
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: LuxuryTheme.crimson,
                      content: Text("Gagal memperbarui data pasien: $e"),
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
                "SIMPAN PERUBAHAN",
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
