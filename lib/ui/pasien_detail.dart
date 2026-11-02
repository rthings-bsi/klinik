import 'package:flutter/material.dart';
import '../helpers/app_colors.dart';
import '../model/pasien.dart';
import '../service/pasien_service.dart';
import 'pasien_page.dart';
import 'pasien_update_form.dart';

class PasienDetail extends StatefulWidget {
  final Pasien pasien;

  const PasienDetail({super.key, required this.pasien});

  @override
  State<PasienDetail> createState() => _PasienDetailState();
}

class _PasienDetailState extends State<PasienDetail> {
  Stream<Pasien> getData() async* {
    Pasien data = await PasienService().getById(widget.pasien.id.toString());
    yield data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Detail Pasien")),
      body: StreamBuilder<Pasien>(
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
          Pasien pasien = snapshot.data!;
          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                _info("Nomor RM", pasien.nomorRm),
                _info("Nama", pasien.nama),
                _info("Tanggal Lahir", pasien.tanggalLahir),
                _info("Nomor Telepon", pasien.nomorTelepon),
                _info("Alamat", pasien.alamat),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _tombolUbah(pasien),
                    _tombolHapus(pasien),
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
  Widget _tombolUbah(Pasien pasien) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PasienUpdateForm(pasien: pasien),
          ),
        );
      },
      child: const Text("Ubah"),
    );
  }

  Widget _tombolHapus(Pasien pasien) {
    return ElevatedButton(
      onPressed: () {
        final navigator = Navigator.of(context);
        AlertDialog alertDialog = AlertDialog(
          content: const Text("Yakin ingin menghapus data ini?"),
          actions: [
            ElevatedButton(
              onPressed: () async {
                await PasienService().hapus(pasien);
                navigator.pop();
                navigator.pushReplacement(
                  MaterialPageRoute(builder: (context) => const PasienPage()),
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
