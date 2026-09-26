import 'package:flutter/material.dart';
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
        const SnackBar(
          backgroundColor: Color(0xFFFF3B30),
          content: Text("Konfirmasi password tidak cocok."),
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
        const SnackBar(
          backgroundColor: Color(0xFF34C759),
          content: Text("Akun berhasil didaftarkan. Silakan masuk."),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFFF3B30),
          content: Text(e.toString().replaceAll("Exception: ", "")),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        title: const Text("Pendaftaran Akun"),
      ),
      body: AestheticBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              // Header Card
              StaggeredEntrance(
                index: 0,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE5E5EA), width: 0.8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 12,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F766E).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.person_add_rounded,
                          color: Color(0xFF0F766E),
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              "Registrasi Pasien Baru",
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1C1C1E),
                                letterSpacing: -0.3,
                              ),
                            ),
                            SizedBox(height: 3),
                            Text(
                              "Daftarkan akun untuk antrian & layanan klinik",
                              style: TextStyle(
                                fontSize: 12.5,
                                color: Color(0xFF8E8E93),
                                letterSpacing: -0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // Form Card
              StaggeredEntrance(
                index: 1,
                child: Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE5E5EA), width: 0.8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
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
                        const SizedBox(height: 14),
                        _textField(
                          controller: _namaCtrl,
                          label: "Nama Lengkap",
                          hint: "Nama sesuai identitas KTP",
                          icon: Icons.badge_rounded,
                          validator: (val) =>
                              val == null || val.trim().isEmpty ? "Nama lengkap wajib diisi" : null,
                        ),
                        const SizedBox(height: 14),
                        _textField(
                          controller: _nomorTeleponCtrl,
                          label: "Nomor WhatsApp / HP",
                          hint: "Contoh: 081234567890",
                          icon: Icons.phone_rounded,
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
                        const SizedBox(height: 14),
                        _textField(
                          controller: _nomorRmCtrl,
                          label: "Nomor RM (Opsional)",
                          hint: "Kosongkan jika pasien baru",
                          icon: Icons.medical_information_rounded,
                        ),
                        const SizedBox(height: 14),
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
                        const SizedBox(height: 14),
                        _passwordField(
                          controller: _confirmPasswordCtrl,
                          label: "Ulangi Kata Sandi",
                          isObscure: _obscureConfirm,
                          onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
                          validator: (val) =>
                              val == null || val.trim().isEmpty ? "Ulangi kata sandi" : null,
                        ),
                        const SizedBox(height: 24),
                        AnimatedPressable(
                          borderRadius: BorderRadius.circular(14),
                          onTap: _isLoading ? null : _handleRegister,
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F766E),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            alignment: Alignment.center,
                            child: _isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.2,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(Icons.check_circle_outline_rounded,
                                          color: Colors.white, size: 20),
                                      SizedBox(width: 8),
                                      Text(
                                        "Daftar Akun Sekarang",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: -0.2,
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

              const SizedBox(height: 20),

              // Bottom Link to Login
              StaggeredEntrance(
                index: 2,
                child: Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: RichText(
                      text: const TextSpan(
                        text: "Sudah memiliki akun? ",
                        style: TextStyle(
                          color: Color(0xFF8E8E93),
                          fontSize: 14,
                          letterSpacing: -0.2,
                        ),
                        children: [
                          TextSpan(
                            text: "Masuk di sini",
                            style: TextStyle(
                              color: Color(0xFF0F766E),
                              fontWeight: FontWeight.bold,
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
  );
}

  Widget _textField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(
        fontSize: 14.5,
        color: Color(0xFF1C1C1E),
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFC7C7CC), fontSize: 13),
        prefixIcon: Icon(icon, size: 20, color: const Color(0xFF0F766E)),
      ),
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
      validator: validator,
      style: const TextStyle(
        fontSize: 14.5,
        color: Color(0xFF1C1C1E),
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_rounded, size: 20, color: Color(0xFF0F766E)),
        suffixIcon: IconButton(
          icon: Icon(
            isObscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: const Color(0xFF8E8E93),
            size: 20,
          ),
          onPressed: onToggle,
        ),
      ),
    );
  }
}
