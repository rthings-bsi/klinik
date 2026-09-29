import 'package:flutter/material.dart';
import '../helpers/luxury_theme.dart';
import '../service/login_service.dart';
import '../widget/smooth_page_route.dart';
import '../widget/staggered_entrance.dart';
import '../widget/aesthetic_background.dart';
import 'beranda.dart';
import 'register_page.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController(text: "admin");
  final _passwordCtrl = TextEditingController(text: "admin");
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LuxuryTheme.alabaster,
      body: AestheticBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 24.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                    StaggeredEntrance(
                      index: 0,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: LuxuryTheme.pureWhite,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: LuxuryTheme.charcoal.withValues(alpha: 0.08),
                            width: 1.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: LuxuryTheme.charcoal.withValues(alpha: 0.06),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(19),
                          child: Image.asset(
                            'assets/images/logo.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    StaggeredEntrance(
                      index: 1,
                      child: Column(
                        children: [
                          const Text(
                            "Klinik App",
                            style: TextStyle(
                              fontFamily: 'serif',
                              fontSize: 32,
                              fontWeight: FontWeight.w400,
                              color: LuxuryTheme.charcoal,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 24,
                                height: 1.0,
                                color: LuxuryTheme.metallicGold,
                              ),
                              const SizedBox(width: 10),
                              const Flexible(
                                child: Text(
                                  "SISTEM MANAJEMEN KLINIK",
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: LuxuryTheme.warmGrey,
                                    letterSpacing: 2.2,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                width: 24,
                                height: 1.0,
                                color: LuxuryTheme.metallicGold,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    StaggeredEntrance(
                      index: 2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 26.0, vertical: 28.0),
                        decoration: BoxDecoration(
                          color: LuxuryTheme.pureWhite,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: LuxuryTheme.charcoal.withValues(alpha: 0.08),
                            width: 1.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: LuxuryTheme.charcoal.withValues(alpha: 0.04),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                            BoxShadow(
                              color: LuxuryTheme.charcoal.withValues(alpha: 0.02),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _usernameTextField(),
                            const SizedBox(height: 20),
                            _passwordTextField(),
                            const SizedBox(height: 30),
                            _tombolLogin(),
                            const SizedBox(height: 14),
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: LuxuryTheme.charcoal,
                                side: BorderSide(
                                  color: LuxuryTheme.charcoal.withValues(alpha: 0.2),
                                  width: 1.0,
                                ),
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  SmoothPageRoute(page: const RegisterPage()),
                                );
                              },
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.person_add_outlined, size: 16),
                                  SizedBox(width: 8),
                                  Text(
                                    "Daftar Akun Baru",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        ),
      ),
    );
  }

  Widget _usernameTextField() {
    return TextFormField(
      controller: _usernameCtrl,
      style: const TextStyle(color: LuxuryTheme.charcoal, fontSize: 14.5),
      decoration: InputDecoration(
        labelText: "Username",
        hintText: "Username, NIP, atau Email",
        prefixIcon: const Icon(Icons.person_outline_rounded, color: LuxuryTheme.charcoal, size: 20),
        filled: true,
        fillColor: LuxuryTheme.alabaster.withValues(alpha: 0.7),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: LuxuryTheme.charcoal.withValues(alpha: 0.1), width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: LuxuryTheme.charcoal.withValues(alpha: 0.12), width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: LuxuryTheme.charcoal, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: LuxuryTheme.crimson, width: 1.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: LuxuryTheme.crimson, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return "Username tidak boleh kosong";
        }
        return null;
      },
    );
  }

  Widget _passwordTextField() {
    return TextFormField(
      controller: _passwordCtrl,
      obscureText: _obscurePassword,
      style: const TextStyle(color: LuxuryTheme.charcoal, fontSize: 14.5),
      decoration: InputDecoration(
        labelText: "Password",
        hintText: "Masukkan password",
        prefixIcon: const Icon(Icons.lock_outline_rounded, color: LuxuryTheme.charcoal, size: 20),
        filled: true,
        fillColor: LuxuryTheme.alabaster.withValues(alpha: 0.7),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: LuxuryTheme.charcoal.withValues(alpha: 0.1), width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: LuxuryTheme.charcoal.withValues(alpha: 0.12), width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: LuxuryTheme.charcoal, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: LuxuryTheme.crimson, width: 1.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: LuxuryTheme.crimson, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: LuxuryTheme.warmGrey,
            size: 20,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return "Password tidak boleh kosong";
        }
        return null;
      },
    );
  }

  Widget _tombolLogin() {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: LuxuryTheme.charcoal,
          foregroundColor: LuxuryTheme.pureWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 2,
        ),
        onPressed: _isLoading
            ? null
            : () async {
                if (_formKey.currentState!.validate()) {
                  setState(() {
                    _isLoading = true;
                  });

                  final username = _usernameCtrl.text.trim();
                  final password = _passwordCtrl.text.trim();

                  final success = await LoginService().login(username, password);

                  setState(() {
                    _isLoading = false;
                  });

                  if (!mounted) return;

                  if (success) {
                    Navigator.pushReplacement(
                      context,
                      SmoothPageRoute(page: const Beranda()),
                    );
                  } else {
                    showDialog(
                      context: context,
                      builder: (dialogCtx) => AlertDialog(
                        backgroundColor: LuxuryTheme.pureWhite,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: LuxuryTheme.charcoal.withValues(alpha: 0.1),
                            width: 1.0,
                          ),
                        ),
                        title: const Text("Gagal Masuk"),
                        content: const Text("Username atau password yang dimasukkan salah."),
                        actions: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: LuxuryTheme.charcoal,
                              foregroundColor: LuxuryTheme.pureWhite,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () => Navigator.pop(dialogCtx),
                            child: const Text("Tutup"),
                          ),
                        ],
                      ),
                    );
                  }
                }
              },
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(color: LuxuryTheme.pureWhite, strokeWidth: 2),
              )
            : const Text(
                "Masuk",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2.0,
                ),
              ),
      ),
    );
  }
}
