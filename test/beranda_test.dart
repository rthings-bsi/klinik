import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klinik_apps/helpers/api_client.dart';
import 'package:klinik_apps/ui/beranda.dart';

void main() {
  setUpAll(() {
    ApiClient.offline = true;
  });

  testWidgets('Beranda menampilkan ringkasan dari data yang tersedia',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: Beranda()));
    await tester.pump();
    await tester.pump();
    await tester.pump();

    expect(find.text('Beranda'), findsOneWidget);
    expect(find.text('Pasien terdaftar'), findsOneWidget);
    // 2 pasien dan 2 pegawai sama-sama bernilai 2, 4 poli.
    expect(find.text('2'), findsNWidgets(2));
    expect(find.text('4'), findsOneWidget);
    expect(find.text('Data pendukung'), findsOneWidget);
    expect(find.text('Pasien terbaru'), findsOneWidget);
    expect(find.text('Dewi Lestari'), findsOneWidget);
    expect(find.text('Budi Santoso'), findsOneWidget);
  });

  testWidgets('Baris modul Poli membuka halaman Data Poli',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: Beranda()));
    await tester.pump();
    await tester.pump();

    await tester.tap(find.text('Poli'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();

    expect(find.text('Data Poli'), findsOneWidget);
    expect(find.text('Poli Anak'), findsOneWidget);
  });

  testWidgets('Baris pasien membuka detail pasien',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: Beranda()));
    await tester.pump();
    await tester.pump();

    await tester.tap(find.text('Budi Santoso'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();

    expect(find.text('Detail Pasien'), findsOneWidget);
    expect(find.text('Nomor RM'), findsOneWidget);
    expect(find.text('Hapus'), findsOneWidget);
  });

  testWidgets('Tata letak beranda aman di layar sempit',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: Beranda()));
    await tester.pump();
    await tester.pump();

    // Melubernya layout akan melempar RenderFlex overflow, jadi tidak ada
    // exception berarti tata letaknya masih utuh di 320 px.
    expect(tester.takeException(), isNull);
    expect(find.text('Pasien terdaftar'), findsOneWidget);
    expect(find.text('Budi Santoso'), findsOneWidget);
  });
}
