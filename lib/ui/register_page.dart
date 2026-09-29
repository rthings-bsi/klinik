import 'package:flutter/material.dart';
import '../helpers/luxury_theme.dart';
import '../model/user.dart';
import '../service/user_service.dart';
import '../widget/animated_pressable.dart';
import '../widget/staggered_entrance.dart';
import '../widget/aesthetic_background.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _namaCtrl = TextEditingController();
  final _nomorTeleponCtrl = TextEditingController();
  final _nomorRmCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _namaCtrl.dispose();
    _nomorTeleponCtrl.dispose();
    _nomorRmCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordCtrl.text.trim() != _confirmPasswordCtrl.text.trim()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: LuxuryTheme.crimson,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: const Text("Konfirmasi password tidak cocok."),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final newUser = User(
        username: _usernameCtrl.text.trim(),
        nama: _namaCtrl.text.trim(),
        nomorTelepon: _nomorTeleponCtrl.text.trim(),
        nomorRm: _nomorRmCtrl.text.trim().isNotEmpty ? _nomorRmCtrl.text.trim() : null,
        password: _passwordCtrl.text.trim(),
        role: "Pasien",
      );

      await UserService().register(newUser);

      if (!mounted) return;
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: LuxuryTheme.charcoal,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: const Text("Akun berhasil didaftarkan. Silakan masuk."),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: LuxuryTheme.crimson,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Text(e.toString().replaceAll("Exception: ", "")),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LuxuryTheme.alabaster,
      appBar: AppBar(
        title: const Text("Pendaftaran Akun"),
      ),
      body: AestheticBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                // Header Card
                StaggeredEntrance(
                  index: 0,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: LuxuryTheme.pureWhite,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: LuxuryTheme.charcoal.withValues(alpha: 0.08),
                        width: 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: LuxuryTheme.charcoal.withValues(alpha: 0.04),
                          blurRadius: 18,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: LuxuryTheme.paleTaupe.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: LuxuryTheme.charcoal.withValues(alpha: 0.1),
                              width: 1.0,
                            ),
                          ),
                          child: const Icon(
                            Icons.person_add_rounded,
                            color: LuxuryTheme.charcoal,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                "Registrasi Pasien Baru",
                                style: TextStyle(
                                  fontFamily: 'serif',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: LuxuryTheme.charcoal,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Daftarkan akun untuk antrian & layanan klinik",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: LuxuryTheme.warmGrey,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Form Card
                StaggeredEntrance(
                  index: 1,
                  child: Container(
                    padding: const EdgeInsets.all(24),
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
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _textField(
                            controller: _usernameCtrl,
                            label: "Username",
                            hint: "Contoh: budi_santoso",
                            icon: Icons.alternate_email_rounded,
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return "Username wajib diisi";
                              }
                              if (val.trim().length < 3) {
                                return "Username minimal 3 karakter";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _textField(
                            controller: _namaCtrl,
                            label: "Nama Lengkap",
                            hint: "Nama sesuai identitas KTP",
                            icon: Icons.badge_outlined,
                            validator: (val) =>
                                val == null || val.trim().isEmpty ? "Nama lengkap wajib diisi" : null,
                          ),
                          const SizedBox(height: 16),
                          _textField(
                            controller: _nomorTeleponCtrl,
                            label: "Nomor WhatsApp / HP",
                            hint: "Contoh: 081234567890",
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return "Nomor HP wajib diisi";
                              }
                              if (val.trim().length < 8) {
                                return "Nomor HP minimal 8 digit";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _textField(
                            controller: _nomorRmCtrl,
                            label: "Nomor RM (Opsional)",
                            hint: "Kosongkan jika pasien baru",
                            icon: Icons.medical_information_outlined,
                          ),
                          const SizedBox(height: 16),
                          _passwordField(
                            controller: _passwordCtrl,
                            label: "Kata Sandi",
                            isObscure: _obscurePassword,
                            onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return "Kata sandi wajib diisi";
                              }
                              if (val.length < 5) {
                                return "Kata sandi minimal 5 karakter";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _passwordField(
                            controller: _confirmPasswordCtrl,
                            label: "Ulangi Kata Sandi",
                            isObscure: _obscureConfirm,
                            onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
                            validator: (val) =>
                                val == null || val.trim().isEmpty ? "Ulangi kata sandi" : null,
                          ),
                          const SizedBox(height: 28),
                          AnimatedPressable(
                            borderRadius: BorderRadius.circular(14),
                            onTap: _isLoading ? null : _handleRegister,
                            child: Container(
                              height: 52,
                              decoration: BoxDecoration(
                                color: LuxuryTheme.charcoal,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: LuxuryTheme.charcoal.withValues(alpha: 0.18),
                                    blurRadius: 14,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: LuxuryTheme.pureWhite,
                                        strokeWidth: 2.0,
                                      ),
                                    )
                                  : const Text(
                                      "DAFTAR AKUN SEKARANG",
                                      style: TextStyle(
                                        color: LuxuryTheme.pureWhite,
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 1.8,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                // Bottom Link to Login
                StaggeredEntrance(
                  index: 2,
                  child: Center(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: RichText(
                        text: const TextSpan(
                          text: "Sudah memiliki akun? ",
                          style: TextStyle(
                            color: LuxuryTheme.warmGrey,
                            fontSize: 13.5,
                            letterSpacing: -0.2,
                          ),
                          children: [
                            TextSpan(
                              text: "Masuk di sini",
                              style: TextStyle(
                                color: LuxuryTheme.charcoal,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
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
);
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: LuxuryTheme.charcoal, fontSize: 14.5),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: LuxuryTheme.charcoal, size: 20),
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
      validator: validator,
    );
  }

  Widget _passwordField({
    required TextEditingController controller,
    required String label,
    required bool isObscure,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isObscure,
      style: const TextStyle(color: LuxuryTheme.charcoal, fontSize: 14.5),
      decoration: InputDecoration(
        labelText: label,
        hintText: "••••••••",
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
            isObscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: LuxuryTheme.warmGrey,
            size: 20,
          ),
          onPressed: onToggle,
        ),
      ),
      validator: validator,
    );
  }
}
