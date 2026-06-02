import 'package:flutter/material.dart';
import '../constants/colors.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final Color? color;
  final EdgeInsets padding;
  final double borderRadius;
  final VoidCallback? onTap;
  final bool isDark;

  const CustomCard({
    Key? key,
    required this.child,
    this.color,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 20,
    this.onTap,
    this.isDark = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bgColor = color ?? (isDark ? AppColors.dark1 : AppColors.white);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? AppColors.black.withOpacity(0.2)
                  : AppColors.dark4.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}