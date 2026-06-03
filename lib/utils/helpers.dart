import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String formatRupiah(dynamic amount) {
  if (amount == null) return 'Rp 0';
  final value = amount is int ? amount : (amount as num).toInt();
  final formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );
  return formatter.format(value);
}

String formatDate(String? isoDate) {
  if (isoDate == null || isoDate.isEmpty) return '-';
  try {
    final dt = DateTime.parse(isoDate).toLocal();
    return DateFormat('d MMMM yyyy', 'id_ID').format(dt);
  } catch (_) {
    return isoDate;
  }
}

String formatDateTime(String? isoDate) {
  if (isoDate == null || isoDate.isEmpty) return '-';
  try {
    final dt = DateTime.parse(isoDate).toLocal();
    return DateFormat('d MMM yyyy, HH:mm', 'id_ID').format(dt);
  } catch (_) {
    return isoDate;
  }
}

String formatCompactNumber(int num) {
  if (num >= 1000000000) return '${(num / 1000000000).toStringAsFixed(1)}M';
  if (num >= 1000000) return '${(num / 1000000).toStringAsFixed(1)}Jt';
  if (num >= 1000) return '${(num / 1000).toStringAsFixed(1)}K';
  return num.toString();
}

Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmText = 'Ya',
  String cancelText = 'Batal',
  Color confirmColor = const Color(0xFF3377FF),
  IconData confirmIcon = Icons.check,
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Row(
        children: [
          Icon(confirmIcon, color: confirmColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
        ],
      ),
      content: Text(message, style: const TextStyle(fontSize: 14, height: 1.5)),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF757575),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Batal', style: TextStyle(fontWeight: FontWeight.w600)),
        ),
        ElevatedButton.icon(
          icon: Icon(confirmIcon, size: 18),
          label: Text(confirmText, style: const TextStyle(fontWeight: FontWeight.w600)),
          style: ElevatedButton.styleFrom(
            backgroundColor: confirmColor,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () => Navigator.pop(context, true),
        ),
      ],
    ),
  );
  return result ?? false;
}