import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/constants/app_dimens.dart';
import '../core/theme/motion.dart';
import '../core/theme/app_theme.dart';

class SkeletonCard extends StatefulWidget {
  const SkeletonCard({
    super.key,
    this.width,
    this.height,
    this.radius = AppDimens.radiusLg,
  });

  final double? width;
  final double? height;
  final double radius;

  @override
  State<SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<SkeletonCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: context.muted,
        borderRadius: BorderRadius.circular(widget.radius),
      ),
    );
    return Obx(
      () => Motion.reduced.value
          ? base
          : AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final t = _controller.value;
                return ShaderMask(
                  blendMode: BlendMode.srcATop,
                  shaderCallback: (bounds) {
                    return LinearGradient(
                      begin: Alignment(-1.5 + t * 3, 0),
                      end: Alignment(-0.5 + t * 3, 0),
                      colors: [
                        context.muted,
                        context.onMuted,
                        context.muted,
                      ],
                      stops: const [0.3, 0.5, 0.7],
                    ).createShader(bounds);
                  },
                  child: child,
                );
              },
              child: base,
            ),
    );
  }
}
