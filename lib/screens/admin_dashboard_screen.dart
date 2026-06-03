import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../utils/helpers.dart';
import '../services/customer_api.dart';
import '../services/service_api.dart';
import '../services/payment_api.dart';
import '../services/api_service.dart';
import '../constants/api.dart';
import '../widgets/shimmer_card.dart';
import 'customer_list_screen.dart';
import 'service_list_screen.dart';
import 'bill_list_screen.dart';
import 'notification_screen.dart';
import 'profile_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final CustomerApi _customerApi = CustomerApi();
  final ServiceApi _serviceApi = ServiceApi();
  final PaymentApi _paymentApi = PaymentApi();
  final ApiService _api = ApiService();

  int totalCustomers = 0;
  int totalServices = 0;
  int pendingPayments = 0;
  int totalBillsAmount = 0;
  List recentServices = [];
  bool isLoading = true;
  String? errorMessage;
  String adminName = 'Admin';

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final customerResponse =
          await _api.get('${ApiConfig.customers}?page=1&quantity=1');
      final serviceResponse =
          await _api.get('${ApiConfig.services}?page=1&quantity=1');
      final servicesList = await _serviceApi.getServices(quantity: 5);
      final payments = await _paymentApi.getPayments(quantity: 100);
      final bills = await _api.get('${ApiConfig.bills}?page=1&quantity=100');

      int billsTotal = 0;
      if (bills != null && bills['data'] != null) {
        final List billsData = bills['data'];
        for (final b in billsData) {
          billsTotal += ((b['price'] ?? 0) as num).toInt();
        }
      }

      if (mounted) {
        setState(() {
          totalCustomers = (customerResponse?['count'] as num?)?.toInt() ?? 0;
          totalServices = (serviceResponse?['count'] as num?)?.toInt() ?? 0;
          pendingPayments =
              payments.where((p) => p['verified'] == false).length;
          totalBillsAmount = billsTotal;
          recentServices = servicesList;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = e.toString();
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF4DA6FF),
                      Color(0xFF0077E6),
                      Color(0xFF005BB5),
                    ],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: const Color(0x33FFFFFF),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0x66FFFFFF),
                                      width: 2,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.person,
                                    color: AppColors.white,
                                    size: 26,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Selamat Datang, Admin',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Color(0xB3FFFFFF),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      adminName,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const NotificationScreen(),
                                ),
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: const BoxDecoration(
                                  color: Color(0x26FFFFFF),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.notifications_outlined,
                                  color: AppColors.white,
                                  size: 22,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        if (isLoading)
                          const Row(
                            children: [
                              Expanded(
                                child: ShimmerCard(
                                  height: 110,
                                  margin: EdgeInsets.only(right: 6),
                                ),
                              ),
                              Expanded(
                                child: ShimmerCard(
                                  height: 110,
                                  margin: EdgeInsets.only(left: 6),
                                ),
                              ),
                            ],
                          )
                        else ...[
                          Row(
                            children: [
                              Expanded(
                                child: _statCard(
                                  icon: Icons.people_outline,
                                  value: formatCompactNumber(totalCustomers),
                                  label: 'Total Pelanggan',
                                  subLabel: 'Aktif',
                                  iconBg: const Color(0xFFE3F2FD),
                                  iconColor: const Color(0xFF2196F3),
                                  trendUp: true,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _statCard(
                                  icon: Icons.receipt_long,
                                  value: formatRupiah(totalBillsAmount),
                                  label: 'Total Tagihan',
                                  subLabel: 'Kumulatif',
                                  iconBg: const Color(0xFFF3E5F5),
                                  iconColor: const Color(0xFF9C27B0),
                                  trendUp: false,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _statCard(
                                  icon: Icons.build,
                                  value: '$totalServices',
                                  label: 'Total Layanan',
                                  subLabel: 'Tersedia',
                                  iconBg: const Color(0xFFE8F5E9),
                                  iconColor: const Color(0xFF4CAF50),
                                  trendUp: true,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _statCard(
                                  icon: Icons.pending_actions,
                                  value: '$pendingPayments',
                                  label: 'Pending Verifikasi',
                                  subLabel: 'Pembayaran',
                                  iconBg: const Color(0xFFFFF3E0),
                                  iconColor: const Color(0xFFFF9800),
                                  trendUp: pendingPayments > 0,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Menu Cepat',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A237E),
                      ),
                    ),
                    const SizedBox(height: 16),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 4,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.85,
                      children: [
                        _menuItem(
                          icon: Icons.people_outline,
                          label: 'Data\nPelanggan',
                          color: const Color(0xFF4CAF50),
                          bgColor: const Color(0xFFE8F5E9),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CustomerListScreen(),
                            ),
                          ),
                        ),
                        _menuItem(
                          icon: Icons.receipt_long,
                          label: 'Tagihan',
                          color: const Color(0xFF2196F3),
                          bgColor: const Color(0xFFE3F2FD),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const BillListScreen(),
                            ),
                          ),
                        ),
                        _menuItem(
                          icon: Icons.build,
                          label: 'Layanan',
                          color: const Color(0xFFFF9800),
                          bgColor: const Color(0xFFFFF3E0),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ServiceListScreen(),
                            ),
                          ),
                        ),
                        _menuItem(
                          icon: Icons.assessment_outlined,
                          label: 'Laporan',
                          color: const Color(0xFF9C27B0),
                          bgColor: const Color(0xFFF3E5F5),
                          onTap: () =>
                              _showSnack('Fitur laporan belum tersedia'),
                        ),
                        _menuItem(
                          icon: Icons.handyman_outlined,
                          label: 'Pemeliharaan',
                          color: const Color(0xFFF44336),
                          bgColor: const Color(0xFFFFEBEE),
                          onTap: () =>
                              _showSnack('Fitur pemeliharaan belum tersedia'),
                        ),
                        _menuItem(
                          icon: Icons.location_on_outlined,
                          label: 'Zona\nWilayah',
                          color: const Color(0xFF00BCD4),
                          bgColor: const Color(0xFFE0F7FA),
                          onTap: () =>
                              _showSnack('Fitur zona wilayah belum tersedia'),
                        ),
                        _menuItem(
                          icon: Icons.settings_outlined,
                          label: 'Pengaturan',
                          color: const Color(0xFF607D8B),
                          bgColor: const Color(0xFFECEFF1),
                          onTap: () =>
                              _showSnack('Fitur pengaturan belum tersedia'),
                        ),
                        _menuItem(
                          icon: Icons.logout_outlined,
                          label: 'Keluar',
                          color: const Color(0xFFE53935),
                          bgColor: const Color(0xFFFFEBEE),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ProfileScreen(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Aktivitas Layanan',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A237E),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ServiceListScreen(),
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(
                                'Lihat Semua',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: const Color(0xFF48A7FF),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 2),
                              const Icon(
                                Icons.chevron_right,
                                size: 16,
                                color: Color(0xFF48A7FF),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (isLoading)
                      const ShimmerCard(height: 80)
                    else if (errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: AppColors.error,
                              size: 40,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Gagal memuat data',
                              style: TextStyle(color: AppColors.grey600),
                            ),
                            TextButton(
                              onPressed: _loadDashboardData,
                              child: const Text('Coba Lagi'),
                            ),
                          ],
                        ),
                      )
                    else if (recentServices.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x0A000000),
                              blurRadius: 12,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.build_circle_outlined,
                                size: 48,
                                color: AppColors.grey300,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Belum ada layanan tersedia',
                                style: TextStyle(
                                  color: AppColors.grey500,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Tambah layanan di menu Layanan',
                                style: TextStyle(
                                  color: AppColors.grey400,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ...recentServices.map((s) {
                        final String name = s['name']?.toString() ?? 'Layanan';
                        final int minUsage =
                            ((s['min_usage'] ?? 0) as num).toInt();
                        final int maxUsage =
                            ((s['max_usage'] ?? 0) as num).toInt();
                        final int price = ((s['price'] ?? 0) as num).toInt();
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x0A000000),
                                  blurRadius: 12,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFFFF3E0),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(12)),
                                  ),
                                  child: const Icon(
                                    Icons.build,
                                    color: Color(0xFFFF9800),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                          color: Color(0xFF1A237E),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Pemakaian: $minUsage - $maxUsage m³',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.grey500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFE8F5E9),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20)),
                                  ),
                                  child: Text(
                                    formatRupiah(price),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF4CAF50),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: const Color(0xFF757575),
      ),
    );
  }

  Widget _statCard({
    required IconData icon,
    required String value,
    required String label,
    required String subLabel,
    required Color iconBg,
    required Color iconColor,
    required bool trendUp,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xF2FFFFFF),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              Icon(
                trendUp ? Icons.trending_up : Icons.trending_down,
                size: 14,
                color:
                    trendUp ? const Color(0xFF4CAF50) : const Color(0xFFE53935),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A237E),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.grey600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subLabel,
            style: TextStyle(
              fontSize: 10,
              color: AppColors.grey400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuItem({
    required IconData icon,
    required String label,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Color.fromRGBO(
                    color.red,
                    color.green,
                    color.blue,
                    0.15,
                  ),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1A237E),
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
