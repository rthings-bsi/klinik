import 'package:flutter/material.dart';
import '../model/pasien.dart';
import 'pasien_detail.dart';

class PasienItem extends StatelessWidget {
  final Pasien pasien;
  final VoidCallback? onRefresh;

  const PasienItem({super.key, required this.pasien, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Card(
        child: ListTile(
          title: Text(pasien.nama),
          subtitle: Text("No. RM: ${pasien.nomorRm}"),
        ),
      ),
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PasienDetail(pasien: pasien),
          ),
        );
        onRefresh?.call();
      },
    );
  }
}
