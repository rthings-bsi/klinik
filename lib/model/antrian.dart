class Antrian {
  String? id;
  String nomorAntrian;
  String idPoli;
  String namaPoli;
  String namaPasien;
  String nomorRm;
  String nomorTelepon;
  String tanggal;
  String waktu;
  String keluhan;
  String status;

  Antrian({
    this.id,
    required this.nomorAntrian,
    required this.idPoli,
    required this.namaPoli,
    required this.namaPasien,
    required this.nomorRm,
    required this.nomorTelepon,
    required this.tanggal,
    required this.waktu,
    required this.keluhan,
    this.status = 'Menunggu',
  });

  factory Antrian.fromJson(Map<String, dynamic> json) {
    String getVal(List<String> keys, [String fallback = '']) {
      for (final k in keys) {
        if (json.containsKey(k) && json[k] != null && json[k].toString().isNotEmpty) {
          return json[k].toString();
        }
        final cleanKey = k.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
        for (final entry in json.entries) {
          final entryClean = entry.key.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
          if (entryClean == cleanKey && entry.value != null && entry.value.toString().isNotEmpty) {
            return entry.value.toString();
          }
        }
      }
      return fallback;
    }

    return Antrian(
      id: getVal(['id', 'no', 'ID']).isEmpty ? null : getVal(['id', 'no', 'ID']),
      nomorAntrian: getVal(['nomor_antrian', 'nomor antrian', 'no_antrian', 'no antrian', 'nomorantrian', 'antrian']),
      idPoli: getVal(['id_poli', 'id poli', 'idpoli', 'idPoli']),
      namaPoli: getVal(['nama_poli', 'nama poli', 'namapoli', 'poli']),
      namaPasien: getVal(['nama_pasien', 'nama pasien', 'namapasien', 'pasien', 'nama']),
      nomorRm: getVal(['nomor_rm', 'nomor rm', 'no_rm', 'no rm', 'norm']),
      nomorTelepon: getVal(['nomor_telepon', 'nomor telepon', 'telepon', 'no_telepon', 'no telepon', 'no_hp', 'no hp', 'phone']),
      tanggal: getVal(['tanggal', 'tgl', 'date']),
      waktu: getVal(['waktu', 'jam', 'time']),
      keluhan: getVal(['keluhan', 'gejala']),
      status: getVal(['status', 'keadaan'], 'Menunggu'),
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'nomor_antrian': nomorAntrian,
        'nomor antrian': nomorAntrian,
        'id_poli': idPoli,
        'id poli': idPoli,
        'nama_poli': namaPoli,
        'nama poli': namaPoli,
        'nama_pasien': namaPasien,
        'nama pasien': namaPasien,
        'nomor_rm': nomorRm,
        'nomor rm': nomorRm,
        'nomor_telepon': nomorTelepon,
        'nomor telepon': nomorTelepon,
        'tanggal': tanggal,
        'waktu': waktu,
        'keluhan': keluhan,
        'status': status,
      };
}
