import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../constants/api.dart';
import '../utils/helpers.dart';
import '../providers/app_provider.dart';
import '../services/bill_api.dart';
import '../services/api_service.dart';
import '../widgets/shimmer_card.dart';
import 'bill_list_screen.dart';
import 'complaint_screen.dart';
import 'service_list_customer_screen.dart';
import 'payment_screen.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen>
    with SingleTickerProviderStateMixin {
  final BillApi _billApi = BillApi();
  final ApiService _api = ApiService();

  List myBills = [];
  dynamic profileData;
  bool isLoading = true;
  String? errorMessage;

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _loadData();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final bills = await _billApi.getMyBills();
      final response = await _api.get('/customers/me');

      if (mounted) {
        setState(() {
          myBills = bills;
          profileData = response?['data'];
          isLoading = false;
        });
        _animController.forward(from: 0);
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

  dynamic get _latestBill {
    if (myBills.isEmpty) return null;
    final unpaid = myBills.where((b) => b['paid'] != true).toList();
    if (unpaid.isNotEmpty) {
      unpaid.sort((a, b) {
        final ay = ((a['year'] ?? 0) as num).toInt() * 100 + ((a['month'] ?? 0) as num).toInt();
        final by = ((b['year'] ?? 0) as num).toInt() * 100 + ((b['month'] ?? 0) as num).toInt();
        return by.compareTo(ay);
      });
      return unpaid.first;
    }
    return myBills.first;
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat Pagi';
    if (hour < 15) return 'Selamat Siang';
    if (hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppProvider>().user;
    final latestBill = _latestBill;
    final service = profileData?['service'] as Map?;
    final maxUsage = ((service?['max_usage'] ?? 20) as num).toInt();

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Stack(
                    children: [
                      Positioned(
                        top: -40,
                        right: -40,
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: const BoxDecoration(
                            color: Color(0x14FFFFFF),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 20,
                        right: 60,
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: const BoxDecoration(
                            color: Color(0x0FFFFFFF),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: const BoxDecoration(
                                color: Color(0x33FFFFFF),
                                shape: BoxShape.circle,
                                border: Border.fromBorderSide(
                                  BorderSide(color: Color(0x4DFFFFFF), width: 2),
                                ),
                              ),
                              child: const Icon(Icons.person, color: AppColors.white, size: 28),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$_greeting,',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xD9FFFFFF),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    profileData?['name']?.toString() ?? user?.name ?? 'Customer',
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Text('👋', style: TextStyle(fontSize: 28)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      if (isLoading)
                        const ShimmerCard(height: 200)
                      else if (latestBill != null)
                        _buildBillCard(latestBill)
                      else
                        _buildEmptyBillCard(),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _quickMenu(
                            icon: Icons.description_outlined,
                            label: 'Tagihan\nSaya',
                            bgColor: const Color(0xFFE8F8F0),
                            iconColor: const Color(0xFF27AE60),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const BillListScreen()),
                            ),
                          ),
                          _quickMenu(
                            icon: Icons.dashboard_outlined,
                            label: 'Dashboard',
                            bgColor: const Color(0xFFE3F2FD),
                            iconColor: const Color(0xFF2196F3),
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Anda sudah di Dashboard'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            },
                          ),
                          _quickMenu(
                            icon: Icons.chat_bubble_outline,
                            label: 'Pengaduan',
                            bgColor: const Color(0xFFFFF8E1),
                            iconColor: const Color(0xFFFFA000),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ComplaintScreen()),
                            ),
                          ),
                          _quickMenu(
                            icon: Icons.headset_mic_outlined,
                            label: 'Tambah\nLayanan',
                            bgColor: const Color(0xFFF3E5F5),
                            iconColor: const Color(0xFF9C27B0),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ServiceListCustomerScreen()),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      if (isLoading)
                        const ShimmerCard(height: 140)
                      else if (latestBill != null)
                        _buildUsageCard(latestBill, maxUsage)
                      else
                        _buildEmptyUsageCard(),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Riwayat Tagihan',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const BillListScreen()),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  'Lihat Semua',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: const Color(0xFF4A90E2),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 2),
                                const Icon(Icons.chevron_right, size: 16, color: Color(0xFF4A90E2)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (isLoading)
                        const Column(
                          children: [
                            ShimmerCard(height: 72),
                            SizedBox(height: 10),
                            ShimmerCard(height: 72),
                            SizedBox(height: 10),
                            ShimmerCard(height: 72),
                          ],
                        )
                      else if (myBills.isEmpty)
                        _buildEmptyHistory()
                      else
                        ...myBills.take(5).map((b) => _buildHistoryItem(b)).toList(),
                      const SizedBox(height: 16),
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

  Widget _buildBillCard(dynamic bill) {
    final monthNames = ['', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
        'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
    final month = ((bill['month'] ?? 1) as num).toInt();
    final year = ((bill['year'] ?? 2026) as num).toInt();
    final price = ((bill['price'] ?? 0) as num).toInt();
    final isPaid = bill['paid'] == true;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF27AE60), Color(0xFF219653)],
        ),
        borderRadius: BorderRadius.all(Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Color(0x4027AE60),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tagihan Bulan Ini • ${monthNames[month]} $year',
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xE6FFFFFF),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            formatRupiah(price),
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Jatuh Tempo: 30 ${monthNames[month]} $year',
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xCCFFFFFF),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _billActionButton(
                  icon: Icons.payment_outlined,
                  label: 'Bayar Sekarang',
                  onTap: isPaid
                      ? () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Tagihan sudah lunas'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        }
                      : () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PaymentScreen(bill: bill),
                          ),
                        ).then((_) => _loadData()),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _billActionButton(
                  icon: Icons.visibility_outlined,
                  label: 'Lihat Tagihan',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BillListScreen()),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyBillCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF27AE60), Color(0xFF219653)],
        ),
        borderRadius: BorderRadius.all(Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tagihan Bulan Ini',
            style: TextStyle(fontSize: 13, color: Color(0xE6FFFFFF)),
          ),
          const SizedBox(height: 12),
          const Text(
            'Belum ada tagihan',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.white),
          ),
          const SizedBox(height: 16),
          const Text(
            'Anda tidak memiliki tagihan aktif saat ini.',
            style: TextStyle(fontSize: 12, color: Color(0xCCFFFFFF)),
          ),
        ],
      ),
    );
  }

  Widget _billActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0x26FFFFFF),
          borderRadius: BorderRadius.circular(12),
          border: const Border.fromBorderSide(
            BorderSide(color: Color(0x40FFFFFF), width: 1),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickMenu({
    required IconData icon,
    required String label,
    required Color bgColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Color.fromRGBO(iconColor.red, iconColor.green, iconColor.blue, 0.12),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: iconColor, size: 26),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1A1A1A),
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsageCard(dynamic bill, int maxUsage) {
    final usage = ((bill['usage_value'] ?? 0) as num).toInt();
    final month = ((bill['month'] ?? 1) as num).toInt();
    final year = ((bill['year'] ?? 2026) as num).toInt();
    final monthNames = ['', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
        'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
    final percentage = maxUsage > 0 ? (usage / maxUsage).clamp(0.0, 1.0) : 0.0;
    final remaining = (maxUsage - usage).clamp(0, maxUsage);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFF2D2D2D),
        borderRadius: BorderRadius.all(Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bulan ${monthNames[month]} $year',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.grey400,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '$usage',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                        letterSpacing: -1,
                      ),
                    ),
                    const TextSpan(
                      text: ' Meter',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ),
                    TextSpan(
                      text: ' / $maxUsage',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: AppColors.grey500,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${(percentage * 100).toInt()}% digunakan',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Sisa ${remaining}m',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.grey400,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Stack(
            children: [
              Container(
                height: 10,
                decoration: BoxDecoration(
                  color: AppColors.grey800,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              FractionallySizedBox(
                widthFactor: percentage,
                child: Container(
                  height: 10,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('0m', style: TextStyle(fontSize: 11, color: AppColors.grey500)),
              Text('${maxUsage}m', style: TextStyle(fontSize: 11, color: AppColors.grey500)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyUsageCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF2D2D2D),
        borderRadius: BorderRadius.all(Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Penggunaan Air',
            style: TextStyle(fontSize: 13, color: AppColors.grey400),
          ),
          const SizedBox(height: 12),
          const Text(
            '0 Meter',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.white),
          ),
          const SizedBox(height: 12),
          Container(
            height: 10,
            decoration: BoxDecoration(
              color: AppColors.grey800,
              borderRadius: BorderRadius.circular(5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(dynamic bill) {
    final monthNames = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    final month = ((bill['month'] ?? 1) as num).toInt();
    final year = ((bill['year'] ?? 2026) as num).toInt();
    final isPaid = bill['paid'] == true;

    Color titleColor;
    Color badgeColor;
    Color badgeBgColor;
    String badgeText;
    Color iconColor;
    Color iconBgColor;

    if (isPaid) {
      titleColor = const Color(0xFF27AE60);
      badgeColor = const Color(0xFF27AE60);
      badgeBgColor = const Color(0xFFE8F8F0);
      badgeText = 'Lunas';
      iconColor = const Color(0xFF27AE60);
      iconBgColor = const Color(0xFFE8F8F0);
    } else {
      final now = DateTime.now();
      final isOverdue = now.year > year || (now.year == year && now.month > month);
      if (isOverdue) {
        titleColor = const Color(0xFFE67E22);
        badgeColor = const Color(0xFFE67E22);
        badgeBgColor = const Color(0xFFFFF3E0);
        badgeText = 'Menunggak';
        iconColor = const Color(0xFFE67E22);
        iconBgColor = const Color(0xFFFFF3E0);
      } else {
        titleColor = const Color(0xFF27AE60);
        badgeColor = const Color(0xFF27AE60);
        badgeBgColor = const Color(0xFFE8F8F0);
        badgeText = 'Baru';
        iconColor = const Color(0xFF27AE60);
        iconBgColor = const Color(0xFFE8F8F0);
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPaid ? Icons.check : Icons.access_time,
              color: iconColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tagihan ${monthNames[month]} $year',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  isPaid
                      ? 'Dibayar • ${bill['updatedAt'] != null ? formatDate(bill['updatedAt'].toString()) : '$monthNames[$month] $year'}'
                      : 'Belum dibayar',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.grey500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: badgeBgColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              badgeText,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: badgeColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyHistory() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.receipt_long_outlined, size: 48, color: AppColors.grey300),
            const SizedBox(height: 12),
            Text(
              'Belum ada riwayat tagihan',
              style: TextStyle(color: AppColors.grey500, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}