import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../services/service_api.dart';
import '../widgets/custom_card.dart';

class ServiceListCustomerScreen extends StatefulWidget {
  const ServiceListCustomerScreen({super.key});

  @override
  State<ServiceListCustomerScreen> createState() => _ServiceListCustomerScreenState();
}

class _ServiceListCustomerScreenState extends State<ServiceListCustomerScreen> {
  final ServiceApi _api = ServiceApi();
  List<dynamic> services = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    setState(() => isLoading = true);
    try {
      final data = await _api.getServices();
      setState(() {
        services = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat layanan: $e'), backgroundColor: AppColors.error),
        );
      }
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
          ? const Center(child: CircularProgressIndicator())
          : services.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.build_circle_outlined, size: 64, color: AppColors.dark3),
                      const SizedBox(height: 16),
                      Text('Belum ada layanan tersedia', style: TextStyle(color: AppColors.dark3, fontSize: 16)),
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
                      final name = s['name']?.toString() ?? 'Layanan';
                      final minUsage = s['min_usage']?.toString() ?? '0';
                      final maxUsage = s['max_usage']?.toString() ?? '0';
                      final price = s['price']?.toString() ?? '0';

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: CustomCard(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: AppColors.mainColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.water_drop, color: AppColors.mainColor),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                    Text('Pemakaian: $minUsage - $maxUsage m³', style: TextStyle(fontSize: 13, color: AppColors.dark2)),
                                    Text('Rp $price', style: const TextStyle(color: AppColors.mainColor, fontWeight: FontWeight.w600, fontSize: 14)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}