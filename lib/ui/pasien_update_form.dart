import 'package:flutter/material.dart';
import '../model/pasien.dart';
import '../service/pasien_service.dart';

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
        title: const Text("Ubah Pasien"),
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
                  "Perbarui Data Pasien",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1C1C1E),
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Ubah informasi identitas atau kontak pasien.",
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
                _tombolSimpanPerubahan(),
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

  Widget _fieldAlamat() {
    return TextFormField(
      controller: _alamatCtrl,
      maxLines: 2,
      decoration: const InputDecoration(
        labelText: "Alamat",
        prefixIcon: Icon(Icons.home_rounded, color: Color(0xFF0F766E)),
      ),
      validator: (val) => val == null || val.trim().isEmpty ? "Alamat wajib diisi" : null,
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
                      SnackBar(content: Text("Gagal memperbarui data pasien: $e")),
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
