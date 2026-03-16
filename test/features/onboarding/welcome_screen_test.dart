import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solexpay_demo_app/features/onboarding/presentation/welcome_screen.dart';

void main() {
  testWidgets('welcome screen shows get started CTA', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: WelcomeScreen()));

    expect(find.text('Get Started'), findsOneWidget);
  });
}
