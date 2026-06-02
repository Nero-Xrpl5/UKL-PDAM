import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../services/customer_api.dart';
import '../services/service_api.dart';
import '../widgets/custom_card.dart';
import '../widgets/custom_textfield.dart';

class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({super.key});

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  final CustomerApi _api = CustomerApi();
  final ServiceApi _serviceApi = ServiceApi();
  List<dynamic> customers = [];
  List<dynamic> services = [];
  bool isLoading = true;
  bool loadingServices = false;

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    setState(() => isLoading = true);
    try {
      final data = await _api.getCustomers();
      setState(() {
        customers = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _loadServices() async {
    setState(() => loadingServices = true);
    try {
      final data = await _serviceApi.getServices();
      setState(() {
        services = data;
        loadingServices = false;
      });
    } catch (e) {
      setState(() => loadingServices = false);
    }
  }

  Future<void> _deleteCustomer(int id) async {
    try {
      await _api.deleteCustomer(id);
      _loadCustomers();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _showAddEditDialog({dynamic customer}) async {
    final bool isEdit = customer != null;

    // Load services first for new customer
    if (!isEdit) {
      await _loadServices();
      if (services.isEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tidak ada layanan tersedia. Buat layanan di menu Layanan terlebih dahulu.'),
            backgroundColor: AppColors.warning,
            duration: Duration(seconds: 4),
          ),
        );
        return;
      }
    }

    if (!mounted) return;

    final TextEditingController nameCtrl = TextEditingController(text: customer?['name']?.toString() ?? '');
    final TextEditingController phoneCtrl = TextEditingController(text: customer?['phone']?.toString() ?? '');
    final TextEditingController addressCtrl = TextEditingController(text: customer?['address']?.toString() ?? '');
    final TextEditingController numberCtrl = TextEditingController(text: customer?['customer_number']?.toString() ?? '');

    int? selectedServiceId;
    if (isEdit) {
      final dynamic sid = customer?['service_id'];
      if (sid is int) {
        selectedServiceId = sid;
      } else if (sid is num) {
        selectedServiceId = sid.toInt();
      } else if (sid is String) {
        selectedServiceId = int.tryParse(sid);
      }
    } else if (services.isNotEmpty) {
      final dynamic sid = services.first['id'];
      if (sid is int) {
        selectedServiceId = sid;
      } else if (sid is num) {
        selectedServiceId = sid.toInt();
      }
    }

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEdit ? 'Edit Customer' : 'Tambah Customer'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(label: 'Nama', hint: 'Nama lengkap', controller: nameCtrl),
                const SizedBox(height: 12),
                CustomTextField(label: 'No Telepon', hint: '08xx', controller: phoneCtrl),
                const SizedBox(height: 12),
                CustomTextField(label: 'Alamat', hint: 'Alamat', controller: addressCtrl),
                const SizedBox(height: 12),
                CustomTextField(
                  label: 'No Pelanggan (NIK)',
                  hint: 'NIK / No Pelanggan',
                  controller: numberCtrl,
                ),
                const SizedBox(height: 4),
                const Text(
                  'No Pelanggan akan digunakan sebagai Username untuk login',
                  style: TextStyle(fontSize: 11, color: AppColors.dark3, fontStyle: FontStyle.italic),
                ),
                if (!isEdit) ...[
                  const SizedBox(height: 12),
                  if (loadingServices)
                    const Center(child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ))
                  else if (services.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.error, color: AppColors.error),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Tidak ada layanan. Buat layanan dulu di menu Layanan.',
                              style: TextStyle(fontSize: 13, color: AppColors.error),
                            ),
                          ),
                        ],
                      ),
                    )
                  else ...[
                    const Text(
                      'Pilih Layanan *',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.dark1),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.subtle),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          isExpanded: true,
                          value: selectedServiceId,
                          hint: const Text('Pilih Layanan'),
                          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.mainColor),
                          items: services.map<DropdownMenuItem<int>>((s) {
                            final dynamic rawId = s['id'];
                            final int id = rawId is int ? rawId : (rawId as num).toInt();
                            final String name = s['name']?.toString() ?? 'Layanan $id';
                            return DropdownMenuItem(
                              value: id,
                              child: Text('$name (ID: $id)', style: const TextStyle(fontSize: 14)),
                            );
                          }).toList(),
                          onChanged: (v) => setDialogState(() => selectedServiceId = v),
                        ),
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () async {
                if (!isEdit && selectedServiceId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Pilih layanan terlebih dahulu!'),
                      backgroundColor: AppColors.warning,
                    ),
                  );
                  return;
                }

                Navigator.pop(context);
                final Map<String, dynamic> data = {
                  'name': nameCtrl.text,
                  'phone': phoneCtrl.text,
                  'address': addressCtrl.text,
                  'customer_number': numberCtrl.text,
                };
                try {
                  if (isEdit) {
                    await _api.updateCustomer(customer['id'], data);
                  } else {
                    // SAMAKAN: username = customer_number (sama seperti register)
                    data['username'] = numberCtrl.text;
                    data['password'] = '12345678';
                    data['service_id'] = selectedServiceId;
                    await _api.createCustomer(data);
                  }
                  _loadCustomers();
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
                    );
                  }
                }
              },
              child: Text(isEdit ? 'Update' : 'Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(title: const Text('Data Pelanggan'), backgroundColor: AppColors.mainColor),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(),
        backgroundColor: AppColors.mainColor,
        child: const Icon(Icons.add),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : customers.isEmpty
              ? const Center(child: Text('Belum ada pelanggan'))
              : RefreshIndicator(
                  onRefresh: _loadCustomers,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: customers.length,
                    itemBuilder: (context, index) {
                      final c = customers[index];
                      final String nameStr = c['name']?.toString() ?? '-';
                      final String firstChar = nameStr.isNotEmpty ? nameStr[0].toUpperCase() : '?';

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: CustomCard(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: AppColors.subtle,
                                child: Text(firstChar, style: const TextStyle(color: AppColors.mainColor)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(nameStr, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    Text(c['customer_number']?.toString() ?? '-', style: TextStyle(fontSize: 12, color: AppColors.dark3)),
                                    Text(c['phone']?.toString() ?? '-', style: TextStyle(fontSize: 12, color: AppColors.dark3)),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit, color: AppColors.mainColor),
                                onPressed: () => _showAddEditDialog(customer: c),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: AppColors.error),
                                onPressed: () => _deleteCustomer((c['id'] as num).toInt()),
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