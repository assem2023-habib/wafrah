import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:wafrah/core/constants/app_strings.dart';
import 'package:wafrah/modules/splash/splash_controller.dart';
import 'package:wafrah/modules/splash/splash_view.dart';
import 'package:wafrah/routes/app_routes.dart';

void main() {
  setUp(() {
    Get.reset();
  });

  testWidgets('shows app name and loading indicator', (tester) async {
    Get.put(SplashController());
    await tester.pumpWidget(
      GetMaterialApp(
        locale: const Locale('ar'),
        home: const SplashView(),
        getPages: [
          GetPage(name: AppRoutes.home, page: () => const SizedBox()),
        ],
      ),
    );

    await tester.pump();
    expect(find.text(AppStrings.appName), findsOneWidget);
    expect(find.text(AppStrings.loading), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1300));
    await tester.pumpAndSettle();
  });
}