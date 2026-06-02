import 'package:flutter/material.dart';
import '../constants/colors.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool isAdmin = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          Stack(
            children: [
              Container(color: AppColors.white),
              Positioned(
                left: -80,
                top: -50,
                bottom: -50,
                child: Container(
                  width: 280,
                  decoration: const BoxDecoration(
                    color: AppColors.mainColor,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(200),
                      bottomRight: Radius.circular(200),
                    ),
                  ),
                ),
              ),
              Positioned(
                right: -20,
                bottom: 120,
                child: Image.asset(
                  'assets/images/welcome_person.png',
                  width: 320,
                  height: 450,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Container(
                    width: 320,
                    height: 450,
                    color: Colors.transparent,
                  ),
                ),
              ),
            ],
          ),
          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16, right: 24),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/images/logo.png',
                          width: 36,
                          height: 36,
                          errorBuilder: (c, e, s) => const Icon(
                            Icons.water_drop,
                            color: AppColors.mainColor,
                            size: 36,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'TirtaApp',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.mainColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.dark4.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Belum Punya Akun?',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.dark1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isAdmin ? 'Admin' : 'User',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.mainColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        isAdmin
                            ? 'Belum memiliki akun admin? Lakukan registrasi untuk mulai mengelola layanan, pelanggan, dan informasi PDAM dengan lebih mudah.'
                            : 'Belum memiliki akun? Daftar sekarang untuk menikmati layanan PDAM secara online dengan lebih mudah, cepat, dan praktis.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.dark2,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => RegisterScreen(isAdmin: isAdmin),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.white,
                            foregroundColor: AppColors.mainColor,
                            elevation: 2,
                            shadowColor: AppColors.dark4.withOpacity(0.2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                              side: const BorderSide(color: AppColors.light2, width: 1),
                            ),
                          ),
                          child: const Text(
                            'Registrasi',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => LoginScreen(isAdmin: isAdmin),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.white,
                            foregroundColor: AppColors.mainColor,
                            elevation: 2,
                            shadowColor: AppColors.dark4.withOpacity(0.2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                              side: const BorderSide(color: AppColors.light2, width: 1),
                            ),
                          ),
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () => setState(() => isAdmin = false),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: !isAdmin ? AppColors.mainColor : AppColors.light3,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: !isAdmin ? AppColors.mainColor : AppColors.light2,
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                Icons.person,
                                color: !isAdmin ? AppColors.white : AppColors.dark3,
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          GestureDetector(
                            onTap: () => setState(() => isAdmin = true),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: isAdmin ? AppColors.mainColor : AppColors.light3,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isAdmin ? AppColors.mainColor : AppColors.light2,
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                Icons.admin_panel_settings,
                                color: isAdmin ? AppColors.white : AppColors.dark3,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}