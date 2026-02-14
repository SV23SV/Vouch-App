import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_constants.dart';

/// Accessible button widget with haptic feedback and minimum touch target.
class VouchButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const VouchButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final onPressedWithHaptic = onPressed != null
        ? () {
            HapticFeedback.mediumImpact();
            onPressed!();
          }
        : null;

    if (isOutlined) {
      return SizedBox(
        height: AppConstants.minTouchTargetSize,
        child: OutlinedButton(
          onPressed: isLoading ? null : onPressedWithHaptic,
          child: _buildChild(context),
        ),
      );
    }

    return SizedBox(
      height: AppConstants.minTouchTargetSize,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressedWithHaptic,
        style: (backgroundColor != null || foregroundColor != null)
            ? ElevatedButton.styleFrom(
                backgroundColor: backgroundColor,
                foregroundColor: foregroundColor,
              )
            : null,
        child: _buildChild(context),
      ),
    );
  }

  Widget _buildChild(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        height: 24,
        width: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: isOutlined
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onPrimary,
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 22),
          const SizedBox(width: 8),
          Text(label),
        ],
      );
    }

    return Text(label);
  }
}
