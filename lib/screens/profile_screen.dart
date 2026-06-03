import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../constants/api.dart';
import '../providers/app_provider.dart';
import '../services/customer_api.dart';
import '../services/api_service.dart';
import '../services/bill_api.dart';
import '../utils/helpers.dart';
import 'welcome_screen.dart';
import 'notification_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final CustomerApi _customerApi = CustomerApi();
  final ApiService _api = ApiService();
  final BillApi _billApi = BillApi();
  dynamic profileData;
  bool isLoading = true;
  List myBills = [];

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadBills();
  }

  Future<void> _loadProfile() async {
    try {
      final provider = context.read<AppProvider>();
      final isAdmin = provider.isAdmin;
      final endpoint = isAdmin ? '/admins/me' : '/customers/me';
      final response = await _customerApi.getMeDirect(endpoint);
      if (mounted) {
        setState(() {
          profileData = response?['data'];
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _loadBills() async {
    try {
      final bills = await _billApi.getMyBills();
      if (mounted) setState(() => myBills = bills);
    } catch (_) {}
  }

  Future<void> _showEditProfileDialog() async {
    final provider = context.read<AppProvider>();
    final isAdmin = provider.isAdmin;
    final nameCtrl = TextEditingController(
      text: profileData?['name']?.toString() ?? provider.user?.name ?? '',
    );
    final phoneCtrl = TextEditingController(
      text: profileData?['phone']?.toString() ?? provider.user?.phone ?? '',
    );
    final addressCtrl = TextEditingController(
      text: profileData?['address']?.toString() ?? '',
    );
    final customerNumberCtrl = TextEditingController(
      text: profileData?['customer_number']?.toString() ?? '',
    );

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Edit Profil', style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _editField(nameCtrl, 'Nama Lengkap', Icons.person_outline),
              const SizedBox(height: 12),
              _editField(phoneCtrl, 'No Telepon', Icons.phone_outlined, TextInputType.phone),
              if (!isAdmin) ...[
                const SizedBox(height: 12),
                _editField(addressCtrl, 'Alamat', Icons.home_outlined),
                const SizedBox(height: 12),
                _editField(customerNumberCtrl, 'No Pelanggan', Icons.badge_outlined),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.mainColor,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              Navigator.pop(context);
              setState(() => isLoading = true);
              try {
                final userId = profileData?['id'];
                if (userId == null) throw Exception('ID user tidak ditemukan');
                if (isAdmin) {
                  await _api.patch('${ApiConfig.admins}/$userId', body: {
                    'name': nameCtrl.text,
                    'phone': phoneCtrl.text,
                  });
                } else {
                  await _api.patch('${ApiConfig.customers}/$userId', body: {
                    'name': nameCtrl.text,
                    'phone': phoneCtrl.text,
                    'address': addressCtrl.text,
                    'customer_number': customerNumberCtrl.text,
                  });
                }
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Profil berhasil diperbarui!'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
                await _loadProfile();
              } catch (e) {
                if (mounted) {
                  setState(() => isLoading = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal update profil: $e'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  Future<void> _showChangePasswordDialog() async {
    final newPassCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    bool obscure1 = true, obscure2 = true;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Ubah Password', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: newPassCtrl,
                  obscureText: obscure1,
                  decoration: InputDecoration(
                    labelText: 'Password Baru',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(obscure1 ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => obscure1 = !obscure1),
                    ),
                    filled: true,
                    fillColor: AppColors.grey100,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: confirmCtrl,
                  obscureText: obscure2,
                  decoration: InputDecoration(
                    labelText: 'Konfirmasi Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(obscure2 ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => obscure2 = !obscure2),
                    ),
                    filled: true,
                    fillColor: AppColors.grey100,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.mainColor,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                if (newPassCtrl.text != confirmCtrl.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Password tidak cocok!'), backgroundColor: AppColors.error),
                  );
                  return;
                }
                if (newPassCtrl.text.length < 6) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Minimal 6 karakter!'), backgroundColor: AppColors.warning),
                  );
                  return;
                }
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Fitur ubah password memerlukan endpoint khusus dari backend.'),
                    backgroundColor: AppColors.warning,
                  ),
                );
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _editField(TextEditingController ctrl, String label, IconData icon, [TextInputType? type]) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: AppColors.grey100,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppProvider>().user;
    final isAdmin = context.watch<AppProvider>().isAdmin;

    final totalUsage = myBills.fold<int>(0, (sum, b) => sum + ((b['usage_value'] ?? 0) as num).toInt());
    final totalBill = myBills.fold<int>(0, (sum, b) => sum + ((b['price'] ?? 0) as num).toInt());

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.mainColor))
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF4DA6FF), Color(0xFF0077E6)],
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                    child: SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                        child: Column(
                          children: [
                            const Text(
                              'Profil Saya',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2D2D2D),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Column(
                                children: [
                                  CircleAvatar(
                                    radius: 40,
                                    backgroundColor: AppColors.grey700,
                                    child: const Icon(Icons.person, size: 40, color: AppColors.white),
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF5B9BD5),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      isAdmin ? 'Admin' : 'Customer',
                                      style: const TextStyle(
                                        color: AppColors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    profileData?['name']?.toString() ?? user?.name ?? 'User',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    profileData?['user']?['username']?.toString() ??
                                        user?.email ??
                                        profileData?['email']?.toString() ??
                                        'email@example.com',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.grey400,
                                    ),
                                  ),
                                  if (!isAdmin) ...[
                                    const SizedBox(height: 20),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _statBox(
                                            value: '${totalUsage}m',
                                            label: 'Pemakaian',
                                            valueColor: AppColors.success,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: _statBox(
                                            value: formatCompactNumber(totalBill),
                                            label: 'Tagihan',
                                            valueColor: const Color(0xFF5B9BD5),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: _statBox(
                                            value: '0',
                                            label: 'Pengaduan',
                                            valueColor: AppColors.warning,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _darkCard(
                          title: 'Informasi Personal',
                          icon: Icons.smartphone,
                          children: [
                            _infoRow(
                              icon: Icons.person_outline,
                              iconBg: const Color(0xFFE8F5E9),
                              iconColor: AppColors.success,
                              label: 'Nama Lengkap',
                              value: profileData?['name']?.toString() ?? user?.name ?? '-',
                            ),
                            const SizedBox(height: 16),
                            _infoRow(
                              icon: Icons.home_outlined,
                              iconBg: const Color(0xFFE3F2FD),
                              iconColor: const Color(0xFF2196F3),
                              label: 'Alamat',
                              value: profileData?['address']?.toString() ?? '-',
                            ),
                            const SizedBox(height: 16),
                            _infoRow(
                              icon: Icons.email_outlined,
                              iconBg: const Color(0xFFFFF3E0),
                              iconColor: const Color(0xFFFF9800),
                              label: 'Email',
                              value: profileData?['email']?.toString() ??
                                  profileData?['user']?['username']?.toString() ??
                                  user?.email ??
                                  '-',
                            ),
                            const SizedBox(height: 16),
                            _infoRow(
                              icon: Icons.phone_outlined,
                              iconBg: const Color(0xFFF3E5F5),
                              iconColor: const Color(0xFF9C27B0),
                              label: 'No Telephone',
                              value: profileData?['phone']?.toString() ?? user?.phone ?? '-',
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (!isAdmin)
                          _darkCard(
                            title: 'Informasi Pelanggan',
                            icon: Icons.water_drop,
                            children: [
                              _infoRow(
                                icon: Icons.person_outline,
                                iconBg: const Color(0xFFE8F5E9),
                                iconColor: AppColors.success,
                                label: 'No. Pelanggan',
                                value: profileData?['customer_number']?.toString() ?? '-',
                              ),
                              const SizedBox(height: 16),
                              _infoRow(
                                icon: Icons.home_outlined,
                                iconBg: const Color(0xFFE0F7FA),
                                iconColor: const Color(0xFF00BCD4),
                                label: 'Golongan',
                                value: profileData?['service']?['name']?.toString() ?? '-',
                              ),
                              const SizedBox(height: 16),
                              _infoRow(
                                icon: Icons.location_on_outlined,
                                iconBg: const Color(0xFFFFF3E0),
                                iconColor: const Color(0xFFFF9800),
                                label: 'Zona Layanan',
                                value: profileData?['address']?.toString()?.contains('Malang') == true
                                    ? 'Kota Malang - Zona B'
                                    : 'Kota Malang - Zona A',
                              ),
                              const SizedBox(height: 16),
                              _infoRow(
                                icon: Icons.verified_user_outlined,
                                iconBg: const Color(0xFFF3E5F5),
                                iconColor: const Color(0xFF9C27B0),
                                label: 'Status Akun',
                                valueWidget: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0x334CAF50),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    'Aktif',
                                    style: TextStyle(
                                      color: AppColors.success,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        if (!isAdmin) const SizedBox(height: 16),
                        _menuButton(
                          icon: Icons.edit_outlined,
                          iconColor: AppColors.success,
                          label: 'Edit Profil',
                          onTap: _showEditProfileDialog,
                        ),
                        const SizedBox(height: 12),
                        _menuButton(
                          icon: Icons.lock_outline,
                          iconColor: const Color(0xFF5B9BD5),
                          label: 'Ubah Password',
                          onTap: _showChangePasswordDialog,
                        ),
                        const SizedBox(height: 12),
                        _menuButton(
                          icon: Icons.notifications_outlined,
                          iconColor: const Color(0xFFFF9800),
                          label: 'Notifikasi',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const NotificationScreen()),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _menuButton(
                          icon: Icons.logout,
                          iconColor: AppColors.error,
                          label: 'Keluar',
                          onTap: () async {
                            await context.read<AppProvider>().logout();
                            if (context.mounted) {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                                (route) => false,
                              );
                            }
                          },
                          textColor: AppColors.error,
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _statBox({required String value, required String label, required Color valueColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.grey800,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.grey400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _darkCard({required String title, required IconData icon, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D2D),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.grey400),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.grey300,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _infoRow({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String label,
    String? value,
    Widget? valueWidget,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: iconColor),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.grey500,
                ),
              ),
              const SizedBox(height: 2),
              if (valueWidget != null)
                valueWidget
              else
                Text(
                  value ?? '-',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _menuButton({
    required IconData icon,
    required Color iconColor,
    required String label,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF2D2D2D),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Color.fromRGBO(iconColor.red, iconColor.green, iconColor.blue, 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: textColor ?? AppColors.white,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.grey600),
          ],
        ),
      ),
    );
  }
}