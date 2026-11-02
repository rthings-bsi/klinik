import 'package:flutter/material.dart';
import '../model/pasien.dart';
import '../service/pasien_service.dart';
import '../service/pegawai_service.dart';
import '../service/poli_service.dart';
import '../widget/sidebar.dart';
import 'pasien_detail.dart';
import 'pasien_form.dart';
import 'pasien_page.dart';
import 'pegawai_page.dart';
import 'poli_page.dart';

/// Isi beranda. Semua angka diambil dari API saat layar dibuka (R-17),
/// jadi tidak ada statistik contoh di sini.
class _RingkasanKlinik {
  final List<Pasien> pasien;
  final int jumlahPoli;
  final int jumlahPegawai;

  const _RingkasanKlinik({
    required this.pasien,
    required this.jumlahPoli,
    required this.jumlahPegawai,
  });
}

class Beranda extends StatefulWidget {
  const Beranda({super.key});

  @override
  State<Beranda> createState() => _BerandaState();
}

class _BerandaState extends State<Beranda> {
  late Future<_RingkasanKlinik> _ringkasan;

  @override
  void initState() {
    super.initState();
    _ringkasan = _muatRingkasan();
  }

  Future<_RingkasanKlinik> _muatRingkasan() async {
    final pasien = PasienService().listData();
    final poli = PoliService().listData();
    final pegawai = PegawaiService().listData();
    return _RingkasanKlinik(
      pasien: await pasien,
      jumlahPoli: (await poli).length,
      jumlahPegawai: (await pegawai).length,
    );
  }

  Future<void> _muatUlang() async {
    setState(() {
      _ringkasan = _muatRingkasan();
    });
    try {
      await _ringkasan;
    } catch (_) {
      // Galatnya sudah ditampilkan FutureBuilder. Di sini cukup ditahan agar
      // indikator muat ulang berhenti tanpa melempar galat kedua.
    }
  }

  /// Halaman tujuan bisa mengubah data, jadi ringkasan dimuat ulang begitu
  /// pengguna kembali ke beranda.
  Future<void> _buka(Widget halaman) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => halaman),
    );
    if (!mounted) return;
    await _muatUlang();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const Sidebar(),
      appBar: AppBar(
        title: const Text("Beranda"),
        actions: [
          IconButton(
            tooltip: "Muat ulang data",
            onPressed: _muatUlang,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _muatUlang,
        child: FutureBuilder<_RingkasanKlinik>(
          future: _ringkasan,
          builder: (context, snapshot) {
            // Transisi 200 ms saat status berubah, supaya data yang baru selesai
            // dimuat masuk tanpa lompatan keras (lihat DESIGN.md).
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _tampilan(snapshot),
            );
          },
        ),
      ),
    );
  }

  Widget _tampilan(AsyncSnapshot<_RingkasanKlinik> snapshot) {
    if (snapshot.hasError) {
      return _tengah(
        key: const ValueKey("galat"),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 40),
            const SizedBox(height: 12),
            const Text(
              "Gagal memuat data klinik.",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 6),
            Text(
              "Periksa koneksi ke server, lalu muat ulang.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _muatUlang,
              child: const Text("Coba lagi"),
            ),
          ],
        ),
      );
    }

    // Saat muat ulang, data lama tetap tampil dan indikatornya cukup dari
    // RefreshIndicator. Jadi daftar tidak berkedip berubah jadi spinner.
    if (!snapshot.hasData) {
      return _tengah(
        key: const ValueKey("memuat"),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text("Memuat data klinik..."),
          ],
        ),
      );
    }

    return _daftar(snapshot.data!);
  }

  /// Wadah untuk state memuat dan galat. Tetap bisa ditarik untuk muat ulang,
  /// jadi pengguna tidak terkunci di layar galat.
  Widget _tengah({required Key key, required Widget child}) {
    return LayoutBuilder(
      key: key,
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  Widget _daftar(_RingkasanKlinik data) {
    final pasienTerbaru = _urutkanTerbaru(data.pasien).take(3).toList();

    return ListView(
      key: const ValueKey("data"),
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        _kartuFokus(data),
        const SizedBox(height: 24),
        _judulBagian("Data pendukung"),
        const SizedBox(height: 8),
        _barisModul(
          ikon: Icons.local_hospital_outlined,
          judul: "Poli",
          jumlah: data.jumlahPoli,
          halaman: const PoliPage(),
        ),
        _barisModul(
          ikon: Icons.badge_outlined,
          judul: "Pegawai",
          jumlah: data.jumlahPegawai,
          halaman: const PegawaiPage(),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(child: _judulBagian("Pasien terbaru")),
            TextButton(
              onPressed: () => _buka(const PasienPage()),
              child: const Text("Lihat semua"),
            ),
          ],
        ),
        const SizedBox(height: 4),
        if (pasienTerbaru.isEmpty)
          _pasienKosong()
        else
          for (final pasien in pasienTerbaru) _barisPasien(pasien),
      ],
    );
  }

  /// Titik fokus layar: pasien adalah data yang bertambah setiap hari,
  /// sedangkan poli dan pegawai hanya data pendukung. Karena itu hanya angka
  /// pasien yang diberi bidang berwarna penuh.
  Widget _kartuFokus(_RingkasanKlinik data) {
    final warna = Theme.of(context).colorScheme;
    const radius = BorderRadius.all(Radius.circular(14));

    return Material(
      color: warna.primary,
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: () => _buka(const PasienPage()),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Pasien terdaftar",
                style: TextStyle(
                  color: warna.onPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "${data.pasien.length}",
                style: TextStyle(
                  color: warna.onPrimary,
                  fontSize: 44,
                  fontWeight: FontWeight.w600,
                  height: 1,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    "Buka data pasien",
                    style: TextStyle(color: warna.onPrimary, fontSize: 14),
                  ),
                  const SizedBox(width: 2),
                  Icon(Icons.chevron_right, size: 18, color: warna.onPrimary),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Baris navigasi. Chevron dipakai hanya di baris yang benar-benar membuka
  /// halaman lain, bukan di tombol aksi (R-08).
  Widget _barisModul({
    required IconData ikon,
    required String judul,
    required int jumlah,
    required Widget halaman,
  }) {
    final warna = Theme.of(context).colorScheme;
    const radius = BorderRadius.all(Radius.circular(12));

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: warna.surface,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(color: warna.outlineVariant),
        ),
        child: InkWell(
          borderRadius: radius,
          onTap: () => _buka(halaman),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(ikon, color: warna.primary),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(judul, style: const TextStyle(fontSize: 16)),
                ),
                Text(
                  "$jumlah",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: warna.primary,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right, color: warna.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _barisPasien(Pasien pasien) {
    final warna = Theme.of(context).colorScheme;
    const radius = BorderRadius.all(Radius.circular(12));

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: warna.surfaceContainerHighest,
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: () => _buka(PasienDetail(pasien: pasien)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: warna.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _inisial(pasien.nama),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: warna.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pasien.nama,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        pasien.nomorRm,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: warna.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: warna.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Empty state: menyebut sebabnya dan satu tindakan yang mengisinya (R-27).
  Widget _pasienKosong() {
    final warna = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: warna.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Belum ada pasien terdaftar.",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 6),
          Text(
            "Data pasien baru akan muncul di sini setelah ditambahkan.",
            style: TextStyle(fontSize: 14, color: warna.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => _buka(const PasienForm()),
            icon: const Icon(Icons.add),
            label: const Text("Tambah pasien"),
          ),
        ],
      ),
    );
  }

  Widget _judulBagian(String teks) {
    return Text(
      teks,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }

  List<Pasien> _urutkanTerbaru(List<Pasien> pasien) {
    final hasil = [...pasien];
    hasil.sort((a, b) {
      final idA = int.tryParse(a.id ?? "") ?? 0;
      final idB = int.tryParse(b.id ?? "") ?? 0;
      return idB.compareTo(idA);
    });
    return hasil;
  }

  /// Inisial nama sebagai placeholder penanda baris, ambil dari data asli.
  String _inisial(String nama) {
    final bagian = nama.trim().split(RegExp(r"\s+"));
    for (final kata in bagian) {
      if (kata.isNotEmpty) return kata.substring(0, 1).toUpperCase();
    }
    return "?";
  }
}
