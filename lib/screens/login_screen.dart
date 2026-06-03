import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../providers/app_provider.dart';
import 'main_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  final bool isAdmin;
  const LoginScreen({super.key, this.isAdmin = false});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isAdmin = false;
  bool obscurePassword = true;
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    isAdmin = widget.isAdmin;
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _hasError = false);

    final provider = context.read<AppProvider>();
    final success = await provider.login(_usernameCtrl.text, _passwordCtrl.text);

    if (success && mounted) {
      // Show success banner
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.check, color: Colors.green, size: 16),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Login Berhasil!',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Mengarahkan ke dashboard...',
                        style: TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          backgroundColor: const Color(0xFF4CAF50),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        ),
      );

      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MainScreen()),
          (route) => false,
        );
      }
    } else if (mounted) {
      setState(() => _hasError = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.close, color: Colors.red, size: 16),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Login Gagal!',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Email/Username atau password salah. Silahkan coba lagi.',
                        style: TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          backgroundColor: const Color(0xFFFF5252),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final errorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.red, width: 1.5),
    );

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Blue gradient background (top portion)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF4DA6FF),
                  Color(0xFF0077E6),
                ],
              ),
            ),
          ),

          // Top bar with back button and logo
          Positioned(
            top: 50,
            left: 16,
            right: 16,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 18),
                  ),
                ),
                const Spacer(),
                Column(
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      width: 40,
                      height: 40,
                      errorBuilder: (c, e, s) => const Icon(
                        Icons.water_drop,
                        size: 36,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'TirtaApp',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      'BERSIH SEHAT TERPERCAYA',
                      style: TextStyle(
                        fontSize: 8,
                        color: Colors.white70,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                const SizedBox(width: 40),
              ],
            ),
          ),

          // Welcome text
          Positioned(
            top: 130,
            left: 24,
            right: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Text(
                      'Selamat datang',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text('👋', style: TextStyle(fontSize: 24)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Masuk untuk melanjutkan',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),

          // Bottom white card
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Masuk Sebagai',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Customer / Admin toggle
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => isAdmin = false),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: !isAdmin ? const Color(0xFFE8F5E9) : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                  border: !isAdmin
                                      ? Border.all(color: const Color(0xFF4CAF50), width: 2)
                                      : null,
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.person,
                                      color: !isAdmin ? const Color(0xFF4CAF50) : Colors.grey,
                                      size: 28,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Customer',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: !isAdmin ? const Color(0xFF4CAF50) : Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => isAdmin = true),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: isAdmin ? const Color(0xFFE8F5E9) : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                  border: isAdmin
                                      ? Border.all(color: const Color(0xFF4CAF50), width: 2)
                                      : null,
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.admin_panel_settings,
                                      color: isAdmin ? const Color(0xFF4CAF50) : Colors.grey,
                                      size: 28,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Admin',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: isAdmin ? const Color(0xFF4CAF50) : Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Email/Username
                      TextFormField(
                        controller: _usernameCtrl,
                        decoration: InputDecoration(
                          labelText: 'Email/Username',
                          labelStyle: TextStyle(
                            color: _hasError ? Colors.red : Colors.grey.shade600,
                            fontSize: 13,
                          ),
                          hintText: 'Masukan email/username',
                          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                          prefixIcon: Icon(
                            Icons.person_outline,
                            color: _hasError ? Colors.red : Colors.grey,
                            size: 20,
                          ),
                          filled: true,
                          fillColor: _hasError ? const Color(0xFFFFEBEE) : Colors.grey.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: _hasError ? Colors.red : const Color(0xFF48A7FF),
                              width: 1.5,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                        validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                      ),

                      const SizedBox(height: 14),

                      // Password
                      TextFormField(
                        controller: _passwordCtrl,
                        obscureText: obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: TextStyle(
                            color: _hasError ? Colors.red : Colors.grey.shade600,
                            fontSize: 13,
                          ),
                          hintText: 'Masukan Password',
                          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                          prefixIcon: Icon(
                            Icons.lock_outline,
                            color: _hasError ? Colors.red : Colors.grey,
                            size: 20,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscurePassword ? Icons.visibility_off : Icons.visibility,
                              color: Colors.grey,
                              size: 20,
                            ),
                            onPressed: () => setState(() => obscurePassword = !obscurePassword),
                          ),
                          filled: true,
                          fillColor: _hasError ? const Color(0xFFFFEBEE) : Colors.grey.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: _hasError ? Colors.red : const Color(0xFF48A7FF),
                              width: 1.5,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                        validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                      ),

                      const SizedBox(height: 8),

                      // Lupa Password
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Lupa Password?',
                            style: TextStyle(
                              color: Color(0xFF48A7FF),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Masuk Button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton(
                          onPressed: _login,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.black,
                            side: const BorderSide(color: Colors.black87, width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: Colors.white,
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          child: const Text('Masuk'),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Daftar Sekarang
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => RegisterScreen(isAdmin: isAdmin),
                              ),
                            );
                          },
                          child: const Text(
                            'Daftar Sekarang',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Divider with "or"
                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.grey.shade300)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'or',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          Expanded(child: Divider(color: Colors.grey.shade300)),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Social / Quick login buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Google
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Image.asset(
                              'assets/images/google_icon.png',
                              width: 24,
                              height: 24,
                              errorBuilder: (c, e, s) => const Icon(Icons.g_mobiledata, size: 28),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Apple
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Image.asset(
                              'assets/images/apple_icon.png',
                              width: 24,
                              height: 24,
                              errorBuilder: (c, e, s) => const Icon(Icons.apple, size: 24),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Admin quick switch
                          GestureDetector(
                            onTap: () => setState(() => isAdmin = !isAdmin),
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: isAdmin ? const Color(0xFFE8F5E9) : Colors.white,
                                border: Border.all(
                                  color: isAdmin ? const Color(0xFF4CAF50) : Colors.grey.shade300,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.admin_panel_settings,
                                size: 24,
                                color: isAdmin ? const Color(0xFF4CAF50) : Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}