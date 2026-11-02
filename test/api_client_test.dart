import 'package:flutter_test/flutter_test.dart';
import 'package:klinik_apps/helpers/api_client.dart';

void main() {
  setUpAll(() {
    // Arahkan ke alamat yang pasti gagal agar fallback data lokal yang diuji.
    dio.options.baseUrl = 'http://127.0.0.1:9/';
  });

  test('CRUD data lokal saat API tidak tersedia', () async {
    final client = ApiClient();

    final listResponse = await client.get('poli');
    final list = listResponse.data as List;
    expect(list.isNotEmpty, isTrue);

    final createResponse =
        await client.post('poli', {'nama_poli': 'Poli Jiwa'});
    expect(createResponse.data['nama_poli'], 'Poli Jiwa');

    final id = createResponse.data['id'].toString();

    final detailResponse = await client.get('poli/$id');
    expect(detailResponse.data['nama_poli'], 'Poli Jiwa');

    final updateResponse =
        await client.put('poli/$id', {'nama_poli': 'Poli Jiwa Updated'});
    expect(updateResponse.data['nama_poli'], 'Poli Jiwa Updated');

    final deleteResponse = await client.delete('poli/$id');
    expect(deleteResponse.data['id'], id);

    final afterDeleteResponse = await client.get('poli');
    final afterDelete = afterDeleteResponse.data as List;
    expect(afterDelete.any((item) => item['id'].toString() == id), isFalse);
  });
}
