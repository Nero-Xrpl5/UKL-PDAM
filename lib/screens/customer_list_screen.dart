import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../utils/helpers.dart';
import '../services/customer_api.dart';
import '../services/service_api.dart';
import '../widgets/custom_card.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/shimmer_card.dart';

class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({super.key});

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  final CustomerApi _api = CustomerApi();
  final ServiceApi _serviceApi = ServiceApi();
  List<dynamic> customers = [];
  List<dynamic> filteredCustomers = [];
  List<dynamic> services = [];
  bool isLoading = true;
  bool loadingServices = false;
  String? errorMessage;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCustomers();
    _searchCtrl.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchCtrl.removeListener(_onSearch);
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearch() {
    final query = _searchCtrl.text.toLowerCase();
    setState(() {
      filteredCustomers = customers.where((c) {
        final name = c['name']?.toString().toLowerCase() ?? '';
        final number = c['customer_number']?.toString().toLowerCase() ?? '';
        return name.contains(query) || number.contains(query);
      }).toList();
    });
  }

  Future<void> _loadCustomers() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final data = await _api.getCustomers();
      setState(() {
        customers = data;
        filteredCustomers = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
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
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Pelanggan?',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content:
            const Text('Semua data terkait pelanggan ini akan ikut terhapus.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      await _api.deleteCustomer(id);
      _loadCustomers();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _showAddEditDialog({dynamic customer}) async {
    final bool isEdit = customer != null;

    // Load services untuk dropdown (dibutuhkan untuk Add & Edit)
    await _loadServices();
    if (services.isEmpty && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Tidak ada layanan tersedia. Buat layanan di menu Layanan terlebih dahulu.'),
          backgroundColor: AppColors.warning,
          duration: Duration(seconds: 4),
        ),
      );
      return;
    }
    if (!mounted) return;

    final nameCtrl =
        TextEditingController(text: customer?['name']?.toString() ?? '');
    final phoneCtrl =
        TextEditingController(text: customer?['phone']?.toString() ?? '');
    final addressCtrl =
        TextEditingController(text: customer?['address']?.toString() ?? '');
    final numberCtrl = TextEditingController(
        text: customer?['customer_number']?.toString() ?? '');
    final passwordCtrl = TextEditingController();
    bool obscurePassword = true;

    int? selectedServiceId;
    if (isEdit) {
      final dynamic sid = customer?['service_id'];
      selectedServiceId = sid is int ? sid : (sid as num?)?.toInt();
    } else if (services.isNotEmpty) {
      final dynamic sid = services.first['id'];
      selectedServiceId = sid is int ? sid : (sid as num).toInt();
    }

    // Jika saat edit service_id tidak ada di list services (edge case), default ke first
    if (selectedServiceId != null &&
        !services.any((s) {
          final dynamic sid = s['id'];
          final int id = sid is int ? sid : (sid as num).toInt();
          return id == selectedServiceId;
        })) {
      selectedServiceId =
          services.isNotEmpty ? (services.first['id'] as num).toInt() : null;
    }

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            isEdit ? 'Edit Customer' : 'Tambah Customer',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextField(
                  label: 'Nama',
                  hint: 'Nama lengkap',
                  controller: nameCtrl,
                  icon: Icons.person,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  label: 'No Telepon',
                  hint: '08xx',
                  controller: phoneCtrl,
                  icon: Icons.phone,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  label: 'Alamat',
                  hint: 'Alamat',
                  controller: addressCtrl,
                  icon: Icons.home,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  label: 'No Pelanggan (NIK)',
                  hint: 'NIK / No Pelanggan',
                  controller: numberCtrl,
                  icon: Icons.badge,
                ),
                const SizedBox(height: 4),
                const Text(
                  'No Pelanggan akan digunakan sebagai Username untuk login',
                  style: TextStyle(
                      fontSize: 11,
                      color: AppColors.dark3,
                      fontStyle: FontStyle.italic),
                ),
                if (!isEdit) ...[
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: passwordCtrl,
                    obscureText: obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: 'Minimal 6 karakter',
                      prefixIcon:
                          const Icon(Icons.lock_outline, color: AppColors.dark3),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: AppColors.dark3,
                          size: 20,
                        ),
                        onPressed: () => setDialogState(
                            () => obscurePassword = !obscurePassword),
                      ),
                      filled: true,
                      fillColor: AppColors.grey100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Password ini akan digunakan customer untuk login',
                    style: TextStyle(
                        fontSize: 11,
                        color: AppColors.dark3,
                        fontStyle: FontStyle.italic),
                  ),
                ],
                const SizedBox(height: 12),
                // DROPDOWN LAYANAN: Tampil untuk Add & Edit
                if (loadingServices)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (services.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0x1AFF3B3B),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.error, color: AppColors.error),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Tidak ada layanan. Buat layanan dulu di menu Layanan.',
                            style:
                                TextStyle(fontSize: 13, color: AppColors.error),
                          ),
                        ),
                      ],
                    ),
                  )
                else ...[
                  const Text(
                    'Pilih Layanan *',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.dark1),
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
                        icon: const Icon(Icons.keyboard_arrow_down,
                            color: AppColors.mainColor),
                        items: services.map<DropdownMenuItem<int>>((s) {
                          final dynamic rawId = s['id'];
                          final int id =
                              rawId is int ? rawId : (rawId as num).toInt();
                          final String name =
                              s['name']?.toString() ?? 'Layanan $id';
                          return DropdownMenuItem<int>(
                            value: id,
                            child: Text('$name (Rp ${s['price']})',
                                style: const TextStyle(fontSize: 14)),
                          );
                        }).toList(),
                        onChanged: (v) =>
                            setDialogState(() => selectedServiceId = v),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.mainColor,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                if (selectedServiceId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Pilih layanan terlebih dahulu!'),
                      backgroundColor: AppColors.warning,
                    ),
                  );
                  return;
                }
                if (!isEdit &&
                    (passwordCtrl.text.isEmpty ||
                        passwordCtrl.text.length < 6)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password minimal 6 karakter!'),
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
                  'service_id': selectedServiceId, // ⬅️ WAJIB UNTUK ADD & UPDATE
                };
                try {
                  if (isEdit) {
                    await _api.updateCustomer(customer['id'], data);
                  } else {
                    data['username'] = numberCtrl.text;
                    data['password'] = passwordCtrl.text;
                    await _api.createCustomer(data);
                  }
                  _loadCustomers();
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Error: $e'),
                          backgroundColor: AppColors.error),
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
      appBar: AppBar(
        title: const Text('Data Pelanggan'),
        backgroundColor: AppColors.mainColor,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Chip(
              label: Text(
                '${filteredCustomers.length}',
                style: const TextStyle(color: AppColors.white, fontSize: 12),
              ),
              backgroundColor: const Color(0x40FFFFFF),
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(),
        backgroundColor: AppColors.mainColor,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Cari nama atau nomor pelanggan...',
                prefixIcon:
                    const Icon(Icons.search, color: AppColors.dark3),
                filled: true,
                fillColor: AppColors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? ListView(
                    padding: const EdgeInsets.all(16),
                    children: const [
                      ShimmerCard(height: 80),
                      SizedBox(height: 12),
                      ShimmerCard(height: 80),
                    ],
                  )
                : errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline,
                                color: AppColors.error, size: 48),
                            const SizedBox(height: 12),
                            Text('Gagal memuat data',
                                style:
                                    TextStyle(color: AppColors.grey600)),
                            TextButton(
                                onPressed: _loadCustomers,
                                child: const Text('Coba Lagi')),
                          ],
                        ),
                      )
                    : filteredCustomers.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.people_outline,
                                    size: 64, color: AppColors.dark3),
                                const SizedBox(height: 16),
                                Text(
                                  _searchCtrl.text.isEmpty
                                      ? 'Belum ada pelanggan'
                                      : 'Tidak ditemukan',
                                  style: const TextStyle(
                                      color: AppColors.dark3,
                                      fontSize: 16),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadCustomers,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: filteredCustomers.length,
                              itemBuilder: (context, index) {
                                final c = filteredCustomers[index];
                                final String nameStr =
                                    c['name']?.toString() ?? '-';
                                final String firstChar = nameStr.isNotEmpty
                                    ? nameStr[0].toUpperCase()
                                    : '?';
                                final service =
                                    c['service'] as Map<String, dynamic>?;

                                return Padding(
                                  padding:
                                      const EdgeInsets.only(bottom: 12),
                                  child: CustomCard(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor:
                                              AppColors.subtle,
                                          child: Text(
                                            firstChar,
                                            style: const TextStyle(
                                              color: AppColors.mainColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                nameStr,
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Text(
                                                c['customer_number']
                                                        ?.toString() ??
                                                    '-',
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    color:
                                                        AppColors.dark3),
                                              ),
                                              Text(
                                                c['phone']?.toString() ??
                                                    '-',
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    color:
                                                        AppColors.dark3),
                                              ),
                                              if (service != null)
                                                Text(
                                                  'Layanan: ${service['name'] ?? '-'}',
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    color: AppColors
                                                        .mainColor,
                                                    fontWeight:
                                                        FontWeight.w600,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.edit,
                                              color: AppColors.mainColor),
                                          onPressed: () =>
                                              _showAddEditDialog(
                                                  customer: c),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete,
                                              color: AppColors.error),
                                          onPressed: () =>
                                              _deleteCustomer(
                                                  (c['id'] as num)
                                                      .toInt()),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}