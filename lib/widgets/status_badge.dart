import 'package:flutter/material.dart';
import '../constants/colors.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;

    switch (status) {
      case 'Lunas':
        bgColor = const Color(0x2606C270);
        textColor = AppColors.success;
        break;
      case 'Belum Bayar':
      case 'Belum':
        bgColor = const Color(0x26FF3B3B);
        textColor = AppColors.error;
        break;
      case 'Menunggu Verifikasi':
        bgColor = const Color(0x26FFCC00);
        textColor = const Color(0xFFFF9800);
        break;
      case 'Diproses':
        bgColor = const Color(0x263377FF);
        textColor = AppColors.mainColor;
        break;
      default:
        bgColor = AppColors.grey100;
        textColor = AppColors.dark3;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}