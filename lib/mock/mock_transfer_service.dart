import '../shared/models/transfer_draft.dart';

enum TransferOutcome { success, pending, failed }

class MockTransferService {
  const MockTransferService({this.delay = const Duration(milliseconds: 900)});

  final Duration delay;

  Future<TransferOutcome> submitTransfer(TransferDraft draft) async {
    await Future<void>.delayed(delay);
    if (draft.amount <= 0) {
      return TransferOutcome.failed;
    }
    if (draft.amount >= 50000) {
      return TransferOutcome.pending;
    }
    if (draft.amount >= 20000) {
      return TransferOutcome.failed;
    }
    return TransferOutcome.success;
  }
}
