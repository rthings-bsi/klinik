class Pegawai {
  String? id;
  String nip;
  String nama;
  String tanggalLahir;
  String nomorTelepon;
  String email;
  String password;

  Pegawai({
    this.id,
    required this.nip,
    required this.nama,
    required this.tanggalLahir,
    required this.nomorTelepon,
    required this.email,
    required this.password,
  });

  factory Pegawai.fromJson(Map<String, dynamic> json) {
    String tgl = json["tanggal_lahir"]?.toString() ?? "";
    if (tgl.contains("T")) {
      tgl = tgl.split("T")[0];
    }
    String telp = json["nomor_telepon"]?.toString() ?? "";
    if (telp.isNotEmpty && !telp.startsWith("0") && !telp.startsWith("+")) {
      telp = "0$telp";
    }

    return Pegawai(
      id: json["id"]?.toString(),
      nip: json["nip"]?.toString() ?? "",
      nama: json["nama"]?.toString() ?? "",
      tanggalLahir: tgl,
      nomorTelepon: telp,
      email: json["email"]?.toString() ?? "",
      password: json["password"]?.toString() ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
        "nip": nip,
        "nama": nama,
        "tanggal_lahir": tanggalLahir,
        "nomor_telepon": nomorTelepon,
        "email": email,
        "password": password,
      };
}
