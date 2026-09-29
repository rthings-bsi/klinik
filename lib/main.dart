import 'package:flutter/material.dart';
import 'helpers/luxury_theme.dart';
import 'helpers/user_info.dart';
import 'ui/beranda.dart';
import 'ui/login.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final token = await UserInfo().getToken();
  runApp(KlinikApp(isLoggedIn: token != null && token.isNotEmpty));
}

class KlinikApp extends StatelessWidget {
  final bool isLoggedIn;

  const KlinikApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Klinik App",
      debugShowCheckedModeBanner: false,
      theme: LuxuryTheme.lightTheme,
      home: isLoggedIn ? const Beranda() : const Login(),
    );
  }
}
