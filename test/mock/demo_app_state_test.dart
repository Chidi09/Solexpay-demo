import 'package:flutter_test/flutter_test.dart';
import 'package:solexpay_demo_app/mock/demo_app_state.dart';
import 'package:solexpay_demo_app/mock/mock_transfer_service.dart';
import 'package:solexpay_demo_app/shared/models/transfer_draft.dart';

void main() {
  test('seeded state starts with transactions and positive balance', () {
    final state = DemoAppState.seeded();

    expect(state.balance, greaterThan(0));
    expect(state.transactions, isNotEmpty);
  });

  test(
    'successful transfer updates balance and prepends transaction',
    () async {
      final state = DemoAppState.seeded();
      final double before = state.balance;

      await state.completeTransfer(
        TransferDraft.p2p(recipientName: 'John Doe', amount: 2000),
      );

      expect(state.balance, before - 2000);
      expect(state.transactions.first.title, contains('John Doe'));
    },
  );

  test(
    'failed transfer keeps balance but prepends failed transaction',
    () async {
      final state = DemoAppState.seeded();
      final double before = state.balance;

      await state.completeTransfer(
        TransferDraft.bank(
          recipientName: 'Jane Doe',
          bankName: 'Solex Bank',
          accountNumber: '0123456789',
          amount: 30000,
        ),
        outcome: TransferOutcome.failed,
      );

      expect(state.balance, before);
      expect(state.transactions.first.title, contains('Jane Doe'));
    },
  );
}
