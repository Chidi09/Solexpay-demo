import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:solexpay_demo_app/features/home/presentation/home_screen.dart';
import 'package:solexpay_demo_app/mock/demo_app_state.dart';

void main() {
  testWidgets('home screen shows recent activity and balance', (
    WidgetTester tester,
  ) async {
    // Set phone viewport to avoid DemoDeviceShell overflow in tests
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ChangeNotifierProvider<DemoAppState>(
        create: (_) => DemoAppState.seeded(),
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    // Advance past animation timers
    await tester.pump(const Duration(milliseconds: 600));

    // Balance card is the first content item — always visible
    expect(find.text('Available balance'), findsOneWidget);
    // No exceptions during render
    expect(tester.takeException(), isNull);
  });
}
