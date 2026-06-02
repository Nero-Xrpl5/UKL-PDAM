import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../constants/colors.dart';
import '../services/payment_api.dart';
import '../widgets/custom_button.dart';

class PaymentScreen extends StatefulWidget {
  final dynamic bill;
  const PaymentScreen({Key? key, required this.bill}) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final PaymentApi _api = PaymentApi();
  File? _image;
  bool isLoading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _image = File(picked.path));
    }
  }

  Future<void> _submitPayment() async {
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih bukti pembayaran terlebih dahulu'), backgroundColor: AppColors.warning),
      );
      return;
    }
    setState(() => isLoading = true);
    try {
      await _api.createPayment(widget.bill['id'], _image!);
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pembayaran berhasil dikirim! Menunggu verifikasi.'), backgroundColor: AppColors.success),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(title: const Text('Bayar Tagihan'), backgroundColor: AppColors.mainColor),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.mainColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('RINGKASAN TAGIHAN', style: TextStyle(color: AppColors.white, fontSize: 12)),
                  const SizedBox(height: 12),
                  Text('No: ${widget.bill['measurement_number'] ?? '-'}', style: const TextStyle(color: AppColors.white)),
                  Text('Periode: ${widget.bill['month']}/${widget.bill['year']}', style: const TextStyle(color: AppColors.white)),
                  Text('Pemakaian: ${widget.bill['usage_value']} m³', style: const TextStyle(color: AppColors.white)),
                  const SizedBox(height: 12),
                  Text('Rp ${widget.bill['price']}', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.white)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Bukti Pembayaran', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.light2),
                ),
                child: _image != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(_image!, fit: BoxFit.cover),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt, size: 48, color: AppColors.dark3),
                          const SizedBox(height: 8),
                          Text('Tap untuk upload bukti', style: TextStyle(color: AppColors.dark3)),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Kirim Pembayaran',
              isLoading: isLoading,
              onPressed: _submitPayment,
            ),
          ],
        ),
      ),
    );
  }
}