import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../core/constants/app_dimens.dart';
import '../core/theme/app_theme.dart';
import '../core/constants/app_strings.dart';

class BottomNav extends StatelessWidget {
  const BottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const List<IconData> _icons = [
    TablerIcons.home,
    TablerIcons.list,
    TablerIcons.chart_pie,
    TablerIcons.bolt,
  ];

  static const List<String> _labels = [
    AppStrings.navHome,
    AppStrings.transactions,
    AppStrings.statistics,
    AppStrings.electricity,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.surface,
        border: Border(top: BorderSide(color: context.border)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              for (var i = 0; i < _icons.length; i++)
                Expanded(
                  child: _NavItem(
                    icon: _icons[i],
                    label: _labels[i],
                    active: i == currentIndex,
                    onTap: () => onTap(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? context.primary : context.textSecondary;
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: AppDimens.gapXs),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: active
                  ? AppDimens.fontWeightMedium
                  : AppDimens.fontWeightNormal,
              color: color,
            ),
          ),
          const SizedBox(height: AppDimens.gapXs),
          Container(
            width: 20,
            height: 3,
            decoration: BoxDecoration(
              color: active ? context.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(AppDimens.radiusFull),
            ),
          ),
        ],
      ),
    );
  }
}