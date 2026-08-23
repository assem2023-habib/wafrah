import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../core/constants/app_strings.dart';
import '../modules/add_expense/add_expense_binding.dart';
import '../modules/add_expense/add_expense_view.dart';
import '../modules/add_income/add_income_binding.dart';
import '../modules/add_income/add_income_view.dart';
import '../modules/categories/categories_binding.dart';
import '../modules/categories/categories_view.dart';
import '../modules/electricity_home/electricity_home_binding.dart';
import '../modules/electricity_home/electricity_home_view.dart';
import '../modules/home/home_binding.dart';
import '../modules/home/home_view.dart';
import '../modules/products/products_binding.dart';
import '../modules/products/products_view.dart';
import '../modules/settings/settings_binding.dart';
import '../modules/settings/settings_view.dart';
import '../modules/splash/splash_binding.dart';
import '../modules/splash/splash_view.dart';
import '../modules/transaction_detail/transaction_detail_binding.dart';
import '../modules/transaction_detail/transaction_detail_view.dart';
import '../modules/transactions/transactions_binding.dart';
import '../modules/transactions/transactions_view.dart';
import '../widgets/coming_soon_view.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static final RouteObserver<PageRoute<void>> appRouteObserver =
      RouteObserver<PageRoute<void>>();

  static final List<GetPage> pages = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.addExpense,
      page: () => const AddExpenseView(),
      binding: AddExpenseBinding(),
    ),
    GetPage(
      name: AppRoutes.addIncome,
      page: () => const AddIncomeView(),
      binding: AddIncomeBinding(),
    ),
    GetPage(
      name: AppRoutes.transactions,
      page: () => const TransactionsView(),
      binding: TransactionsBinding(),
    ),
    GetPage(
      name: AppRoutes.transactionDetail,
      page: () => const TransactionDetailView(),
      binding: TransactionDetailBinding(),
    ),
    GetPage(
      name: AppRoutes.categories,
      page: () => const CategoriesView(),
      binding: CategoriesBinding(),
    ),
    GetPage(
      name: AppRoutes.products,
      page: () => const ProductsView(),
      binding: ProductsBinding(),
    ),
    GetPage(
      name: AppRoutes.statistics,
      page: () => const ComingSoonView(title: AppStrings.statistics),
    ),
    GetPage(
      name: AppRoutes.electricity,
      page: () => const ElectricityHomeView(),
      binding: ElectricityHomeBinding(),
    ),
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
    ),
  ];
}