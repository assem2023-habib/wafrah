import 'package:get/get.dart';

import '../modules/add_expense/add_expense_binding.dart';
import '../modules/add_expense/add_expense_view.dart';
import '../modules/add_income/add_income_binding.dart';
import '../modules/add_income/add_income_view.dart';
import '../modules/home/home_binding.dart';
import '../modules/home/home_view.dart';
import '../modules/splash/splash_binding.dart';
import '../modules/splash/splash_view.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

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
  ];
}