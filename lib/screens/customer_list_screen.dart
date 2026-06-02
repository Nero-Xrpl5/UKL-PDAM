import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../services/customer_api.dart';
import '../widgets/custom_card.dart';
import '../widgets/custom_textfield.dart';

class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({Key? key}) : super(key: key);

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  final CustomerApi _api = CustomerApi();
  List<dynamic> customers = [];
  bool isLoading = true;

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
    }
  }

  Future<void> _deleteCustomer(int id) async {
    try {
      await _api.deleteCustomer(id);
      _loadCustomers();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
      );
    }
  }

  void _showAddEditDialog({dynamic customer}) {
    final isEdit = customer != null;
    final nameCtrl = TextEditingController(text: customer?['name'] ?? '');
    final phoneCtrl = TextEditingController(text: customer?['phone'] ?? '');
    final addressCtrl = TextEditingController(text: customer?['address'] ?? '');
    final numberCtrl = TextEditingController(text: customer?['customer_number'] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
              CustomTextField(label: 'No Pelanggan', hint: 'NIK/No Pelanggan', controller: numberCtrl),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final data = {
                'name': nameCtrl.text,
                'phone': phoneCtrl.text,
                'address': addressCtrl.text,
                'customer_number': numberCtrl.text,
              };
              try {
                if (isEdit) {
                  await _api.updateCustomer(customer['id'], data);
                } else {
                  data['username'] = numberCtrl.text;
                  data['password'] = '12345678';
                  data['service_id'] = 1;
                  await _api.createCustomer(data);
                }
                _loadCustomers();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
                );
              }
            },
            child: Text(isEdit ? 'Update' : 'Simpan'),
          ),
        ],
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
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: customers.length,
              itemBuilder: (context, index) {
                final c = customers[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: CustomCard(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.subtle,
                          child: Text((c['name'] ?? '')[0].toString().toUpperCase(), style: const TextStyle(color: AppColors.mainColor)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(c['name'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text(c['customer_number'] ?? '-', style: TextStyle(fontSize: 12, color: AppColors.dark3)),
                              Text(c['phone'] ?? '-', style: TextStyle(fontSize: 12, color: AppColors.dark3)),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: AppColors.mainColor),
                          onPressed: () => _showAddEditDialog(customer: c),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: AppColors.error),
                          onPressed: () => _deleteCustomer(c['id']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}