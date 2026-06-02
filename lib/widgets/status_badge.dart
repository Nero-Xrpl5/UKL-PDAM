import 'package:flutter/material.dart';
import '../constants/colors.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final double fontSize;
  final EdgeInsets padding;

  const StatusBadge({
    Key? key,
    required this.status,
    this.fontSize = 12,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  }) : super(key: key);

  Color get _backgroundColor {
    switch (status.toLowerCase()) {
      case 'aktif':
      case 'lunas':
      case 'paid':
      case 'success':
      case 'selesai':
        return AppColors.success.withOpacity(0.15);
      case 'non-aktif':
      case 'nonaktif':
      case 'belum bayar':
      case 'unpaid':
      case 'gagal':
        return AppColors.error.withOpacity(0.15);
      case 'menunggu verifikasi':
      case 'pending':
      case 'proses':
      case 'menunggak':
        return AppColors.warning.withOpacity(0.15);
      case 'belum':
        return AppColors.light2;
      default:
        return AppColors.subtle;
    }
  }

  Color get _textColor {
    switch (status.toLowerCase()) {
      case 'aktif':
      case 'lunas':
      case 'paid':
      case 'success':
      case 'selesai':
        return AppColors.success;
      case 'non-aktif':
      case 'nonaktif':
      case 'belum bayar':
      case 'unpaid':
      case 'gagal':
        return AppColors.error;
      case 'menunggu verifikasi':
      case 'pending':
      case 'proses':
      case 'menunggak':
        return AppColors.warning;
      case 'belum':
        return AppColors.dark2;
      default:
        return AppColors.mainColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          color: _textColor,
        ),
      ),
    );
  }
}