import 'package:flutter_test/flutter_test.dart';
import 'package:klinik_app/main.dart';
import 'package:klinik_app/model/poli.dart';
import 'package:klinik_app/model/pegawai.dart';
import 'package:klinik_app/model/pasien.dart';
import 'package:klinik_app/model/user.dart';
import 'package:klinik_app/model/antrian.dart';
import 'package:klinik_app/service/poli_service.dart';
import 'package:klinik_app/service/pegawai_service.dart';
import 'package:klinik_app/service/pasien_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:klinik_app/helpers/user_info.dart';
import 'package:klinik_app/service/login_service.dart';
import 'package:klinik_app/service/user_service.dart';
import 'package:klinik_app/service/antrian_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });
  testWidgets('KlinikApp smoke test - renders Login screen when logged out',
      (WidgetTester tester) async {
    await tester.pumpWidget(const KlinikApp(isLoggedIn: false));
    await tester.pumpAndSettle();

    expect(find.text('Klinik App'), findsWidgets);
    expect(find.text('Masuk'), findsOneWidget);
    expect(find.text('Username'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
  });

  group('Poli Service & Model Tests', () {
    test('Poli serialization to/from JSON', () {
      final json = {'id': '10', 'nama_poli': 'Poli Mata'};
      final poli = Poli.fromJson(json);
      expect(poli.id, '10');
      expect(poli.namaPoli, 'Poli Mata');

      final serialized = poli.toJson();
      expect(serialized['nama_poli'], 'Poli Mata');
    });

    test('Poli Service CRUD operations', () async {
      final service = PoliService();
      final list = await service.listData();
      expect(list.isNotEmpty, true);

      final newPoli = await service.simpan(Poli(namaPoli: 'Poli Saraf'));
      expect(newPoli.namaPoli, 'Poli Saraf');

      final fetched = await service.getById(newPoli.id!);
      expect(fetched.namaPoli, 'Poli Saraf');

      final updated = await service.ubah(
        Poli(id: newPoli.id, namaPoli: 'Poli Saraf & Bedah'),
        newPoli.id!,
      );
      expect(updated.namaPoli, 'Poli Saraf & Bedah');

      await service.hapus(updated);
    });
  });

  group('Pegawai Service & Model Tests', () {
    test('Pegawai serialization to/from JSON', () {
      final json = {
        'id': '99',
        'nip': '19901010',
        'nama': 'Dr. Test',
        'tanggal_lahir': '1990-10-10',
        'nomor_telepon': '081234',
        'email': 'test@klinik.id',
        'password': 'secret',
      };
      final pegawai = Pegawai.fromJson(json);
      expect(pegawai.nama, 'Dr. Test');
      expect(pegawai.nip, '19901010');
    });

    test('Pegawai Service CRUD operations', () async {
      final service = PegawaiService();
      final list = await service.listData();
      expect(list.isNotEmpty, true);

      final created = await service.simpan(Pegawai(
        nip: '19990101',
        nama: 'Apoteker Rani',
        tanggalLahir: '1999-01-01',
        nomorTelepon: '081299998888',
        email: 'rani@klinik.id',
        password: 'pass',
      ));
      expect(created.nama, 'Apoteker Rani');
    });
  });

  group('Pasien Service & Model Tests', () {
    test('Pasien serialization to/from JSON', () {
      final json = {
        'id': '101',
        'nomor_rm': 'RM-001',
        'nama': 'Pasien Satu',
        'tanggal_lahir': '2001-01-01',
        'nomor_telepon': '0812001',
        'alamat': 'Jl. Khatulistiwa',
      };
      final pasien = Pasien.fromJson(json);
      expect(pasien.nomorRm, 'RM-001');
      expect(pasien.nama, 'Pasien Satu');
    });

    test('Pasien Service CRUD operations', () async {
      final service = PasienService();
      final list = await service.listData();
      expect(list.isNotEmpty, true);

      final created = await service.simpan(Pasien(
        nomorRm: 'RM-2024-999',
        nama: 'Pasien Test',
        tanggalLahir: '2000-01-01',
        nomorTelepon: '08999999999',
        alamat: 'Pontianak',
      ));
      expect(created.nama, 'Pasien Test');
    });
  });

  group('User Registration & Model Tests', () {
    test('User serialization to/from JSON', () {
      final json = {
        'id': '50',
        'username': 'user_test',
        'password': 'password123',
        'nama': 'User Penguji',
        'nomor_telepon': '08123456789',
        'role': 'Pasien',
        'nomor_rm': 'RM-TEST',
      };
      final user = User.fromJson(json);
      expect(user.username, 'user_test');
      expect(user.nama, 'User Penguji');
      expect(user.role, 'Pasien');
    });

    test('User Registration and Authentication', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      final service = UserService();
      final regUser = User(
        username: 'pasien_baru_${DateTime.now().millisecondsSinceEpoch}',
        password: 'password123',
        nama: 'Pasien Baru',
        nomorTelepon: '08129999999',
      );
      final registered = await service.register(regUser);
      expect(registered.username, regUser.username);

      final auth = await service.authenticate(regUser.username, 'password123');
      expect(auth != null, true);
      expect(auth!.nama, 'Pasien Baru');
    });
  });

  group('Antrian Service & Model Tests', () {
    test('Antrian serialization to/from JSON', () {
      final json = {
        'id': '10',
        'nomor_antrian': 'A-01',
        'id_poli': '1',
        'nama_poli': 'Poli Saraf',
        'nama_pasien': 'Pasien Antrian',
        'nomor_rm': 'RM-001',
        'nomor_telepon': '081234',
        'tanggal': '2026-09-26',
        'waktu': '08:30',
        'keluhan': 'Pusing',
        'status': 'Menunggu',
      };
      final antrian = Antrian.fromJson(json);
      expect(antrian.nomorAntrian, 'A-01');
      expect(antrian.namaPoli, 'Poli Saraf');
      expect(antrian.status, 'Menunggu');
    });

    test('Antrian Service CRUD & Status Update', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      final service = AntrianService();
      final list = await service.listData();
      expect(list.isNotEmpty, true);

      final newAntrian = await service.simpan(Antrian(
        nomorAntrian: '',
        idPoli: '1',
        namaPoli: 'Poli Saraf',
        namaPasien: 'Pasien Test Antrian',
        nomorRm: 'RM-2024-999',
        nomorTelepon: '0812334455',
        tanggal: '2026-09-26',
        waktu: '10:00',
        keluhan: 'Pemeriksaan rutin saraf',
      ));
      expect(newAntrian.nomorAntrian.isNotEmpty, true);

      final updated = await service.ubahStatus(newAntrian.id!, 'Dipanggil');
      expect(updated.status, 'Dipanggil');
    });
  });

  group('Role-Based Access Control (RBAC) Tests', () {
    test('UserInfo role detection for Admin and Pasien', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      final userInfo = UserInfo();

      // Test Admin Role
      await userInfo.setRole('Admin');
      await userInfo.setUsername('admin');
      expect(await userInfo.isAdmin(), true);
      expect(await userInfo.isPasien(), false);
      expect(await userInfo.getRole(), 'Admin');

      // Test Pasien Role
      await userInfo.setRole('Pasien');
      await userInfo.setUsername('pasien01');
      await userInfo.setNama('Siti Aminah');
      await userInfo.setNomorTelepon('0812345678');
      await userInfo.setNomorRm('RM-2026-001');

      expect(await userInfo.isAdmin(), false);
      expect(await userInfo.isPasien(), true);
      expect(await userInfo.getRole(), 'Pasien');
      expect(await userInfo.getNama(), 'Siti Aminah');
      expect(await userInfo.getNomorTelepon(), '0812345678');
      expect(await userInfo.getNomorRm(), 'RM-2026-001');
    });
  });
}
