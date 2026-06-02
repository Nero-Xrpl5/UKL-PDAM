import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../providers/app_provider.dart';
import '../services/bill_api.dart';
import '../widgets/custom_card.dart';
import '../widgets/status_badge.dart';
import 'payment_screen.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({Key? key}) : super(key: key);

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
    final totalUnpaid = unpaidBills.fold<int>(0, (sum, b) => sum + (b['price'] ?? 0).toInt());

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
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: AppColors.white.withOpacity(0.2), shape: BoxShape.circle),
                    child: const Icon(Icons.notifications_outlined, color: AppColors.white, size: 22),
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
                    : SingleChildScrollView(
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
                            const Text('Riwayat Tagihan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.dark1)),
                            const SizedBox(height: 12),
                            if (myBills.isEmpty)
                              const Center(child: Text('Belum ada tagihan')),
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
          ],
        ),
      ),
    );
  }
}