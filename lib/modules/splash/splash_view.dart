import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:get/get.dart';

import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/motion.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.background,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      color: context.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      TablerIcons.wallet,
                      size: 38,
                      color: context.onPrimary,
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: context.secondary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimens.spacingLg),
              Text(
                AppStrings.appName,
                style: TextStyle(
                  fontSize: AppDimens.fontSizeHeadingLg,
                  fontWeight: AppDimens.fontWeightMedium,
                  color: context.textPrimary,
                ),
              ),
              const SizedBox(height: AppDimens.gapSm),
              Text(
                AppStrings.loading,
                style: TextStyle(
                  fontSize: AppDimens.fontSizeCaption,
                  color: context.textSecondary,
                ),
              ),
              const SizedBox(height: AppDimens.spacingMd),
              const _PulsingDots(),
            ],
          ),
        ),
      ),
    );
  }
}

class _PulsingDots extends StatefulWidget {
  const _PulsingDots();

  @override
  State<_PulsingDots> createState() => _PulsingDotsState();
}

class _PulsingDotsState extends State<_PulsingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Motion.reduced.value
          ? _buildDots((_) => 1)
          : AnimatedBuilder(
              animation: _controller,
              builder: (context, _) => _buildDots(
                (i) => 0.25 + 0.75 * ((_controller.value * 3 - i) % 3 / 3),
              ),
            ),
    );
  }

  Widget _buildDots(double Function(int index) alphaFor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < 3; i++) ...[
          if (i > 0) const SizedBox(width: AppDimens.gapXs),
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: context.primary.withValues(alpha: alphaFor(i)),
              shape: BoxShape.circle,
            ),
          ),
        ],
      ],
    );
  }
}