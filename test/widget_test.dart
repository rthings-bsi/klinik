import 'package:flutter/material.dart';
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
import 'package:klinik_app/service/user_service.dart';
import 'package:klinik_app/service/antrian_service.dart';
import 'package:klinik_app/widget/elegant_navbar.dart';
import 'package:klinik_app/helpers/poli_helper.dart';
import 'package:klinik_app/ui/poli_item.dart';
import 'package:klinik_app/service/login_service.dart';
import 'package:klinik_app/ui/beranda.dart';

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

  group('ElegantNavBar Widget Tests', () {
    testWidgets('renders all navigation items and responds to taps',
        (WidgetTester tester) async {
      int selectedIndex = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: StatefulBuilder(
              builder: (context, setState) {
                return ElegantNavBar(
                  currentIndex: selectedIndex,
                  onTap: (index) {
                    setState(() => selectedIndex = index);
                  },
                  items: const [
                    NavBarItem(
                      icon: Icons.home_outlined,
                      activeIcon: Icons.home_rounded,
                      label: "Beranda",
                    ),
                    NavBarItem(
                      icon: Icons.confirmation_number_outlined,
                      activeIcon: Icons.confirmation_number_rounded,
                      label: "Antrian",
                    ),
                    NavBarItem(
                      icon: Icons.meeting_room_outlined,
                      activeIcon: Icons.meeting_room_rounded,
                      label: "Poli",
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text("Beranda"), findsOneWidget);
      expect(find.text("Antrian"), findsOneWidget);
      expect(find.text("Poli"), findsOneWidget);

      await tester.tap(find.text("Antrian"));
      await tester.pumpAndSettle();

      expect(selectedIndex, 1);
    });
  });

  group('PoliItem & PoliHelper UI Tests', () {
    test('PoliHelper correctly maps medical specialties and metadata', () {
      final sarafMeta = PoliHelper.getMeta('Poli Saraf');
      expect(sarafMeta.category, 'Spesialis Saraf');
      expect(sarafMeta.icon, Icons.psychology_rounded);

      final gigiMeta = PoliHelper.getMeta('Poli Gigi');
      expect(gigiMeta.category, 'Kesehatan Gigi & Mulut');
      expect(gigiMeta.icon, Icons.health_and_safety_rounded);

      final anakMeta = PoliHelper.getMeta('Poli Anak');
      expect(anakMeta.category, 'Spesialis Anak (Pediatri)');
      expect(anakMeta.icon, Icons.child_care_rounded);

      final umumMeta = PoliHelper.getMeta('Poli Umum');
      expect(umumMeta.category, 'Pelayanan Medis Umum');
      expect(umumMeta.icon, Icons.medical_services_rounded);
    });

    testWidgets('PoliItem renders specialty category and location without raw hash clutter',
        (WidgetTester tester) async {
      final testPoli = Poli(id: '1', namaPoli: 'Poli Saraf');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PoliItem(poli: testPoli),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Poli Saraf'), findsOneWidget);
      expect(find.text('Spesialis Saraf'), findsOneWidget);
      expect(find.text('#1'), findsOneWidget);
      expect(find.byIcon(Icons.psychology_rounded), findsOneWidget);
    });
  });

  group('LoginService Multi-Role Authentication Tests', () {
    test('Admin superuser login succeeds', () async {
      final loginService = LoginService();
      final success = await loginService.login('admin', 'admin');
      expect(success, true);
      expect(await UserInfo().isAdmin(), true);
      expect(await UserInfo().getRole(), 'Admin');
    });

    test('Pegawai can login using NIP or Email and password', () async {
      final pegawaiService = PegawaiService();
      final testPegawai = Pegawai(
        nip: '199505052026',
        nama: 'Dr. Budi Santoso',
        tanggalLahir: '1995-05-05',
        nomorTelepon: '08123456789',
        email: 'budi.dokter@klinik.id',
        password: 'dokterpass123',
      );
      await pegawaiService.simpan(testPegawai);

      final loginService = LoginService();
      // Test login via NIP
      final loginNip = await loginService.login('199505052026', 'dokterpass123');
      expect(loginNip, true);
      expect(await UserInfo().isAdmin(), true);
      expect(await UserInfo().getNama(), 'Dr. Budi Santoso');

      // Test login via Email
      final loginEmail = await loginService.login('budi.dokter@klinik.id', 'dokterpass123');
      expect(loginEmail, true);
      expect(await UserInfo().isAdmin(), true);
    });
  });

  group('Beranda Minimalist UI & RBAC Tests', () {
    testWidgets('Beranda renders Admin dashboard elements properly',
        (WidgetTester tester) async {
      await UserInfo().setRole('Admin');
      await UserInfo().setUsername('admin');
      await UserInfo().setNama('Administrator');

      await tester.pumpWidget(
        const MaterialApp(
          home: Beranda(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Klinik Pratama Medika'), findsOneWidget);
      expect(find.text('Selamat Bertugas, Administrator'), findsOneWidget);
      expect(find.text('MONITOR ANTRIAN KLINIK'), findsOneWidget);
      expect(find.text('AKSI CEPAT'), findsOneWidget);
      expect(find.text('RINGKASAN DATA'), findsOneWidget);
    });

    testWidgets('Beranda renders Pasien dashboard elements properly',
        (WidgetTester tester) async {
      await UserInfo().setRole('Pasien');
      await UserInfo().setUsername('siti');
      await UserInfo().setNama('Siti Aminah');
      await UserInfo().setNomorRm('RM-2026-001');

      await tester.pumpWidget(
        const MaterialApp(
          home: Beranda(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Klinik Pratama Medika'), findsOneWidget);
      expect(find.text('Halo Sehat, Siti Aminah'), findsOneWidget);
      expect(find.text('AKSI CEPAT'), findsOneWidget);
      expect(find.text('RINGKASAN DATA'), findsOneWidget);
      expect(find.text('Ambil Nomor Antrian'), findsOneWidget);
    });
  });
}
