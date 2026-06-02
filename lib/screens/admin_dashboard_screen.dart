import 'package:flutter/material.dart';
import 'package:tirta_app/services/api_service.dart';
import '../constants/colors.dart';
import '../services/customer_api.dart';
import '../services/payment_api.dart';
import '../widgets/custom_card.dart';
import 'customer_list_screen.dart';
import 'service_list_screen.dart';
import 'bill_list_screen.dart';
import 'complaint_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final CustomerApi _customerApi = CustomerApi();
  final ServiceApi _serviceApi = ServiceApi();
  final PaymentApi _paymentApi = PaymentApi();

  int totalCustomers = 0;
  int totalServices = 0;
  int pendingPayments = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      final customers = await _customerApi.getCustomers(quantity: 1);
      final services = await _serviceApi.getServices(quantity: 1);
      final payments = await _paymentApi.getPayments(quantity: 100);
      
      setState(() {
        totalCustomers = customers.length;
        totalServices = services.length;
        pendingPayments = payments.where((p) => p['verified'] == false).length;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                        Text(
                          'Selamat Pagi, Admin',
                          style: TextStyle(fontSize: 14, color: AppColors.white.withOpacity(0.8)),
                        ),
                        const Text(
                          'Dashboard',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.white),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
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
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(child: _statCard(totalCustomers.toString(), 'Total Pelanggan', Icons.people, AppColors.success)),
                                const SizedBox(width: 12),
                                Expanded(child: _statCard(pendingPayments.toString(), 'Belum Verifikasi', Icons.pending_actions, AppColors.warning)),
                                const SizedBox(width: 12),
                                Expanded(child: _statCard(totalServices.toString(), 'Total Layanan', Icons.build, AppColors.info)),
                              ],
                            ),
                            const SizedBox(height: 24),
                            GridView.count(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 1.3,
                              children: [
                                _menuCard('Data Pelanggan', Icons.people_outline, AppColors.subtle, AppColors.mainColor, () {
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerListScreen()));
                                }),
                                _menuCard('Tagihan', Icons.receipt_long, AppColors.subtle, AppColors.mainColor, () {
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => const BillListScreen()));
                                }),
                                _menuCard('Layanan', Icons.build, const Color(0xFFFFF3E0), AppColors.warning, () {
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ServiceListScreen()));
                                }),
                                _menuCard('Pengaduan', Icons.report_problem, const Color(0xFFFFF3E0), AppColors.warning, () {
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ComplaintScreen()));
                                }),
                              ],
                            ),
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

  Widget _statCard(String value, String label, IconData icon, Color color) {
    return CustomCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.dark2), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _menuCard(String title, IconData icon, Color bgColor, Color iconColor, VoidCallback onTap) {
    return CustomCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.dark1)),
        ],
      ),
    );
  }
}