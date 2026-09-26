class User {
  String? id;
  String username;
  String password;
  String nama;
  String nomorTelepon;
  String role;
  String? nomorRm;
  String? createdAt;

  User({
    this.id,
    required this.username,
    required this.password,
    required this.nama,
    required this.nomorTelepon,
    this.role = 'Pasien',
    this.nomorRm,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id']?.toString(),
        username: json['username']?.toString() ?? '',
        password: json['password']?.toString() ?? '',
        nama: json['nama']?.toString() ?? '',
        nomorTelepon: json['nomor_telepon']?.toString() ?? '',
        role: json['role']?.toString() ?? 'Pasien',
        nomorRm: json['nomor_rm']?.toString(),
        createdAt: json['created_at']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'username': username,
        'password': password,
        'nama': nama,
        'nomor_telepon': nomorTelepon,
        'role': role,
        if (nomorRm != null) 'nomor_rm': nomorRm,
        if (createdAt != null) 'created_at': createdAt,
      };
}
