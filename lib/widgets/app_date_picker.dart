import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:intl/intl.dart';

import '../core/constants/app_dimens.dart';
import '../core/theme/app_theme.dart';
import '../core/constants/app_strings.dart';
import '../core/utils/number_formatter.dart';

class AppDatePicker extends StatefulWidget {
  const AppDatePicker({
    super.key,
    this.initialDate,
    required this.onConfirm,
    this.onCancel,
  });

  final DateTime? initialDate;
  final ValueChanged<DateTime> onConfirm;
  final VoidCallback? onCancel;

  @override
  State<AppDatePicker> createState() => _AppDatePickerState();
}

class _AppDatePickerState extends State<AppDatePicker> {
  late int _year;
  late int _month;
  DateTime? _selected;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialDate ?? DateTime.now();
    _year = initial.year;
    _month = initial.month;
    _selected = widget.initialDate;
  }

  void _previousMonth() {
    setState(() {
      if (_month == 1) {
        _year -= 1;
        _month = 12;
      } else {
        _month -= 1;
      }
    });
  }

  void _nextMonth() {
    setState(() {
      if (_month == 12) {
        _year += 1;
        _month = 1;
      } else {
        _month += 1;
      }
    });
  }

  DateTime _dateOf(int day) => DateTime(_year, _month, day);

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Widget _buildCell({
    required int index,
    required int leading,
    required int daysInMonth,
    required int previousMonthDays,
    required DateTime today,
  }) {
    final isCurrentMonth = index >= leading && index < leading + daysInMonth;
    final day = isCurrentMonth
        ? index - leading + 1
        : index < leading
            ? previousMonthDays - leading + index + 1
            : index - leading - daysInMonth + 1;
    final date = _dateOf(day);
    final isSelected = _selected != null && _sameDay(_selected!, date);
    final isToday = _sameDay(today, date);

    return InkWell(
      onTap: isCurrentMonth ? () => setState(() => _selected = date) : null,
      customBorder: const CircleBorder(),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? context.primary : null,
          border: isToday && !isSelected
              ? Border.all(color: context.primary, width: 1.5)
              : null,
        ),
        child: Text(
          NumberFormatter.formatNumber(day),
          style: TextStyle(
            fontSize: AppDimens.fontSizeLabel,
            fontWeight: isSelected || isToday
                ? AppDimens.fontWeightMedium
                : AppDimens.fontWeightNormal,
            color: isSelected
                ? context.onPrimary
                : (isCurrentMonth
                    ? context.textPrimary
                    : context.textSecondary),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final firstDay = DateTime(_year, _month, 1);
    final daysInMonth = DateTime(_year, _month + 1, 0).day;
    final leading = firstDay.weekday % 7;
    final previousMonthDays = DateTime(_year, _month, 0).day;
    final totalCells = ((leading + daysInMonth + 6) ~/ 7) * 7;

    return Container(
      width: 320,
      padding: const EdgeInsets.all(AppDimens.spacingMd),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusXl),
        border: Border.all(color: context.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: _previousMonth,
                style: IconButton.styleFrom(
                  fixedSize:
                      const Size(AppDimens.iconButton, AppDimens.iconButton),
                ),
                icon: Icon(
                  TablerIcons.chevron_right,
                  size: AppDimens.iconLg,
                  color: context.textPrimary,
                ),
              ),
              Expanded(
                child: Text(
                  DateFormat('MMMM yyyy', 'ar')
                      .format(DateTime(_year, _month)),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: AppDimens.fontSizeHeading,
                    fontWeight: AppDimens.fontWeightMedium,
                    color: context.textPrimary,
                  ),
                ),
              ),
              IconButton(
                onPressed: _nextMonth,
                style: IconButton.styleFrom(
                  fixedSize:
                      const Size(AppDimens.iconButton, AppDimens.iconButton),
                ),
                icon: Icon(
                  TablerIcons.chevron_left,
                  size: AppDimens.iconLg,
                  color: context.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.gapSm),
          Row(
            children: [
              for (var i = 0; i < 7; i++)
                Expanded(
                  child: Center(
                    child: Text(
                      AppStrings.weekdayLetters[i],
                      style: TextStyle(
                        fontSize: AppDimens.fontSizeLabel,
                        fontWeight: AppDimens.fontWeightMedium,
                        color: context.textSecondary,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppDimens.gapSm),
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: AppDimens.gapXs,
            crossAxisSpacing: AppDimens.gapXs,
            children: [
              for (var i = 0; i < totalCells; i++)
                _buildCell(
                  index: i,
                  leading: leading,
                  daysInMonth: daysInMonth,
                  previousMonthDays: previousMonthDays,
                  today: today,
                ),
            ],
          ),
          const SizedBox(height: AppDimens.spacingMd),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => widget.onCancel?.call(),
                  child: const Text(AppStrings.cancel),
                ),
              ),
              const SizedBox(width: AppDimens.gapMd),
              Expanded(
                child: FilledButton(
                  onPressed: _selected == null
                      ? null
                      : () => widget.onConfirm(_selected!),
                  child: const Text(AppStrings.confirm),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}