import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:solexpay_demo_app/features/bills/presentation/airtime_screen.dart';
import 'package:solexpay_demo_app/mock/demo_app_state.dart';

void main() {
  testWidgets('airtime screen shows cashback offer', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => DemoAppState.seeded(),
        child: const MaterialApp(home: AirtimeScreen()),
      ),
    );

    await tester.pump(const Duration(milliseconds: 500));

    expect(find.textContaining('Cashback'), findsAtLeastNWidgets(1));
  });
}
