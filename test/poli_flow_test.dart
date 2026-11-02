import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klinik_apps/helpers/api_client.dart';
import 'package:klinik_apps/ui/poli_page.dart';

void main() {
  setUpAll(() {
    ApiClient.offline = true;
  });

  testWidgets('Daftar dan detail poli tampil dari data lokal',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: PoliPage()));
    await tester.pump();
    await tester.pump();

    expect(find.text('Poli Anak'), findsOneWidget);
    expect(find.text('Poli Gigi'), findsOneWidget);

    await tester.tap(find.text('Poli Anak'));
    await tester.pump();
    await tester.pump();

    expect(find.text('Detail Poli'), findsOneWidget);
    expect(find.text('Nama Poli : Poli Anak'), findsOneWidget);
    expect(find.text('Ubah'), findsOneWidget);
    expect(find.text('Hapus'), findsOneWidget);
  });

  testWidgets('Tambah poli lalu kembali ke daftar',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: PoliPage()));
    await tester.pump();
    await tester.pump();

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Poli Jiwa');
    await tester.tap(find.text('Simpan'));
    await tester.pump();
    await tester.pump();

    expect(find.text('Detail Poli'), findsOneWidget);
    expect(find.text('Nama Poli : Poli Jiwa'), findsOneWidget);

    await tester.tap(find.byTooltip('Back').last);
    await tester.pumpAndSettle();

    expect(find.text('Poli Jiwa'), findsOneWidget);
  });
}
