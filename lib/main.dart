import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';

import 'core/theme/app_theme.dart';
import 'data/hive_service.dart';
import 'data/repositories/repository_bindings.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init();
  await HiveService.seedIfNeeded();
  RepositoryBindings.init();
  runApp(const WafrahApp());
}

class WafrahApp extends StatelessWidget {
  const WafrahApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'وِفرة',
      theme: buildAppTheme(Brightness.light),
      darkTheme: buildAppTheme(Brightness.dark),
      themeMode: ThemeMode.system,
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      initialRoute: AppRoutes.splash,
      getPages: AppPages.pages,
      navigatorObservers: [AppPages.appRouteObserver],
    );
  }
}
