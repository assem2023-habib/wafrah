import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:wafrah/main.dart';

void main() {
  testWidgets('App renders smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const WafrahApp());
    await tester.pump();

    expect(find.byType(Scaffold), findsWidgets);
  });
}
