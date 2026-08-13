import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';

void main() {
  runApp(const WafrahApp());
}

class WafrahApp extends StatelessWidget {
  const WafrahApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wafrah',
      theme: buildAppTheme(Brightness.light),
      darkTheme: buildAppTheme(Brightness.dark),
      home: const Scaffold(
        body: Center(child: Text('Wafrah')),
      ),
    );
  }
}
