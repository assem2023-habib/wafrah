import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import 'package:wafrah/core/constants/app_strings.dart';
import 'package:wafrah/core/theme/app_theme.dart';
import 'package:wafrah/data/models/transaction.dart';
import 'package:wafrah/widgets/app_buttons.dart';
import 'package:wafrah/widgets/app_card.dart';
import 'package:wafrah/widgets/app_empty_state.dart';
import 'package:wafrah/widgets/app_error_banner.dart';
import 'package:wafrah/widgets/app_number_field.dart';
import 'package:wafrah/widgets/bottom_nav.dart';
import 'package:wafrah/widgets/success_screen.dart';
import 'package:wafrah/widgets/transaction_item.dart';

Widget wrap(Widget child) => MaterialApp(
      theme: buildAppTheme(Brightness.light),
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Scaffold(body: child),
    );

void main() {
  group('AppPrimaryButton', () {
    testWidgets('shows label and fires onPressed', (tester) async {
      var pressed = false;
      await tester.pumpWidget(
        wrap(AppPrimaryButton(
          label: AppStrings.save,
          onPressed: () => pressed = true,
        )),
      );
      await tester.pump();
      expect(find.text(AppStrings.save), findsOneWidget);
      await tester.tap(find.text(AppStrings.save));
      expect(pressed, isTrue);
    });
  });

  group('AppSecondaryButton', () {
    testWidgets('shows label', (tester) async {
      await tester.pumpWidget(
        wrap(const AppSecondaryButton(label: AppStrings.cancel)),
      );
      await tester.pump();
      expect(find.text(AppStrings.cancel), findsOneWidget);
    });
  });

  group('AppErrorBanner', () {
    testWidgets('shows message and fires onClose', (tester) async {
      var closed = false;
      await tester.pumpWidget(
        wrap(AppErrorBanner(
          message: AppStrings.warning,
          onClose: () => closed = true,
        )),
      );
      await tester.pump();
      expect(find.text(AppStrings.warning), findsOneWidget);
      await tester.tap(find.byIcon(TablerIcons.x));
      expect(closed, isTrue);
    });
  });

  group('AppEmptyState', () {
    testWidgets('shows title and fires action', (tester) async {
      var acted = false;
      await tester.pumpWidget(
        wrap(AppEmptyState(
          icon: TablerIcons.alert_circle,
          title: AppStrings.noTransactions,
          actionLabel: AppStrings.addTransaction,
          onAction: () => acted = true,
        )),
      );
      await tester.pump();
      expect(find.text(AppStrings.noTransactions), findsOneWidget);
      await tester.tap(find.text(AppStrings.addTransaction));
      expect(acted, isTrue);
    });
  });

  group('BottomNav', () {
    testWidgets('shows four items and fires onTap with index', (tester) async {
      int? tapped;
      await tester.pumpWidget(
        wrap(BottomNav(currentIndex: 0, onTap: (index) => tapped = index)),
      );
      await tester.pump();
      expect(find.text(AppStrings.navHome), findsOneWidget);
      expect(find.text(AppStrings.transactions), findsOneWidget);
      expect(find.text(AppStrings.statistics), findsOneWidget);
      expect(find.text(AppStrings.electricity), findsOneWidget);
      await tester.tap(find.text(AppStrings.statistics));
      expect(tapped, 2);
    });
  });

  group('AppCard', () {
    testWidgets('shows its child', (tester) async {
      await tester.pumpWidget(wrap(const AppCard(child: Text('card child'))));
      await tester.pump();
      expect(find.text('card child'), findsOneWidget);
    });
  });

  group('TransactionItem', () {
    testWidgets('shows income amount with plus sign', (tester) async {
      final transaction = Transaction(
        id: '1',
        type: TransactionType.income,
        amount: 1000,
        date: DateTime(2026, 1, 1),
      );
      await tester.pumpWidget(
        wrap(TransactionItem(
          transaction: transaction,
          categoryName: AppStrings.incomeBadge,
        )),
      );
      await tester.pump();
      expect(find.text('+ ١,٠٠٠ ل.س'), findsOneWidget);
    });

    testWidgets('shows expense amount with minus sign', (tester) async {
      final transaction = Transaction(
        id: '2',
        type: TransactionType.expense,
        amount: 500,
        date: DateTime(2026, 1, 1),
        note: AppStrings.note,
      );
      await tester.pumpWidget(
        wrap(TransactionItem(
          transaction: transaction,
          categoryName: AppStrings.expenseBadge,
        )),
      );
      await tester.pump();
      expect(find.text('- ٥٠٠ ل.س'), findsOneWidget);
    });
  });

  group('SuccessScreen', () {
    testWidgets('shows message', (tester) async {
      await tester.pumpWidget(
        wrap(const SuccessScreen(message: AppStrings.savedSuccess)),
      );
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.savedSuccess), findsOneWidget);
    });
  });

  group('AppNumberField', () {
    testWidgets('formats input to Arabic digits with separators',
        (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        wrap(AppNumberField(
          label: AppStrings.amount,
          controller: controller,
          suffix: AppStrings.currencyUnit,
        )),
      );
      await tester.pump();
      await tester.enterText(find.byType(TextField), '1000');
      expect(controller.text, '١,٠٠٠');
    });
  });
}
