import 'package:flutter/material.dart';
import 'helpers/app_colors.dart';
import 'helpers/user_info.dart';
import 'ui/beranda.dart';
import 'ui/login.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var token = await UserInfo().getToken();
  final skemaWarna = ColorScheme.fromSeed(seedColor: AppColors.biru).copyWith(
    primary: AppColors.biru,
    onPrimary: Colors.white,
  );
  runApp(MaterialApp(
    title: "Klinik APP",
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: skemaWarna,
      appBarTheme: AppBarTheme(
        backgroundColor: skemaWarna.primary,
        foregroundColor: skemaWarna.onPrimary,
      ),
    ),
    home: token == null ? const Login() : const Beranda(),
  ));
}
