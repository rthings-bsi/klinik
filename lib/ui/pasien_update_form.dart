import 'package:flutter/material.dart';
import '../model/pasien.dart';
import '../service/pasien_service.dart';
import 'pasien_detail.dart';

class PasienUpdateForm extends StatefulWidget {
  final Pasien pasien;

  const PasienUpdateForm({super.key, required this.pasien});

  @override
  State<PasienUpdateForm> createState() => _PasienUpdateFormState();
}

class _PasienUpdateFormState extends State<PasienUpdateForm> {
  final _formKey = GlobalKey<FormState>();
  final _nomorRmCtrl = TextEditingController();
  final _namaCtrl = TextEditingController();
  final _tanggalLahirCtrl = TextEditingController();
  final _nomorTeleponCtrl = TextEditingController();
  final _alamatCtrl = TextEditingController();

  Future<Pasien> getData() async {
    Pasien data = await PasienService().getById(widget.pasien.id.toString());
    if (mounted) {
      setState(() {
        _nomorRmCtrl.text = data.nomorRm;
        _namaCtrl.text = data.nama;
        _tanggalLahirCtrl.text = data.tanggalLahir;
        _nomorTeleponCtrl.text = data.nomorTelepon;
        _alamatCtrl.text = data.alamat;
      });
    }
    return data;
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ubah Pasien")),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _fieldNomorRm(),
              const SizedBox(height: 16),
              _fieldNama(),
              const SizedBox(height: 16),
              _fieldTanggalLahir(),
              const SizedBox(height: 16),
              _fieldNomorTelepon(),
              const SizedBox(height: 16),
              _fieldAlamat(),
              const SizedBox(height: 20),
              _tombolSimpan(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fieldNomorRm() {
    return TextField(
      decoration: const InputDecoration(labelText: "Nomor RM"),
      controller: _nomorRmCtrl,
    );
  }

  Widget _fieldNama() {
    return TextField(
      decoration: const InputDecoration(labelText: "Nama"),
      controller: _namaCtrl,
    );
  }

  Widget _fieldTanggalLahir() {
    return TextField(
      decoration: const InputDecoration(labelText: "Tanggal Lahir"),
      controller: _tanggalLahirCtrl,
    );
  }

  Widget _fieldNomorTelepon() {
    return TextField(
      decoration: const InputDecoration(labelText: "Nomor Telepon"),
      controller: _nomorTeleponCtrl,
    );
  }

  Widget _fieldAlamat() {
    return TextField(
      decoration: const InputDecoration(labelText: "Alamat"),
      controller: _alamatCtrl,
    );
  }

  Widget _tombolSimpan() {
    return ElevatedButton(
      onPressed: () async {
        Pasien pasien = Pasien(
          nomorRm: _nomorRmCtrl.text,
          nama: _namaCtrl.text,
          tanggalLahir: _tanggalLahirCtrl.text,
          nomorTelepon: _nomorTeleponCtrl.text,
          alamat: _alamatCtrl.text,
        );
        String id = widget.pasien.id.toString();
        final navigator = Navigator.of(context);
        await PasienService().ubah(pasien, id).then((value) {
          navigator.pop();
          navigator.pushReplacement(
            MaterialPageRoute(builder: (context) => PasienDetail(pasien: value)),
          );
        });
      },
      child: const Text("Simpan Perubahan"),
    );
  }
}
