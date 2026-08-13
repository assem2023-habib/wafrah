import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:wafrah/core/constants/app_strings.dart';
import 'package:wafrah/data/models/transaction.dart';
import 'package:wafrah/data/repositories/interfaces/transaction_repository_interface.dart';
import 'package:wafrah/modules/add_income/add_income_controller.dart';
import 'package:wafrah/modules/add_income/add_income_view.dart';
import 'package:wafrah/routes/app_routes.dart';
import 'package:wafrah/widgets/app_number_field.dart';

class FakeTransactionRepository implements ITransactionRepository {
  FakeTransactionRepository([List<Transaction>? items]) : _items = items ?? [];

  final List<Transaction> _items;
  bool added = false;
  Transaction? lastAdded;

  @override
  Future<List<Transaction>> getAll() async => List.of(_items);

  @override
  Future<Transaction?> getById(String id) async {
    for (final item in _items) {
      if (item.id == id) return item;
    }
    return null;
  }

  @override
  Future<Transaction> add(Transaction transaction) async {
    added = true;
    lastAdded = transaction;
    _items.add(transaction);
    return transaction;
  }

  @override
  Future<void> update(Transaction transaction) async {
    final index = _items.indexWhere((t) => t.id == transaction.id);
    if (index != -1) _items[index] = transaction;
  }

  @override
  Future<void> delete(String id) async {
    _items.removeWhere((t) => t.id == id);
  }
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('ar');
  });

  setUp(() {
    Get.reset();
  });

  testWidgets('saving income shows success dialog and adds transaction',
      (tester) async {
    final txRepo = FakeTransactionRepository();
    final controller = AddIncomeController(transactionRepository: txRepo);
    Get.put(controller);
    await tester.pumpWidget(
      GetMaterialApp(
        locale: const Locale('ar'),
        home: const AddIncomeView(),
        getPages: [
          GetPage(name: AppRoutes.home, page: () => const SizedBox()),
        ],
      ),
    );
    await tester.pumpAndSettle();

    final amountField = find.descendant(
      of: find.byType(AppNumberField).first,
      matching: find.byType(TextField),
    );
    await tester.enterText(amountField, '1000');
    await tester.tap(find.text(AppStrings.saveIncome));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.savedSuccess), findsOneWidget);
    expect(txRepo.added, isTrue);
    expect(txRepo.lastAdded!.type, TransactionType.income);
    expect(txRepo.lastAdded!.amount, 1000);

    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.savedSuccess), findsNothing);
  });
}