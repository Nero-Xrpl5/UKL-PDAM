import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../services/service_api.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_card.dart';
import '../widgets/custom_textfield.dart';

class ServiceListScreen extends StatefulWidget {
  const ServiceListScreen({super.key});

  @override
  State<ServiceListScreen> createState() => _ServiceListScreenState();
}

class _ServiceListScreenState extends State<ServiceListScreen> {
  final ServiceApi _api = ServiceApi();
  List<dynamic> services = [];
  bool isLoading = true;

  final _nameCtrl = TextEditingController();
  final _minCtrl = TextEditingController();
  final _maxCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();

  int? _editingId;

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
          SnackBar(content: Text('Gagal memuat: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _createOrUpdateService() async {
    if (_nameCtrl.text.isEmpty || _priceCtrl.text.isEmpty) return;
    final data = {
      'name': _nameCtrl.text,
      'min_usage': int.tryParse(_minCtrl.text) ?? 0,
      'max_usage': int.tryParse(_maxCtrl.text) ?? 100,
      'price': int.tryParse(_priceCtrl.text) ?? 0,
    };
    try {
      if (_editingId != null) {
        await _api.updateService(_editingId!, data);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Layanan berhasil diupdate!'), backgroundColor: AppColors.success),
          );
        }
      } else {
        await _api.createService(data);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Layanan berhasil ditambahkan!'), backgroundColor: AppColors.success),
          );
        }
      }
      _nameCtrl.clear(); _minCtrl.clear(); _maxCtrl.clear(); _priceCtrl.clear();
      setState(() => _editingId = null);
      _loadServices();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  void _startEdit(dynamic service) {
    setState(() {
      _editingId = (service['id'] as num).toInt();
      _nameCtrl.text = service['name']?.toString() ?? '';
      _minCtrl.text = service['min_usage']?.toString() ?? '';
      _maxCtrl.text = service['max_usage']?.toString() ?? '';
      _priceCtrl.text = service['price']?.toString() ?? '';
    });
  }

  void _cancelEdit() {
    setState(() => _editingId = null);
    _nameCtrl.clear(); _minCtrl.clear(); _maxCtrl.clear(); _priceCtrl.clear();
  }

  Future<void> _deleteService(int id) async {
    try {
      await _api.deleteService(id);
      _loadServices();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(title: const Text('Kelola Layanan'), backgroundColor: AppColors.mainColor),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_editingId != null ? 'Edit Layanan' : 'Tambah Layanan', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  CustomTextField(label: 'Nama Layanan', hint: 'Nama', controller: _nameCtrl),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: CustomTextField(label: 'Min', hint: '0', keyboardType: TextInputType.number, controller: _minCtrl)),
                      const SizedBox(width: 12),
                      Expanded(child: CustomTextField(label: 'Max', hint: '100', keyboardType: TextInputType.number, controller: _maxCtrl)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(label: 'Harga', hint: '5000', keyboardType: TextInputType.number, controller: _priceCtrl),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: _editingId != null ? 'Update' : 'Simpan',
                          onPressed: _createOrUpdateService,
                        ),
                      ),
                      if (_editingId != null) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomButton(
                            text: 'Batal',
                            color: AppColors.dark3,
                            onPressed: _cancelEdit,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('Daftar Layanan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (services.isEmpty)
              const Center(child: Text('Belum ada layanan'))
            else
              ...services.map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: CustomCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(s['name']?.toString() ?? '-', style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text('${s['min_usage']} - ${s['max_usage']} m³'),
                            Text('Rp ${s['price']}', style: const TextStyle(color: AppColors.mainColor, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: AppColors.mainColor),
                        onPressed: () => _startEdit(s),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: AppColors.error),
                        onPressed: () => _deleteService((s['id'] as num).toInt()),
                      ),
                    ],
                  ),
                ),
              )).toList(),
          ],
        ),
      ),
    );
  }
}