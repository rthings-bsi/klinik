class Pasien {
  String? id;
  String nomorRm;
  String nama;
  String tanggalLahir;
  String nomorTelepon;
  String alamat;

  Pasien({
    this.id,
    required this.nomorRm,
    required this.nama,
    required this.tanggalLahir,
    required this.nomorTelepon,
    required this.alamat,
  });

  factory Pasien.fromJson(Map<String, dynamic> json) {
    String tgl = json["tanggal_lahir"]?.toString() ?? "";
    if (tgl.contains("T")) {
      tgl = tgl.split("T")[0];
    }
    String telp = json["nomor_telepon"]?.toString() ?? "";
    if (telp.isNotEmpty && !telp.startsWith("0") && !telp.startsWith("+")) {
      telp = "0$telp";
    }

    return Pasien(
      id: json["id"]?.toString(),
      nomorRm: json["nomor_rm"]?.toString() ?? "",
      nama: json["nama"]?.toString() ?? "",
      tanggalLahir: tgl,
      nomorTelepon: telp,
      alamat: json["alamat"]?.toString() ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
        "nomor_rm": nomorRm,
        "nama": nama,
        "tanggal_lahir": tanggalLahir,
        "nomor_telepon": nomorTelepon,
        "alamat": alamat,
      };
}
