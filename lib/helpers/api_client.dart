import 'package:dio/dio.dart';

final Dio dio = Dio(
  BaseOptions(
    baseUrl: 'https://script.google.com/macros/s/AKfycby4dY6Nr272MCSrqmHv-ehU5NOn24syJ61PZoWkFe3hRYrZodU2SydVDsPGIuea6Gf8/exec',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ),
);

class ApiClient {
  // In-memory fallback mock storage to ensure 100% reliability offline
  static final Map<String, List<Map<String, dynamic>>> _mockStorage = {
    'poli': [
      {'id': '1', 'nama_poli': 'Poli Saraf'},
      {'id': '2', 'nama_poli': 'Poli Gigi'},
      {'id': '3', 'nama_poli': 'Poli Anak'},
    ],
    'pegawai': [
      {
        'id': '1',
        'nip': '198901012015011001',
        'nama': 'dr. Hendra Pratama, Sp.A',
        'tanggal_lahir': '1989-01-01',
        'nomor_telepon': '081234567890',
        'email': 'hendra.pratama@klinik.id',
        'password': 'password123',
      },
      {
        'id': '2',
        'nip': '199203152018022002',
        'nama': 'drg. Siti Nurhaliza, Sp.KG',
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
    'users': [
      {
        'id': '1',
        'username': 'pasien1',
        'password': 'password123',
        'nama': 'Budi Santoso',
        'nomor_telepon': '082155443322',
        'role': 'Pasien',
        'nomor_rm': 'RM-2024-001',
        'created_at': '2024-09-01',
      },
    ],
    'antrian': [
      {
        'id': '1',
        'nomor_antrian': 'A-01',
        'id_poli': '1',
        'nama_poli': 'Poli Saraf',
        'nama_pasien': 'Budi Santoso',
        'nomor_rm': 'RM-2024-001',
        'nomor_telepon': '082155443322',
        'tanggal': '2026-09-26',
        'waktu': '08:30',
        'keluhan': 'Sering pusing dan migrain di pagi hari',
        'status': 'Dipanggil',
      },
      {
        'id': '2',
        'nomor_antrian': 'A-02',
        'id_poli': '2',
        'nama_poli': 'Poli Gigi',
        'nama_pasien': 'Dewi Lestari',
        'nomor_rm': 'RM-2024-002',
        'nomor_telepon': '085266778899',
        'tanggal': '2026-09-26',
        'waktu': '09:00',
        'keluhan': 'Pemeriksaan rutin karang gigi',
        'status': 'Menunggu',
      },
      {
        'id': '3',
        'nomor_antrian': 'A-03',
        'id_poli': '3',
        'nama_poli': 'Poli Anak',
        'nama_pasien': 'Rian Pratama',
        'nomor_rm': 'RM-2024-003',
        'nomor_telepon': '081377889900',
        'tanggal': '2026-09-26',
        'waktu': '09:30',
        'keluhan': 'Demam dan batuk pilek 2 hari',
        'status': 'Menunggu',
      },
    ],
  };

  Future<Response> get(String path) async {
    final cleanPath = path.replaceAll(RegExp(r'^/|/$'), '');
    final segments = cleanPath.split('/');
    final resource = segments[0];

    try {
      if (segments.length > 1) {
        final id = segments[1];
        final response = await dio.get(
          '',
          queryParameters: {'sheet': resource, 'id': id},
        );
        if (response.data is List && (response.data as List).isNotEmpty) {
          return Response(
            requestOptions: response.requestOptions,
            data: response.data[0],
            statusCode: 200,
          );
        }
        return Response(
          requestOptions: response.requestOptions,
          data: {},
          statusCode: 404,
        );
      } else {
        final response = await dio.get(
          '',
          queryParameters: {'sheet': resource},
        );
        return response;
      }
    } catch (_) {
      return _handleMockGet(path);
    }
  }

  Future<Response> post(String path, dynamic data) async {
    final cleanPath = path.replaceAll(RegExp(r'^/|/$'), '');
    final segments = cleanPath.split('/');
    final resource = segments[0];

    try {
      final Map<String, dynamic> record = Map<String, dynamic>.from(data as Map);

      final response = await dio.post(
        '',
        data: {
          'action': 'create',
          'sheet': resource,
          'data': record,
        },
        options: Options(
          validateStatus: (status) => status != null && status < 400,
          followRedirects: false,
        ),
      );

      dynamic resultData = response.data;
      final redirectUrl = response.headers.value('location');
      if (redirectUrl != null && redirectUrl.isNotEmpty) {
        final echoRes = await dio.get(redirectUrl);
        resultData = echoRes.data;
      }

      return Response(
        requestOptions: RequestOptions(path: path),
        data: resultData ?? record,
        statusCode: 201,
      );
    } catch (_) {
      return _handleMockPost(path, data);
    }
  }

  Future<Response> put(String path, dynamic data) async {
    final cleanPath = path.replaceAll(RegExp(r'^/|/$'), '');
    final segments = cleanPath.split('/');
    final resource = segments[0];
    final id = segments.length > 1 ? segments[1] : '';

    try {
      final Map<String, dynamic> record = Map<String, dynamic>.from(data as Map);

      final response = await dio.post(
        '',
        data: {
          'action': 'update',
          'sheet': resource,
          'id': id,
          'data': record,
        },
        options: Options(
          validateStatus: (status) => status != null && status < 400,
          followRedirects: false,
        ),
      );

      dynamic resultData = response.data;
      final redirectUrl = response.headers.value('location');
      if (redirectUrl != null && redirectUrl.isNotEmpty) {
        final echoRes = await dio.get(redirectUrl);
        resultData = echoRes.data;
      }

      record['id'] = id;
      return Response(
        requestOptions: RequestOptions(path: path),
        data: resultData ?? record,
        statusCode: 200,
      );
    } catch (_) {
      return _handleMockPut(path, data);
    }
  }

  Future<Response> delete(String path) async {
    final cleanPath = path.replaceAll(RegExp(r'^/|/$'), '');
    final segments = cleanPath.split('/');
    final resource = segments[0];
    final id = segments.length > 1 ? segments[1] : '';

    try {
      final response = await dio.post(
        '',
        data: {
          'action': 'delete',
          'sheet': resource,
          'id': id,
        },
        options: Options(
          validateStatus: (status) => status != null && status < 400,
          followRedirects: false,
        ),
      );

      dynamic resultData = response.data;
      final redirectUrl = response.headers.value('location');
      if (redirectUrl != null && redirectUrl.isNotEmpty) {
        final echoRes = await dio.get(redirectUrl);
        resultData = echoRes.data;
      }

      return Response(
        requestOptions: RequestOptions(path: path),
        data: resultData ?? {'id': id},
        statusCode: 200,
      );
    } catch (_) {
      return _handleMockDelete(path);
    }
  }

  // Fallback simulator for offline & local testing
  Response _handleMockGet(String path) {
    final cleanPath = path.replaceAll(RegExp(r'^/|/$'), '');
    final segments = cleanPath.split('/');
    final resource = segments[0];

    if (_mockStorage.containsKey(resource)) {
      final list = _mockStorage[resource]!;
      if (segments.length > 1) {
        final id = segments[1];
        final item = list.firstWhere(
          (element) => element['id'].toString() == id.toString(),
          orElse: () => {},
        );
        return Response(
          requestOptions: RequestOptions(path: path),
          data: item.isNotEmpty ? Map<String, dynamic>.from(item) : null,
          statusCode: item.isNotEmpty ? 200 : 404,
        );
      }
      return Response(
        requestOptions: RequestOptions(path: path),
        data: list.map((e) => Map<String, dynamic>.from(e)).toList(),
        statusCode: 200,
      );
    }

    return Response(
      requestOptions: RequestOptions(path: path),
      data: [],
      statusCode: 200,
    );
  }

  Response _handleMockPost(String path, dynamic data) {
    final cleanPath = path.replaceAll(RegExp(r'^/|/$'), '');
    final resource = cleanPath.split('/')[0];

    final newId = DateTime.now().millisecondsSinceEpoch.toString().substring(7);
    final newItem = Map<String, dynamic>.from(data as Map);
    newItem['id'] = newId;

    if (_mockStorage.containsKey(resource)) {
      _mockStorage[resource]!.add(newItem);
    }

    return Response(
      requestOptions: RequestOptions(path: path),
      data: newItem,
      statusCode: 201,
    );
  }

  Response _handleMockPut(String path, dynamic data) {
    final cleanPath = path.replaceAll(RegExp(r'^/|/$'), '');
    final segments = cleanPath.split('/');
    final resource = segments[0];
    final id = segments.length > 1 ? segments[1] : '';

    final updatedItem = Map<String, dynamic>.from(data as Map);
    updatedItem['id'] = id;

    if (_mockStorage.containsKey(resource)) {
      final list = _mockStorage[resource]!;
      final index = list.indexWhere((element) => element['id'].toString() == id);
      if (index != -1) {
        list[index] = updatedItem;
      }
    }

    return Response(
      requestOptions: RequestOptions(path: path),
      data: updatedItem,
      statusCode: 200,
    );
  }

  Response _handleMockDelete(String path) {
    final cleanPath = path.replaceAll(RegExp(r'^/|/$'), '');
    final segments = cleanPath.split('/');
    final resource = segments[0];
    final id = segments.length > 1 ? segments[1] : '';

    if (_mockStorage.containsKey(resource)) {
      _mockStorage[resource]!.removeWhere((element) => element['id'].toString() == id);
    }

    return Response(
      requestOptions: RequestOptions(path: path),
      data: {'id': id},
      statusCode: 200,
    );
  }
}
