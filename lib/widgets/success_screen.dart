import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_dimens.dart';

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.5, end: 1),
            duration: AppDimens.durMedium,
            curve: Curves.easeOutBack,
            builder: (context, scale, child) =>
                Transform.scale(scale: scale, child: child),
            child: Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                TablerIcons.check,
                size: AppDimens.iconXl,
                color: AppColors.onPrimary,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: AppDimens.fontWeightMedium,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
