import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../providers/app_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  final bool isAdmin;
  const RegisterScreen({Key? key, this.isAdmin = false}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool isAdmin = false;
  bool obscurePassword = true;
  bool obscureConfirm = true;
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _customerNumberCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    isAdmin = widget.isAdmin;
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (_passwordCtrl.text != _confirmCtrl.text) {
      context.read<AppProvider>().setError('Password tidak cocok');
      return;
    }

    final provider = context.read<AppProvider>();
    
    if (isAdmin) {
      final data = {
        'username': _usernameCtrl.text,
        'password': _passwordCtrl.text,
        'name': _nameCtrl.text,
        'phone': _phoneCtrl.text,
      };
      
      provider.setLoading(true);
      try {
        final result = await provider.registerAdmin(data);
        if (result) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Registrasi Admin berhasil! Silakan login.'),
                backgroundColor: AppColors.success,
              ),
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => LoginScreen(isAdmin: true)),
            );
          }
        }
      } catch (e) {
        provider.setLoading(false);
        provider.setError('Registrasi gagal: ${e.toString()}');
      }
    } else {
      final data = {
        'username': _usernameCtrl.text,
        'password': _passwordCtrl.text,
        'name': _nameCtrl.text,
        'phone': _phoneCtrl.text,
        'customer_number': _customerNumberCtrl.text.isNotEmpty 
            ? _customerNumberCtrl.text 
            : _phoneCtrl.text,
        'address': _addressCtrl.text.isNotEmpty 
            ? _addressCtrl.text 
            : 'Malang',
        'service_id': 1,
      };
      
      provider.setLoading(true);
      try {
        final result = await provider.registerCustomer(data);
        if (result) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Registrasi Customer berhasil! Silakan login.'),
                backgroundColor: AppColors.success,
              ),
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => LoginScreen(isAdmin: false)),
            );
          }
        }
      } catch (e) {
        provider.setLoading(false);
        provider.setError('Registrasi gagal: ${e.toString()}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainColor,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
            child: Column(
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_back_ios, color: AppColors.white, size: 18),
                      ),
                    ),
                    const Spacer(),
                    Image.asset(
                      'assets/images/logo.png',
                      width: 50,
                      height: 50,
                      errorBuilder: (c, e, s) => const Icon(Icons.water_drop, color: AppColors.white, size: 40),
                    ),
                    const Spacer(),
                    const SizedBox(width: 40),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'TirtaApp',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.white),
                ),
                Text(
                  'Registrasi Akun ${isAdmin ? 'Admin' : 'User'}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.white.withOpacity(0.9)),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTextField(
                        label: 'Nama Lengkap',
                        hint: 'Masukan Nama Lengkap',
                        icon: Icons.person_outline,
                        controller: _nameCtrl,
                        validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        label: 'Username',
                        hint: 'Masukan Username',
                        icon: Icons.person_outline,
                        controller: _usernameCtrl,
                        validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        label: 'Email',
                        hint: 'Masukan Email',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        controller: _emailCtrl,
                        validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        label: 'No Telephone',
                        hint: '+62 8xx-xxxx-xxxx',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        controller: _phoneCtrl,
                        validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                      ),
                      if (!isAdmin) ...[
                        const SizedBox(height: 16),
                        CustomTextField(
                          label: 'No Pelanggan (NIK)',
                          hint: 'Masukan Nomor Pelanggan',
                          icon: Icons.badge_outlined,
                          controller: _customerNumberCtrl,
                          validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          label: 'Alamat',
                          hint: 'Masukan Alamat',
                          icon: Icons.home_outlined,
                          controller: _addressCtrl,
                          validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                        ),
                      ],
                      const SizedBox(height: 16),
                      CustomTextField(
                        label: 'Password',
                        hint: 'Password',
                        icon: Icons.lock_outline,
                        obscureText: obscurePassword,
                        controller: _passwordCtrl,
                        validator: (v) => v == null || v.length < 6 ? 'Minimal 6 karakter' : null,
                        suffix: IconButton(
                          icon: Icon(
                            obscurePassword ? Icons.visibility_off : Icons.visibility,
                            color: AppColors.dark3,
                            size: 20,
                          ),
                          onPressed: () => setState(() => obscurePassword = !obscurePassword),
                        ),
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        label: 'Confirm Password',
                        hint: 'Confirm Password',
                        icon: Icons.lock_outline,
                        obscureText: obscureConfirm,
                        controller: _confirmCtrl,
                        validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                        suffix: IconButton(
                          icon: Icon(
                            obscureConfirm ? Icons.visibility_off : Icons.visibility,
                            color: AppColors.dark3,
                            size: 20,
                          ),
                          onPressed: () => setState(() => obscureConfirm = !obscureConfirm),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Consumer<AppProvider>(
                        builder: (context, provider, child) {
                          return CustomButton(
                            text: 'Registrasi',
                            isLoading: provider.isLoading,
                            onPressed: _register,
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      if (context.watch<AppProvider>().error != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, color: AppColors.error, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  context.watch<AppProvider>().error!,
                                  style: const TextStyle(color: AppColors.error, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Sudah punya akun? ', style: TextStyle(color: AppColors.dark2, fontSize: 13)),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => LoginScreen(isAdmin: isAdmin)),
                              );
                            },
                            child: const Text(
                              'Login',
                              style: TextStyle(color: AppColors.mainColor, fontWeight: FontWeight.w700, fontSize: 13),
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