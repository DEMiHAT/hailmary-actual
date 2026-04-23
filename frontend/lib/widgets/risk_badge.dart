import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class RiskBadge extends StatelessWidget {
  final String riskLevel;
  final double fontSize;

  const RiskBadge({
    super.key,
    required this.riskLevel,
    this.fontSize = 12,
  });

  Color get _color {
    switch (riskLevel.toUpperCase()) {
      case 'HIGH':
        return AppColors.emergency;
      case 'MEDIUM':
        return AppColors.warning;
      case 'LOW':
        return AppColors.safe;
      default:
        return AppColors.info;
    }
  }

  Color get _bgColor {
    switch (riskLevel.toUpperCase()) {
      case 'HIGH':
        return AppColors.emergencyLight;
      case 'MEDIUM':
        return AppColors.warningLight;
      case 'LOW':
        return AppColors.safeLight;
      default:
        return AppColors.infoLight;
    }
  }

  IconData get _icon {
    switch (riskLevel.toUpperCase()) {
      case 'HIGH':
        return Icons.warning_rounded;
      case 'MEDIUM':
        return Icons.info_outline_rounded;
      case 'LOW':
        return Icons.check_circle_outline_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: fontSize + 2, color: _color),
          const SizedBox(width: 4),
          Text(
            riskLevel.toUpperCase(),
            style: TextStyle(
              color: _color,
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
