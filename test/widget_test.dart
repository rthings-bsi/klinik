import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:klinik_apps/ui/login.dart';

void main() {
  testWidgets('Halaman login tampil', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: Login()));

    expect(find.text('Login Admin'), findsOneWidget);
    expect(find.text('Username'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });
}
