import 'package:flutter/material.dart';
import '../helpers/luxury_theme.dart';
import '../model/pegawai.dart';
import '../service/pegawai_service.dart';
import '../widget/animated_pressable.dart';
import '../widget/aesthetic_background.dart';

class PegawaiUpdateForm extends StatefulWidget {
  final Pegawai pegawai;

  const PegawaiUpdateForm({super.key, required this.pegawai});

  @override
  State<PegawaiUpdateForm> createState() => _PegawaiUpdateFormState();
}

class _PegawaiUpdateFormState extends State<PegawaiUpdateForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nipCtrl;
  late TextEditingController _namaCtrl;
  late TextEditingController _tanggalLahirCtrl;
  late TextEditingController _nomorTeleponCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _passwordCtrl;

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _nipCtrl = TextEditingController(text: widget.pegawai.nip);
    _namaCtrl = TextEditingController(text: widget.pegawai.nama);
    _tanggalLahirCtrl = TextEditingController(text: widget.pegawai.tanggalLahir);
    _nomorTeleponCtrl = TextEditingController(text: widget.pegawai.nomorTelepon);
    _emailCtrl = TextEditingController(text: widget.pegawai.email);
    _passwordCtrl = TextEditingController(text: widget.pegawai.password);
  }

  @override
  void dispose() {
    _nipCtrl.dispose();
    _namaCtrl.dispose();
    _tanggalLahirCtrl.dispose();
    _nomorTeleponCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(widget.pegawai.tanggalLahir) ?? DateTime(1995, 1, 1),
      firstDate: DateTime(1950),
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
        title: const Text("Ubah Pegawai"),
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
                    "Perbarui Data Pegawai",
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
                    "Ubah informasi biodata atau kontak pegawai.",
                    style: TextStyle(
                      fontSize: 12.5,
                      color: LuxuryTheme.warmGrey,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Divider(height: 1, thickness: 1, color: LuxuryTheme.charcoal.withValues(alpha: 0.1)),
                  const SizedBox(height: 22),
                  _fieldNip(),
                  const SizedBox(height: 18),
                  _fieldNama(),
                  const SizedBox(height: 18),
                  _fieldTanggalLahir(),
                  const SizedBox(height: 18),
                  _fieldNomorTelepon(),
                  const SizedBox(height: 18),
                  _fieldEmail(),
                  const SizedBox(height: 18),
                  _fieldPassword(),
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

  Widget _fieldNip() {
    return TextFormField(
      controller: _nipCtrl,
      style: const TextStyle(color: LuxuryTheme.charcoal, fontSize: 14.5),
      decoration: const InputDecoration(
        labelText: "NIP",
        hintText: "Contoh: 199001012020011001",
        prefixIcon: Icon(Icons.badge_outlined, color: LuxuryTheme.charcoal, size: 20),
      ),
      validator: (val) => val == null || val.trim().isEmpty ? "NIP wajib diisi" : null,
    );
  }

  Widget _fieldNama() {
    return TextFormField(
      controller: _namaCtrl,
      style: const TextStyle(color: LuxuryTheme.charcoal, fontSize: 14.5),
      decoration: const InputDecoration(
        labelText: "Nama Lengkap",
        hintText: "Contoh: dr. Budi Setiawan, Sp.A",
        prefixIcon: Icon(Icons.person_outline_rounded, color: LuxuryTheme.charcoal, size: 20),
      ),
      validator: (val) => val == null || val.trim().isEmpty ? "Nama wajib diisi" : null,
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
        labelText: "Nomor Telepon",
        hintText: "Contoh: 081234567890",
        prefixIcon: Icon(Icons.phone_outlined, color: LuxuryTheme.charcoal, size: 20),
      ),
      validator: (val) => val == null || val.trim().isEmpty ? "Nomor telepon wajib diisi" : null,
    );
  }

  Widget _fieldEmail() {
    return TextFormField(
      controller: _emailCtrl,
      keyboardType: TextInputType.emailAddress,
      style: const TextStyle(color: LuxuryTheme.charcoal, fontSize: 14.5),
      decoration: const InputDecoration(
        labelText: "Alamat Email",
        hintText: "Contoh: pegawai@klinik.id",
        prefixIcon: Icon(Icons.email_outlined, color: LuxuryTheme.charcoal, size: 20),
      ),
      validator: (val) {
        if (val == null || val.trim().isEmpty) return "Email wajib diisi";
        if (!val.contains("@")) return "Format email tidak valid";
        return null;
      },
    );
  }

  Widget _fieldPassword() {
    return TextFormField(
      controller: _passwordCtrl,
      obscureText: _obscurePassword,
      style: const TextStyle(color: LuxuryTheme.charcoal, fontSize: 14.5),
      decoration: InputDecoration(
        labelText: "Password",
        hintText: "Minimal 6 karakter",
        prefixIcon: const Icon(Icons.lock_outline_rounded, color: LuxuryTheme.charcoal, size: 20),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: LuxuryTheme.warmGrey,
            size: 20,
          ),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
      ),
      validator: (val) =>
          val == null || val.trim().length < 6 ? "Password minimal 6 karakter" : null,
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
                  final updated = Pegawai(
                    id: widget.pegawai.id,
                    nip: _nipCtrl.text.trim(),
                    nama: _namaCtrl.text.trim(),
                    tanggalLahir: _tanggalLahirCtrl.text.trim(),
                    nomorTelepon: _nomorTeleponCtrl.text.trim(),
                    email: _emailCtrl.text.trim(),
                    password: _passwordCtrl.text.trim(),
                  );

                  await PegawaiService().ubah(updated, widget.pegawai.id ?? '');

                  if (!mounted) return;
                  Navigator.pop(context, true);
                } catch (e) {
                  setState(() => _isLoading = false);
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: LuxuryTheme.crimson,
                      content: Text("Gagal memperbarui data pegawai: $e"),
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
