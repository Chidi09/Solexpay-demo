import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solexpay_demo_app/features/transfers/presentation/transfer_review_screen.dart';
import 'package:solexpay_demo_app/shared/models/transfer_draft.dart';

void main() {
  testWidgets('transfer review shows total deducted', (
    WidgetTester tester,
  ) async {
    // Use a narrow viewport so DemoDeviceShell renders the plain child (no frame)
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final TransferDraft draft = TransferDraft.p2p(
      recipientName: 'John Doe',
      amount: 2000,
    );

    await tester.pumpWidget(
      MaterialApp(home: TransferReviewScreen(draft: draft)),
    );

    expect(find.textContaining('Total deducted'), findsOneWidget);
  });
}
