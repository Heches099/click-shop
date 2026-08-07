import 'package:flutter/material.dart';
import '../../../config/design_tokens.dart';
import '../../../core/widgets/animated_press.dart';

class PremiumPressableButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final Color? color;
  final Color? textColor;
  final double? width;
  final double height;
  final IconData? icon;

  const PremiumPressableButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.color,
    this.textColor,
    this.width,
    this.height = 56,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedPress(
      onPressed: onPressed,
      child: Container(
        width: width ?? double.infinity,
        height: height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color ?? AppColors.primary,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: (color ?? AppColors.primary).withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: textColor ?? Colors.white, size: 20),
              const SizedBox(width: 10),
            ],
            Text(
              text,
              style: AppTypography.bodyLarge.copyWith(
                color: textColor ?? Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
