import 'package:flutter/material.dart';
import '../model/pegawai.dart';
import '../service/pegawai_service.dart';

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
              primary: Color(0xFF0F766E),
              onPrimary: Colors.white,
              onSurface: Color(0xFF0F172A),
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
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        title: const Text("Ubah Pegawai"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Container(
          padding: const EdgeInsets.all(22),
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "Perbarui Data Pegawai",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1C1C1E),
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Ubah informasi biodata atau kontak pegawai.",
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF8E8E93),
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, color: Color(0xFFE5E5EA)),
                const SizedBox(height: 18),
                _fieldNip(),
                const SizedBox(height: 14),
                _fieldNama(),
                const SizedBox(height: 14),
                _fieldTanggalLahir(),
                const SizedBox(height: 14),
                _fieldNomorTelepon(),
                const SizedBox(height: 14),
                _fieldEmail(),
                const SizedBox(height: 14),
                _fieldPassword(),
                const SizedBox(height: 26),
                _tombolSimpanPerubahan(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _fieldNip() {
    return TextFormField(
      controller: _nipCtrl,
      decoration: const InputDecoration(
        labelText: "NIP",
        prefixIcon: Icon(Icons.badge_rounded, color: Color(0xFF0F766E)),
      ),
      validator: (val) => val == null || val.trim().isEmpty ? "NIP wajib diisi" : null,
    );
  }

  Widget _fieldNama() {
    return TextFormField(
      controller: _namaCtrl,
      decoration: const InputDecoration(
        labelText: "Nama Lengkap",
        prefixIcon: Icon(Icons.person_rounded, color: Color(0xFF0F766E)),
      ),
      validator: (val) => val == null || val.trim().isEmpty ? "Nama wajib diisi" : null,
    );
  }

  Widget _fieldTanggalLahir() {
    return TextFormField(
      controller: _tanggalLahirCtrl,
      readOnly: true,
      onTap: _selectDate,
      decoration: InputDecoration(
        labelText: "Tanggal Lahir",
        prefixIcon: const Icon(Icons.calendar_today_rounded, color: Color(0xFF0F766E)),
        suffixIcon: IconButton(
          icon: const Icon(Icons.date_range_rounded, color: Color(0xFF0F766E)),
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
      decoration: const InputDecoration(
        labelText: "Nomor Telepon",
        prefixIcon: Icon(Icons.phone_rounded, color: Color(0xFF0F766E)),
      ),
      validator: (val) => val == null || val.trim().isEmpty ? "Nomor telepon wajib diisi" : null,
    );
  }

  Widget _fieldEmail() {
    return TextFormField(
      controller: _emailCtrl,
      keyboardType: TextInputType.emailAddress,
      decoration: const InputDecoration(
        labelText: "Alamat Email",
        prefixIcon: Icon(Icons.email_rounded, color: Color(0xFF0F766E)),
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
      decoration: InputDecoration(
        labelText: "Password",
        prefixIcon: const Icon(Icons.lock_rounded, color: Color(0xFF0F766E)),
        suffixIcon: IconButton(
          icon: Icon(_obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
      ),
      validator: (val) =>
          val == null || val.trim().length < 6 ? "Password minimal 6 karakter" : null,
    );
  }

  Widget _tombolSimpanPerubahan() {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF007AFF),
          foregroundColor: Colors.white,
        ),
        onPressed: _isLoading
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
                      SnackBar(content: Text("Gagal memperbarui data pegawai: $e")),
                    );
                  }
                }
              },
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : const Text(
                "Simpan Perubahan",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }
}
