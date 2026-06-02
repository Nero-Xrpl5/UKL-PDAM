import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../providers/app_provider.dart';
import '../services/bill_api.dart';
import '../widgets/custom_card.dart';
import '../widgets/status_badge.dart';
import 'notification_screen.dart';
import 'payment_screen.dart';
import 'service_list_customer_screen.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  final BillApi _billApi = BillApi();
  List<dynamic> myBills = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBills();
  }

  Future<void> _loadBills() async {
    try {
      final bills = await _billApi.getMyBills();
      setState(() {
        myBills = bills;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppProvider>().user;
    final unpaidBills = myBills.where((b) => b['paid'] == false).toList();
    final totalUnpaid = unpaidBills.fold<int>(0, (sum, b) => sum + ((b['price'] ?? 0) as num).toInt());

    return Scaffold(
      backgroundColor: AppColors.mainColor,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Selamat Pagi,', style: TextStyle(fontSize: 14, color: AppColors.white.withOpacity(0.8))),
                        Text(user?.name ?? 'Customer', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.white)),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const NotificationScreen()),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: AppColors.white.withOpacity(0.2), shape: BoxShape.circle),
                      child: const Icon(Icons.notifications_outlined, color: AppColors.white, size: 22),
                    ),
                  ),
                ],
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
                    : RefreshIndicator(
                        onRefresh: _loadBills,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (unpaidBills.isNotEmpty)
                                CustomCard(
                                  isDark: true,
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.warning_amber, color: AppColors.warning),
                                          const SizedBox(width: 8),
                                          Text('${unpaidBills.length} Tagihan Belum Dibayar', style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Text('Total: Rp $totalUnpaid', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.white)),
                                      const SizedBox(height: 16),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton.icon(
                                          onPressed: () {
                                            Navigator.push(context, MaterialPageRoute(
                                              builder: (_) => PaymentScreen(bill: unpaidBills.first),
                                            )).then((_) => _loadBills());
                                          },
                                          icon: const Icon(Icons.payment),
                                          label: const Text('Bayar Sekarang'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.success,
                                            foregroundColor: AppColors.white,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              const SizedBox(height: 24),

                              // Quick Actions
                              const Text('Menu Cepat', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.dark1)),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: _quickAction(Icons.receipt_long, 'Tagihan', () {
                                      // Navigate to bills tab
                                    }),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _quickAction(Icons.build, 'Layanan', () {
                                      Navigator.push(context, MaterialPageRoute(builder: (_) => const ServiceListCustomerScreen()));
                                    }),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _quickAction(Icons.history, 'Riwayat', () {
                                      // Navigate to history
                                    }),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),

                              if (myBills.isNotEmpty) ...[
                                const Text('Grafik Tagihan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.dark1)),
                                const SizedBox(height: 12),
                                CustomCard(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        height: 180,
                                        child: _buildBillChart(myBills),
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          _chartLegend('Lunas', AppColors.success),
                                          const SizedBox(width: 16),
                                          _chartLegend('Belum', AppColors.error),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),
                              ],

                              const Text('Riwayat Tagihan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.dark1)),
                              const SizedBox(height: 12),
                              if (myBills.isEmpty)
                                const Center(child: Text('Belum ada tagihan'))
                              else
                                ...myBills.map((b) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: CustomCard(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 48,
                                          height: 48,
                                          decoration: BoxDecoration(
                                            color: b['paid'] == true ? AppColors.success.withOpacity(0.1) : AppColors.error.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Icon(
                                            b['paid'] == true ? Icons.check_circle : Icons.receipt,
                                            color: b['paid'] == true ? AppColors.success : AppColors.error,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('Tagihan ${b['month']}/${b['year']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                              Text('Pemakaian: ${b['usage_value']} m³'),
                                              Text('Rp ${b['price']}', style: const TextStyle(color: AppColors.mainColor, fontWeight: FontWeight.w600)),
                                            ],
                                          ),
                                        ),
                                        StatusBadge(status: b['paid'] == true ? 'Lunas' : 'Belum'),
                                        if (b['paid'] == false)
                                          IconButton(
                                            icon: const Icon(Icons.payment, color: AppColors.mainColor),
                                            onPressed: () => Navigator.push(context, MaterialPageRoute(
                                              builder: (_) => PaymentScreen(bill: b),
                                            )).then((_) => _loadBills()),
                                          ),
                                      ],
                                    ),
                                  ),
                                )).toList(),
                            ],
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickAction(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: CustomCard(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Icon(icon, color: AppColors.mainColor, size: 28),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.dark1)),
          ],
        ),
      ),
    );
  }

  Widget _chartLegend(String label, Color color) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 12, color: AppColors.dark2)),
      ],
    );
  }

  Widget _buildBillChart(List<dynamic> bills) {
    final sorted = List<dynamic>.from(bills)..sort((a, b) {
      final aVal = ((a['year'] ?? 0) as num).toInt() * 100 + ((a['month'] ?? 0) as num).toInt();
      final bVal = ((b['year'] ?? 0) as num).toInt() * 100 + ((b['month'] ?? 0) as num).toInt();
      return aVal.compareTo(bVal);
    });

    final chartData = sorted.length > 6 ? sorted.sublist(sorted.length - 6) : sorted;

    if (chartData.isEmpty) return const Center(child: Text('Tidak ada data'));

    final maxPrice = chartData.map((b) => ((b['price'] ?? 0) as num).toInt()).reduce((a, b) => a > b ? a : b);
    final maxVal = maxPrice > 0 ? maxPrice.toDouble() : 1.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: chartData.map((b) {
        final price = ((b['price'] ?? 0) as num).toInt();
        final isPaid = b['paid'] == true;
        final heightFactor = price / maxVal;

        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Rp${(price / 1000).floor()}k',
              style: TextStyle(fontSize: 10, color: AppColors.dark3),
            ),
            const SizedBox(height: 4),
            Container(
              width: 30,
              height: 120 * heightFactor,
              decoration: BoxDecoration(
                color: isPaid ? AppColors.success : AppColors.error,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${b['month']}/${((b['year'] ?? 0) as num).toInt() % 100}',
              style: TextStyle(fontSize: 10, color: AppColors.dark2, fontWeight: FontWeight.w600),
            ),
          ],
        );
      }).toList(),
    );
  }
}