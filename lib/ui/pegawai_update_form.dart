import 'package:flutter/material.dart';
import '../model/pegawai.dart';
import '../service/pegawai_service.dart';
import 'pegawai_detail.dart';

class PegawaiUpdateForm extends StatefulWidget {
  final Pegawai pegawai;

  const PegawaiUpdateForm({super.key, required this.pegawai});

  @override
  State<PegawaiUpdateForm> createState() => _PegawaiUpdateFormState();
}

class _PegawaiUpdateFormState extends State<PegawaiUpdateForm> {
  final _formKey = GlobalKey<FormState>();
  final _nipCtrl = TextEditingController();
  final _namaCtrl = TextEditingController();
  final _tanggalLahirCtrl = TextEditingController();
  final _nomorTeleponCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  Future<Pegawai> getData() async {
    Pegawai data =
        await PegawaiService().getById(widget.pegawai.id.toString());
    if (mounted) {
      setState(() {
        _nipCtrl.text = data.nip;
        _namaCtrl.text = data.nama;
        _tanggalLahirCtrl.text = data.tanggalLahir;
        _nomorTeleponCtrl.text = data.nomorTelepon;
        _emailCtrl.text = data.email;
        _passwordCtrl.text = data.password;
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
      appBar: AppBar(title: const Text("Ubah Pegawai")),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _fieldNip(),
              const SizedBox(height: 16),
              _fieldNama(),
              const SizedBox(height: 16),
              _fieldTanggalLahir(),
              const SizedBox(height: 16),
              _fieldNomorTelepon(),
              const SizedBox(height: 16),
              _fieldEmail(),
              const SizedBox(height: 16),
              _fieldPassword(),
              const SizedBox(height: 20),
              _tombolSimpan(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fieldNip() {
    return TextField(
      decoration: const InputDecoration(labelText: "NIP"),
      controller: _nipCtrl,
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

  Widget _fieldEmail() {
    return TextField(
      decoration: const InputDecoration(labelText: "Email"),
      controller: _emailCtrl,
    );
  }

  Widget _fieldPassword() {
    return TextField(
      decoration: const InputDecoration(labelText: "Password"),
      obscureText: true,
      controller: _passwordCtrl,
    );
  }

  Widget _tombolSimpan() {
    return ElevatedButton(
      onPressed: () async {
        Pegawai pegawai = Pegawai(
          nip: _nipCtrl.text,
          nama: _namaCtrl.text,
          tanggalLahir: _tanggalLahirCtrl.text,
          nomorTelepon: _nomorTeleponCtrl.text,
          email: _emailCtrl.text,
          password: _passwordCtrl.text,
        );
        String id = widget.pegawai.id.toString();
        final navigator = Navigator.of(context);
        await PegawaiService().ubah(pegawai, id).then((value) {
          navigator.pop();
          navigator.pushReplacement(
            MaterialPageRoute(builder: (context) => PegawaiDetail(pegawai: value)),
          );
        });
      },
      child: const Text("Simpan Perubahan"),
    );
  }
}
