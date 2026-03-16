import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solexpay_demo_app/features/transfers/presentation/transfer_animation_screen.dart';
import 'package:solexpay_demo_app/shared/models/transfer_draft.dart';

void main() {
  testWidgets('transfer animation shows sending state', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        home: TransferAnimationScreen(
          draft: TransferDraft.p2p(recipientName: 'John Doe', amount: 2000),
        ),
      ),
    );
    await tester.pump();

    expect(find.textContaining('Sending'), findsOneWidget);
  });
}
