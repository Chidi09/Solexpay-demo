import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:solexpay_demo_app/features/savings/presentation/savings_screen.dart';
import 'package:solexpay_demo_app/mock/demo_app_state.dart';

void main() {
  testWidgets('savings screen shows total saved', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => DemoAppState.seeded(),
        child: const MaterialApp(home: SavingsScreen()),
      ),
    );

    // Pump once to build, then pump a frame to flush animation timers
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.textContaining('Total Saved'), findsOneWidget);
  });
}
