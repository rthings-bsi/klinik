import 'package:flutter/material.dart';
import '../helpers/app_colors.dart';
import '../model/poli.dart';
import '../service/poli_service.dart';
import 'poli_page.dart';
import 'poli_update_form.dart';

class PoliDetail extends StatefulWidget {
  final Poli poli;

  const PoliDetail({super.key, required this.poli});

  @override
  State<PoliDetail> createState() => _PoliDetailState();
}

class _PoliDetailState extends State<PoliDetail> {
  Stream<Poli> getData() async* {
    Poli data = await PoliService().getById(widget.poli.id.toString());
    yield data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Detail Poli")),
      body: StreamBuilder<Poli>(
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
          Poli poli = snapshot.data!;
          return Column(
            children: [
              const SizedBox(height: 20),
              Text(
                "Nama Poli : ${poli.namaPoli}",
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _tombolUbah(poli),
                  _tombolHapus(poli),
                ],
              )
            ],
          );
        },
      ),
    );
  }

  // Tombol "Ubah" ikut warna utama tema, jadi warnanya hanya ditentukan
  // di satu tempat (main.dart).
  Widget _tombolUbah(Poli poli) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PoliUpdateForm(poli: poli),
          ),
        );
      },
      child: const Text("Ubah"),
    );
  }

  Widget _tombolHapus(Poli poli) {
    return ElevatedButton(
      onPressed: () {
        final navigator = Navigator.of(context);
        AlertDialog alertDialog = AlertDialog(
          content: const Text("Yakin ingin menghapus data ini?"),
          actions: [
            ElevatedButton(
              onPressed: () async {
                await PoliService().hapus(poli);
                navigator.pop();
                navigator.pushReplacement(
                  MaterialPageRoute(builder: (context) => const PoliPage()),
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
