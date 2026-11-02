import 'package:flutter/material.dart';
import '../helpers/app_colors.dart';
import '../model/pegawai.dart';
import '../service/pegawai_service.dart';
import 'pegawai_page.dart';
import 'pegawai_update_form.dart';

class PegawaiDetail extends StatefulWidget {
  final Pegawai pegawai;

  const PegawaiDetail({super.key, required this.pegawai});

  @override
  State<PegawaiDetail> createState() => _PegawaiDetailState();
}

class _PegawaiDetailState extends State<PegawaiDetail> {
  Stream<Pegawai> getData() async* {
    Pegawai data = await PegawaiService().getById(widget.pegawai.id.toString());
    yield data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Detail Pegawai")),
      body: StreamBuilder<Pegawai>(
        stream: getData(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return const Center(child: Text("Data Tidak Ditemukan"));
          }
          Pegawai pegawai = snapshot.data!;
          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                _info("NIP", pegawai.nip),
                _info("Nama", pegawai.nama),
                _info("Tanggal Lahir", pegawai.tanggalLahir),
                _info("Nomor Telepon", pegawai.nomorTelepon),
                _info("Email", pegawai.email),
                _info("Password", pegawai.password),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _tombolUbah(pegawai),
                    _tombolHapus(pegawai),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _info(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              ": $value",
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  // Tombol "Ubah" ikut warna utama tema, jadi warnanya hanya ditentukan
  // di satu tempat (main.dart).
  Widget _tombolUbah(Pegawai pegawai) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PegawaiUpdateForm(pegawai: pegawai),
          ),
        );
      },
      child: const Text("Ubah"),
    );
  }

  Widget _tombolHapus(Pegawai pegawai) {
    return ElevatedButton(
      onPressed: () {
        final navigator = Navigator.of(context);
        AlertDialog alertDialog = AlertDialog(
          content: const Text("Yakin ingin menghapus data ini?"),
          actions: [
            ElevatedButton(
              onPressed: () async {
                await PegawaiService().hapus(pegawai);
                navigator.pop();
                navigator.pushReplacement(
                  MaterialPageRoute(builder: (context) => const PegawaiPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.merahHapus,
                  foregroundColor: Colors.white),
              child: const Text("YA"),
            ),
            ElevatedButton(
              onPressed: () {
                navigator.pop();
              },
              child: const Text("Tidak"),
            )
          ],
        );
        showDialog(context: context, builder: (context) => alertDialog);
      },
      style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.merahHapus, foregroundColor: Colors.white),
      child: const Text("Hapus"),
    );
  }
}
