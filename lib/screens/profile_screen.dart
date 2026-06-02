import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../providers/app_provider.dart';
import '../services/customer_api.dart';
import '../widgets/custom_card.dart';
import 'welcome_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final CustomerApi _api = CustomerApi();
  dynamic profileData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final response = await _api.getMe();
      setState(() {
        profileData = response?['data'];
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppProvider>().user;
    final isAdmin = context.watch<AppProvider>().isAdmin;

    return Scaffold(
      backgroundColor: AppColors.mainColor,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: const Center(
                child: Text('Profil Saya', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.white)),
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                decoration: const BoxDecoration(
                  color: AppColors.bgLight,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
                ),
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        child: Column(
                          children: [
                            CustomCard(
                              isDark: true,
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                children: [
                                  CircleAvatar(
                                    radius: 45,
                                    backgroundColor: AppColors.white.withOpacity(0.2),
                                    child: const Icon(Icons.person, size: 40, color: AppColors.white),
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                    decoration: BoxDecoration(color: AppColors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                                    child: Text(isAdmin ? 'Admin' : 'Customer', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.white)),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(user?.name ?? 'User', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.white)),
                                  const SizedBox(height: 4),
                                  Text(user?.email ?? profileData?['email'] ?? 'email@example.com', style: TextStyle(fontSize: 13, color: AppColors.white.withOpacity(0.7))),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            CustomCard(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _infoRow(Icons.person_outline, 'Nama Lengkap', profileData?['name'] ?? user?.name ?? '-'),
                                  const Divider(height: 24),
                                  _infoRow(Icons.phone_outlined, 'No Telepon', profileData?['phone'] ?? user?.phone ?? '-'),
                                  const Divider(height: 24),
                                  if (!isAdmin) ...[
                                    _infoRow(Icons.home_outlined, 'Alamat', profileData?['address'] ?? '-'),
                                    const Divider(height: 24),
                                    _infoRow(Icons.badge_outlined, 'No Pelanggan', profileData?['customer_number'] ?? '-'),
                                    const Divider(height: 24),
                                  ],
                                  _infoRow(Icons.verified_user_outlined, 'Status', 'Aktif'),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            _menuItem(Icons.edit_outlined, 'Edit Profil', () {}),
                            const SizedBox(height: 10),
                            _menuItem(Icons.lock_outline, 'Ubah Password', () {}),
                            const SizedBox(height: 10),
                            _menuItem(Icons.logout, 'Keluar', () async {
                              await context.read<AppProvider>().logout();
                              if (context.mounted) {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                                  (route) => false,
                                );
                              }
                            }, color: AppColors.error),
                          ],
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.subtle, borderRadius: BorderRadius.circular(10)), child: Icon(icon, size: 20, color: AppColors.mainColor)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: AppColors.dark3)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.dark1)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _menuItem(IconData icon, String title, VoidCallback onTap, {Color? color}) {
    return CustomCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Icon(icon, size: 22, color: color ?? AppColors.dark1),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: color ?? AppColors.dark1))),
          Icon(Icons.chevron_right, size: 20, color: AppColors.dark3),
        ],
      ),
    );
  }
}