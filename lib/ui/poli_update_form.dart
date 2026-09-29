import 'package:flutter/material.dart';
import '../helpers/luxury_theme.dart';
import '../model/poli.dart';
import '../service/poli_service.dart';
import '../widget/animated_pressable.dart';
import '../widget/aesthetic_background.dart';

class PoliUpdateForm extends StatefulWidget {
  final Poli poli;

  const PoliUpdateForm({super.key, required this.poli});

  @override
  State<PoliUpdateForm> createState() => _PoliUpdateFormState();
}

class _PoliUpdateFormState extends State<PoliUpdateForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaPoliCtrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _namaPoliCtrl = TextEditingController(text: widget.poli.namaPoli);
  }

  @override
  void dispose() {
    _namaPoliCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LuxuryTheme.alabaster,
      appBar: AppBar(
        title: const Text("Ubah Poli"),
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
                    "Perbarui Data Poliklinik",
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
                    "Ubah informasi nama ruangan poli pada sistem.",
                    style: TextStyle(
                      fontSize: 12.5,
                      color: LuxuryTheme.warmGrey,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Divider(height: 1, thickness: 1, color: LuxuryTheme.charcoal.withValues(alpha: 0.1)),
                  const SizedBox(height: 22),
                  _fieldNamaPoli(),
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

  Widget _fieldNamaPoli() {
    return TextFormField(
      controller: _namaPoliCtrl,
      style: const TextStyle(color: LuxuryTheme.charcoal, fontSize: 14.5),
      decoration: const InputDecoration(
        labelText: "Nama Poli",
        hintText: "Contoh: Poli Jantung, Poli Bedah",
        prefixIcon: Icon(Icons.meeting_room_outlined, color: LuxuryTheme.charcoal, size: 20),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return "Nama Poli tidak boleh kosong";
        }
        return null;
      },
    );
  }

  Widget _tombolSimpanPerubahan() {
    return AnimatedPressable(
      borderRadius: BorderRadius.zero,
      onTap: _isLoading
          ? null
          : () async {
              if (_formKey.currentState!.validate()) {
                setState(() {
                  _isLoading = true;
                });

                try {
                  Poli updated = Poli(
                    id: widget.poli.id,
                    namaPoli: _namaPoliCtrl.text.trim(),
                  );
                  await PoliService().ubah(updated, widget.poli.id ?? '');

                  if (!mounted) return;
                  Navigator.pop(context, true);
                } catch (e) {
                  setState(() {
                    _isLoading = false;
                  });
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: LuxuryTheme.crimson,
                      content: Text("Gagal memperbarui data: $e"),
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
