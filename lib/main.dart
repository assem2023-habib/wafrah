import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'core/services/app_icon_service.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/motion.dart';
import 'core/theme/theme_service.dart';
import 'data/hive_service.dart';
import 'data/repositories/repository_bindings.dart';
import 'modules/electricity_home/electricity_home_controller.dart';
import 'modules/home/home_controller.dart';
import 'modules/statistics/statistics_controller.dart';
import 'modules/transaction_detail/transaction_detail_controller.dart';
import 'modules/transactions/transactions_controller.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init();
  await HiveService.seedIfNeeded();
  await ThemeService.init();
  Motion.init();
  final initialMode = ThemeService.load();
  await AppIconService.setIcon(isDark: initialMode == ThemeMode.dark);
  RepositoryBindings.init();
  runApp(WafrahApp(initialThemeMode: initialMode));
}

class WafrahApp extends StatelessWidget {
  const WafrahApp({super.key, required this.initialThemeMode});

  final ThemeMode initialThemeMode;

  void _refreshOnBack(Routing? routing) {
    if (routing == null || routing.isBack != true) {
      return;
    }
    if (routing.current == AppRoutes.home) {
      _refresh<HomeController>((c) => c.load(silent: true));
      _refresh<TransactionsController>((c) => c.load(silent: true));
      _refresh<StatisticsController>((c) => c.load(silent: true));
      _refresh<ElectricityHomeController>((c) => c.load(silent: true));
    }
    if (routing.current == AppRoutes.transactionDetail) {
      _refresh<TransactionDetailController>((c) => c.reloadCurrent());
    }
  }

  void _refresh<T>(void Function(T controller) action) {
    if (Get.isRegistered<T>()) {
      action(Get.find<T>());
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'وِفرة',
      theme: buildAppTheme(Brightness.light),
      darkTheme: buildAppTheme(Brightness.dark),
      themeMode: initialThemeMode,
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      initialRoute: AppRoutes.splash,
      getPages: AppPages.pages,
      routingCallback: _refreshOnBack,
    );
  }
}
