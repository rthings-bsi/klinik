import 'package:flutter/material.dart';
import '../model/pasien.dart';
import '../service/pasien_service.dart';
import '../widget/smooth_page_route.dart';
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
        title: const Text("Tambah Pasien"),
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
                  "Formulir Pendaftaran Pasien",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1C1C1E),
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Catat data identitas dan nomor rekam medis pasien baru.",
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF8E8E93),
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, color: Color(0xFFE5E5EA)),
                const SizedBox(height: 18),
                _fieldNomorRm(),
                const SizedBox(height: 14),
                _fieldNama(),
                const SizedBox(height: 14),
                _fieldTanggalLahir(),
                const SizedBox(height: 14),
                _fieldNomorTelepon(),
                const SizedBox(height: 14),
                _fieldAlamat(),
                const SizedBox(height: 26),
                _tombolSimpan(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _fieldNomorRm() {
    return TextFormField(
      controller: _nomorRmCtrl,
      decoration: const InputDecoration(
        labelText: "Nomor Rekam Medis (RM)",
        hintText: "Contoh: RM-2024-004",
        prefixIcon: Icon(Icons.assignment_rounded, color: Color(0xFF0F766E)),
      ),
      validator: (val) => val == null || val.trim().isEmpty ? "Nomor RM wajib diisi" : null,
    );
  }

  Widget _fieldNama() {
    return TextFormField(
      controller: _namaCtrl,
      decoration: const InputDecoration(
        labelText: "Nama Lengkap Pasien",
        hintText: "Contoh: Siti Aisyah",
        prefixIcon: Icon(Icons.person_rounded, color: Color(0xFF0F766E)),
      ),
      validator: (val) => val == null || val.trim().isEmpty ? "Nama pasien wajib diisi" : null,
    );
  }

  Widget _fieldTanggalLahir() {
    return TextFormField(
      controller: _tanggalLahirCtrl,
      readOnly: true,
      onTap: _selectDate,
      decoration: InputDecoration(
        labelText: "Tanggal Lahir",
        hintText: "YYYY-MM-DD",
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
        labelText: "Nomor Telepon / WhatsApp",
        hintText: "Contoh: 081234567890",
        prefixIcon: Icon(Icons.phone_rounded, color: Color(0xFF0F766E)),
      ),
      validator: (val) => val == null || val.trim().isEmpty ? "Nomor telepon wajib diisi" : null,
    );
  }

  Widget _fieldAlamat() {
    return TextFormField(
      controller: _alamatCtrl,
      maxLines: 2,
      decoration: const InputDecoration(
        labelText: "Alamat Tempat Tinggal",
        hintText: "Contoh: Jl. Gajah Mada No. 12, Pontianak",
        prefixIcon: Icon(Icons.home_rounded, color: Color(0xFF0F766E)),
      ),
      validator: (val) => val == null || val.trim().isEmpty ? "Alamat wajib diisi" : null,
    );
  }

  Widget _tombolSimpan() {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0F766E),
          foregroundColor: Colors.white,
        ),
        onPressed: _isLoading
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
                      SnackBar(content: Text("Gagal menyimpan data pasien: $e")),
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
                "Simpan Data",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }
}
