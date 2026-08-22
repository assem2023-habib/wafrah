import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../core/constants/app_dimens.dart';
import '../core/constants/app_strings.dart';
import 'app_empty_state.dart';
import 'page_header.dart';

class ComingSoonView extends StatelessWidget {
  const ComingSoonView({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppDimens.spacingMd),
              child: PageHeader(
                title: title,
                onBack: () => Navigator.of(context).pop(),
              ),
            ),
            const Expanded(
              child: AppEmptyState(
                icon: TablerIcons.tools,
                title: AppStrings.comingSoon,
              ),
            ),
          ],
        ),
      ),
    );
  }
}