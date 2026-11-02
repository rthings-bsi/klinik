import 'package:dio/dio.dart';

final Dio dio = Dio(BaseOptions(
    baseUrl: 'https://63588b60c27556d2893f7a12.mockapi.io/',
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 3)));

class ApiClient {
  // Data lokal dipakai jika API MockAPI pada modul sudah tidak dapat diakses
  // (project MockAPI modul mengembalikan 404). Struktur data tetap sama
  // dengan response REST API sehingga layer service tidak perlu berubah.
  static bool offline = false;

  static final Map<String, List<Map<String, dynamic>>> _localData = {
    'poli': [
      {'id': '1', 'nama_poli': 'Poli Anak'},
      {'id': '2', 'nama_poli': 'Poli Kandungan'},
      {'id': '3', 'nama_poli': 'Poli Gigi'},
      {'id': '4', 'nama_poli': 'Poli THT'},
    ],
    'pegawai': [
      {
        'id': '1',
        'nip': '198901012015011001',
        'nama': 'dr. Hendra Pratama',
        'tanggal_lahir': '1989-01-01',
        'nomor_telepon': '081234567890',
        'email': 'hendra.pratama@klinik.id',
        'password': 'password123',
      },
      {
        'id': '2',
        'nip': '199203152018022002',
        'nama': 'drg. Siti Nurhaliza',
        'tanggal_lahir': '1992-03-15',
        'nomor_telepon': '081298765432',
        'email': 'siti.nurhaliza@klinik.id',
        'password': 'password123',
      },
    ],
    'pasien': [
      {
        'id': '1',
        'nomor_rm': 'RM-2024-001',
        'nama': 'Budi Santoso',
        'tanggal_lahir': '1985-05-12',
        'nomor_telepon': '082155443322',
        'alamat': 'Jl. Merdeka No. 45, Pontianak',
      },
      {
        'id': '2',
        'nomor_rm': 'RM-2024-002',
        'nama': 'Dewi Lestari',
        'tanggal_lahir': '1990-11-28',
        'nomor_telepon': '085266778899',
        'alamat': 'Jl. Gajah Mada No. 12, Pontianak',
      },
    ],
  };

  Future<Response> get(String path) async {
    if (!offline) {
      try {
        final response = await dio.get(path);
        return response;
      } on DioException {
        offline = true;
      }
    }
    return _localGet(path);
  }

  Future<Response> post(String path, dynamic data) async {
    if (!offline) {
      try {
        final response = await dio.post(path, data: data);
        return response;
      } on DioException {
        offline = true;
      }
    }
    return _localPost(path, data);
  }

  Future<Response> put(String path, dynamic data) async {
    if (!offline) {
      try {
        final response = await dio.put(path, data: data);
        return response;
      } on DioException {
        offline = true;
      }
    }
    return _localPut(path, data);
  }

  Future<Response> delete(String path) async {
    if (!offline) {
      try {
        final response = await dio.delete(path);
        return response;
      } on DioException {
        offline = true;
      }
    }
    return _localDelete(path);
  }

  Response _localGet(String path) {
    final segments = path.split('/');
    final resource = segments.first;
    final list = _localData.putIfAbsent(resource, () => []);

    if (segments.length > 1) {
      final id = segments[1];
      final item = list.firstWhere(
        (element) => element['id'].toString() == id,
        orElse: () => <String, dynamic>{},
      );
      if (item.isEmpty) {
        throw Exception("Data tidak ditemukan");
      }
      return Response(
        requestOptions: RequestOptions(path: path),
        data: Map<String, dynamic>.from(item),
        statusCode: 200,
      );
    }

    return Response(
      requestOptions: RequestOptions(path: path),
      data: list.map((element) => Map<String, dynamic>.from(element)).toList(),
      statusCode: 200,
    );
  }

  Response _localPost(String path, dynamic data) {
    final resource = path.split('/').first;
    final list = _localData.putIfAbsent(resource, () => []);

    int newId = 1;
    for (final item in list) {
      final id = int.tryParse(item['id'].toString()) ?? 0;
      if (id >= newId) newId = id + 1;
    }

    final item = Map<String, dynamic>.from(data as Map);
    item['id'] = newId.toString();
    list.add(item);

    return Response(
      requestOptions: RequestOptions(path: path),
      data: Map<String, dynamic>.from(item),
      statusCode: 201,
    );
  }

  Response _localPut(String path, dynamic data) {
    final segments = path.split('/');
    final resource = segments.first;
    final id = segments.length > 1 ? segments[1] : '';
    final list = _localData.putIfAbsent(resource, () => []);

    final item = Map<String, dynamic>.from(data as Map);
    item['id'] = id;

    final index =
        list.indexWhere((element) => element['id'].toString() == id);
    if (index != -1) {
      list[index] = item;
    } else {
      list.add(item);
    }

    return Response(
      requestOptions: RequestOptions(path: path),
      data: Map<String, dynamic>.from(item),
      statusCode: 200,
    );
  }

  Response _localDelete(String path) {
    final segments = path.split('/');
    final resource = segments.first;
    final id = segments.length > 1 ? segments[1] : '';
    final list = _localData.putIfAbsent(resource, () => []);

    final index =
        list.indexWhere((element) => element['id'].toString() == id);
    final item = index != -1
        ? list.removeAt(index)
        : <String, dynamic>{'id': id};

    return Response(
      requestOptions: RequestOptions(path: path),
      data: Map<String, dynamic>.from(item),
      statusCode: 200,
    );
  }
}
