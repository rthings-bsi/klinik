import 'package:flutter/material.dart';
import '../model/pegawai.dart';
import 'pegawai_detail.dart';

class PegawaiItem extends StatelessWidget {
  final Pegawai pegawai;
  final VoidCallback? onRefresh;

  const PegawaiItem({super.key, required this.pegawai, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Card(
        child: ListTile(
          title: Text(pegawai.nama),
          subtitle: Text("NIP: ${pegawai.nip}"),
        ),
      ),
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PegawaiDetail(pegawai: pegawai),
          ),
        );
        onRefresh?.call();
      },
    );
  }
}
