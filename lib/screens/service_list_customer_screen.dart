import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../utils/helpers.dart';
import '../services/service_api.dart';
import '../widgets/shimmer_card.dart';

class ServiceListCustomerScreen extends StatefulWidget {
  const ServiceListCustomerScreen({super.key});

  @override
  State<ServiceListCustomerScreen> createState() => _ServiceListCustomerScreenState();
}

class _ServiceListCustomerScreenState extends State<ServiceListCustomerScreen> {
  final ServiceApi _api = ServiceApi();
  List services = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final data = await _api.getServices();
      setState(() {
        services = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: const Text('Daftar Layanan'),
        backgroundColor: AppColors.mainColor,
      ),
      body: isLoading
          ? ListView(
              padding: const EdgeInsets.all(16),
              children: const [
                ShimmerCard(height: 100),
                SizedBox(height: 12),
                ShimmerCard(height: 100),
                SizedBox(height: 12),
                ShimmerCard(height: 100),
              ],
            )
          : errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: AppColors.error, size: 48),
                      const SizedBox(height: 12),
                      Text('Gagal memuat data', style: TextStyle(color: AppColors.grey600)),
                      TextButton(onPressed: _loadServices, child: const Text('Coba Lagi')),
                    ],
                  ),
                )
              : services.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.build_circle_outlined, size: 64, color: AppColors.grey300),
                          const SizedBox(height: 16),
                          Text(
                            'Belum ada layanan tersedia',
                            style: TextStyle(color: AppColors.grey500, fontSize: 16),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadServices,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: services.length,
                        itemBuilder: (context, index) {
                          final s = services[index];
                          final String name = s['name']?.toString() ?? 'Layanan';
                          final int minUsage = ((s['min_usage'] ?? 0) as num).toInt();
                          final int maxUsage = ((s['max_usage'] ?? 0) as num).toInt();
                          final int price = ((s['price'] ?? 0) as num).toInt();

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x08000000),
                                  blurRadius: 12,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFFFF3E0),
                                        borderRadius: BorderRadius.all(Radius.circular(12)),
                                      ),
                                      child: const Icon(Icons.water_drop, color: Color(0xFFFF9800)),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            name,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF1A237E),
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'Golongan $name',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: AppColors.grey500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(height: 24),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    _infoItem('Pemakaian', '$minUsage - $maxUsage m³'),
                                    _infoItem('Tarif', formatRupiah(price)),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
    );
  }

  Widget _infoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: AppColors.grey500),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.dark1,
          ),
        ),
      ],
    );
  }
}