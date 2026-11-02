import 'package:flutter/material.dart';
import '../model/poli.dart';
import 'poli_detail.dart';

class PoliItem extends StatelessWidget {
  final Poli poli;
  final VoidCallback? onRefresh;

  const PoliItem({super.key, required this.poli, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Card(
        child: ListTile(
          title: Text(poli.namaPoli),
        ),
      ),
      onTap: () async {
        await Navigator.push(context,
            MaterialPageRoute(builder: (context) => PoliDetail(poli: poli)));
        onRefresh?.call();
      },
    );
  }
}
