import 'package:flutter/material.dart';
import '../model/poli.dart';
import '../service/poli_service.dart';
import '../widget/smooth_page_route.dart';
import 'poli_detail.dart';

class PoliForm extends StatefulWidget {
  const PoliForm({super.key});

  @override
  State<PoliForm> createState() => _PoliFormState();
}

class _PoliFormState extends State<PoliForm> {
  final _formKey = GlobalKey<FormState>();
  final _namaPoliCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _namaPoliCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        title: const Text("Tambah Poli"),
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
                  "Formulir Data Poliklinik",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1C1C1E),
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Masukkan nama ruangan atau spesialisasi poli baru.",
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF8E8E93),
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, color: Color(0xFFE5E5EA)),
                const SizedBox(height: 20),
                _fieldNamaPoli(),
                const SizedBox(height: 26),
                _tombolSimpan(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _fieldNamaPoli() {
    return TextFormField(
      controller: _namaPoliCtrl,
      decoration: const InputDecoration(
        labelText: "Nama Poli",
        hintText: "Contoh: Poli Gigi, Poli Anak",
        prefixIcon: Icon(Icons.meeting_room_rounded, color: Color(0xFF0F766E)),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return "Nama Poli tidak boleh kosong";
        }
        return null;
      },
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
                  setState(() {
                    _isLoading = true;
                  });

                  try {
                    Poli poli = Poli(namaPoli: _namaPoliCtrl.text.trim());
                    final savedPoli = await PoliService().simpan(poli);

                    if (!mounted) return;
                    Navigator.pushReplacement(
                      context,
                      SmoothPageRoute(page: PoliDetail(poli: savedPoli)),
                    );
                  } catch (e) {
                    setState(() {
                      _isLoading = false;
                    });
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Gagal menyimpan data: $e")),
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
