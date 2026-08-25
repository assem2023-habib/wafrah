import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../widgets/bottom_nav.dart';
import '../electricity_home/electricity_home_view.dart';
import '../home/home_view.dart';
import '../statistics/statistics_view.dart';
import '../transactions/transactions_view.dart';
import 'main_shell_controller.dart';

class MainShellView extends StatelessWidget {
  const MainShellView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MainShellController>();
    return Scaffold(
      body: SafeArea(
        child: Obx(
          () => Column(
            children: [
              Expanded(
                child: IndexedStack(
                  index: controller.currentIndex.value,
                  children: const [
                    HomeView(),
                    TransactionsView(),
                    StatisticsView(),
                    ElectricityHomeView(),
                  ],
                ),
              ),
              BottomNav(
                currentIndex: controller.currentIndex.value,
                onTap: controller.changeTab,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
