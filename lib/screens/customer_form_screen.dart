import 'package:flutter/material.dart';
import 'package:tirta_app/models/customer.dart';
import '../constants/colors.dart';
import '../services/customer_api.dart';
import '../services/service_api.dart';

class CustomerFormScreen extends StatefulWidget {
  final dynamic customer;
  const CustomerFormScreen({super.key, this.customer});

  bool get isEdit => customer != null;

  @override
  State<CustomerFormScreen> createState() => _CustomerFormScreenState();
}

class _CustomerFormScreenState extends State<CustomerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final CustomerApi _customerApi = CustomerApi();
  final ServiceApi _serviceApi = ServiceApi();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _numberCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _usernameCtrl;
  late final TextEditingController _passwordCtrl;

  int? _selectedServiceId;
  List<dynamic> _services = [];
  bool _isLoadingServices = false;
  bool _isSubmitting = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    final c = widget.customer;
    _nameCtrl = TextEditingController(text: c?['name']?.toString() ?? '');
    _phoneCtrl = TextEditingController(text: c?['phone']?.toString() ?? '');
    _numberCtrl = TextEditingController(
        text: c?['customer_number']?.toString() ?? '');
    _addressCtrl = TextEditingController(text: c?['address']?.toString() ?? '');
    _usernameCtrl = TextEditingController();
    _passwordCtrl = TextEditingController();

    if (widget.isEdit) {
      final dynamic sid = c?['service_id'];
      _selectedServiceId =
          sid is int ? sid : (sid as num?)?.toInt();
    }

    _loadServices();
  }

  Future<void> _loadServices() async {
    setState(() => _isLoadingServices = true);
    try {
      final data = await _serviceApi.getServices();
      setState(() {
        _services = data;
        _isLoadingServices = false;
        // Jika edit dan service_id tidak ditemukan di list, default ke first
        if (_selectedServiceId != null &&
            !_services.any((s) {
              final dynamic id = s['id'];
              final int sid = id is int ? id : (id as num).toInt();
              return sid == _selectedServiceId;
            })) {
          _selectedServiceId =
              _services.isNotEmpty ? (_services.first['id'] as num).toInt() : null;
        }
      });
    } catch (e) {
      setState(() => _isLoadingServices = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _numberCtrl.dispose();
    _addressCtrl.dispose();
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedServiceId == null) {
      _showSnack('Pilih layanan terlebih dahulu', isError: true);
      return;
    }
    if (!widget.isEdit && _passwordCtrl.text.length < 6) {
      _showSnack('Password minimal 6 karakter', isError: true);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final Map<String, dynamic> payload = {
        'name': _nameCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'customer_number': _numberCtrl.text.trim(),
        'address': _addressCtrl.text.trim(),
        'service_id': _selectedServiceId,
      };

      if (widget.isEdit) {
        final int id = (widget.customer['id'] as num).toInt();
        await CustomerApi.updateCustomer(id, payload as Map<String, dynamic>);
      } else {
        payload['username'] = _usernameCtrl.text.trim().isNotEmpty
            ? _usernameCtrl.text.trim()
            : _numberCtrl.text.trim();
        payload['password'] = _passwordCtrl.text.trim();
        await CustomerApi.createCustomer(payload as Map<String, dynamic>);
      }

      if (mounted) {
        setState(() => _isSubmitting = false);
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        _showSnack('Error: $e', isError: true);
      }
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nama
                    _fieldLabel('Nama Pelanggan'),
                    _textField(
                      ctrl: _nameCtrl,
                      hint: 'Masukan Nama Lengkap',
                      icon: Icons.person_outline,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),

                    // No Telepon
                    _fieldLabel('No Telepon'),
                    _textField(
                      ctrl: _phoneCtrl,
                      hint: '+62 857-9876-5432',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'No telepon wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),

                    // No Pelanggan
                    _fieldLabel('No Pelanggan (NIK)'),
                    _textField(
                      ctrl: _numberCtrl,
                      hint: 'NIK / Nomor Pelanggan',
                      icon: Icons.badge_outlined,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'No pelanggan wajib diisi'
                          : null,
                    ),
                    const SizedBox(height: 16),

                    // Alamat
                    _fieldLabel('Alamat'),
                    _textField(
                      ctrl: _addressCtrl,
                      hint: 'Jl. Nama Jalan No. xx, Kelurahan, Kota',
                      icon: Icons.location_on_outlined,
                      maxLines: 2,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Alamat wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),

                    // Username & Password (hanya create)
                    if (!widget.isEdit) ...[
                      _fieldLabel('Username'),
                      _textField(
                        ctrl: _usernameCtrl,
                        hint: 'Username untuk login (opsional, default = No Pelanggan)',
                        icon: Icons.account_circle_outlined,
                      ),
                      const SizedBox(height: 16),
                      _fieldLabel('Password'),
                      _textField(
                        ctrl: _passwordCtrl,
                        hint: 'Password minimal 6 karakter',
                        icon: Icons.lock_outline,
                        obscureText: _obscurePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: AppColors.dark3,
                            size: 20,
                          ),
                          onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                        ),
                        validator: (v) => (v == null || v.length < 6)
                            ? 'Password minimal 6 karakter'
                            : null,
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Pilih Layanan (service_id)
                    _fieldLabel('Pilih Layanan'),
                    _buildServiceDropdown(),
                    const SizedBox(height: 32),

                    // Tombol Simpan
                    _isSubmitting
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.mainColor,
                            ),
                          )
                        : Column(
                            children: [
                              _btn(
                                label: widget.isEdit
                                    ? 'Simpan Customer'
                                    : 'Tambah Customer',
                                bg: AppColors.mainColor,
                                fg: AppColors.white,
                                onTap: _submit,
                              ),
                              const SizedBox(height: 12),
                              _btn(
                                label: 'Batal',
                                bg: const Color(0xFFFFEBEE),
                                fg: AppColors.error,
                                onTap: () => Navigator.pop(context),
                              ),
                            ],
                          ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4DA6FF), Color(0xFF0077E6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0x26FFFFFF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    color: AppColors.white,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                widget.isEdit ? 'Edit Customer' : 'Tambah Customer',
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0x26FFFFFF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person,
                  color: AppColors.white,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: AppColors.dark1,
        ),
      ),
    );
  }

  Widget _textField({
    required TextEditingController ctrl,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      maxLines: maxLines,
      obscureText: obscureText,
      validator: validator,
      style: const TextStyle(fontSize: 14, color: AppColors.dark1),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.grey400, fontSize: 13),
        prefixIcon: Icon(icon, color: AppColors.mainColor, size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.mainColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildServiceDropdown() {
    if (_isLoadingServices) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.mainColor,
              ),
            ),
            SizedBox(width: 12),
            Text(
              'Memuat layanan...',
              style: TextStyle(color: AppColors.grey500, fontSize: 14),
            ),
          ],
        ),
      );
    }

    if (_services.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0x1AFF3B3B),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Row(
          children: [
            Icon(Icons.error_outline, color: AppColors.error),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Tidak ada layanan. Buat layanan di menu Layanan terlebih dahulu.',
                style: TextStyle(fontSize: 13, color: AppColors.error),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.grey200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          isExpanded: true,
          value: _selectedServiceId,
          hint: const Row(
            children: [
              Icon(Icons.water_drop_outlined,
                  color: AppColors.mainColor, size: 20),
              SizedBox(width: 12),
              Text(
                'Pilih Layanan PDAM',
                style: TextStyle(color: AppColors.grey400, fontSize: 14),
              ),
            ],
          ),
          icon: const Icon(Icons.keyboard_arrow_down,
              color: AppColors.mainColor),
          items: _services.map<DropdownMenuItem<int>>((s) {
            final dynamic rawId = s['id'];
            final int sid = rawId is int ? rawId : (rawId as num).toInt();
            final String name = s['name']?.toString() ?? 'Layanan $sid';
            final int price = ((s['price'] ?? 0) as num).toInt();
            return DropdownMenuItem<int>(
              value: sid,
              child: Text(
                '$name (Rp ${price.toString()})',
                style: const TextStyle(fontSize: 14, color: AppColors.dark1),
              ),
            );
          }).toList(),
          onChanged: (v) => setState(() => _selectedServiceId = v),
        ),
      ),
    );
  }

  Widget _btn({
    required String label,
    required Color bg,
    required Color fg,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: fg,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }
}