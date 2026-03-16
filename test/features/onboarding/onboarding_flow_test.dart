import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solexpay_demo_app/app/app.dart';

void main() {
  testWidgets('onboarding flow reaches shell after valid inputs', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const SolexPayApp());

    expect(find.text('SolexPay'), findsOneWidget);

    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    expect(find.textContaining('SolexPay'), findsWidgets);

    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, '8012345678');
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, '123456');
    await tester.pump();
    await tester.tap(find.text('Verify OTP'));
    await tester.pump(const Duration(milliseconds: 950));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, '12345678901');
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Capture Selfie'));
    await tester.pump(const Duration(milliseconds: 1450));
    await tester.pumpAndSettle();

    expect(find.textContaining('all set'), findsOneWidget);

    await tester.tap(find.text('Set Transaction PIN'));
    await tester.pumpAndSettle();

    final Finder pinFields = find.byType(TextField);
    expect(pinFields, findsNWidgets(2));
    await tester.enterText(pinFields.at(0), '1234');
    await tester.enterText(pinFields.at(1), '1234');
    await tester.pump();

    await tester.tap(find.text('Finish Setup'));
    await tester.pump(const Duration(milliseconds: 850));
    await tester.pumpAndSettle();

    expect(find.text('Available balance'), findsOneWidget);
  });
}
