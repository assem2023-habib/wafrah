import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../core/constants/app_dimens.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/motion.dart';

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
            duration: Motion.dur(AppDimens.durMedium),
            curve: Curves.easeOutBack,
            builder: (context, scale, child) =>
                Transform.scale(scale: scale, child: child),
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: context.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                TablerIcons.check,
                size: AppDimens.iconXl,
                color: context.onPrimary,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: AppDimens.fontWeightMedium,
              color: context.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}