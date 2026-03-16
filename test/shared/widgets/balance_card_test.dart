import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solexpay_demo_app/shared/widgets/balance_card.dart';

void main() {
  testWidgets('balance card renders amount and account number', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: BalanceCard(balance: 47500, accountNumber: '0123 456 789'),
        ),
      ),
    );

    expect(find.textContaining('47,500'), findsOneWidget);
    expect(find.text('0123 456 789'), findsOneWidget);
  });
}
