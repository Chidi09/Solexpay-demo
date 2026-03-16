enum TransferType { p2p, bank }

class TransferDraft {
  const TransferDraft({
    required this.type,
    required this.recipientName,
    required this.amount,
    required this.fee,
    this.bankName,
    this.accountNumber,
    this.note,
  });

  factory TransferDraft.p2p({
    required String recipientName,
    required double amount,
    String? note,
  }) {
    return TransferDraft(
      type: TransferType.p2p,
      recipientName: recipientName,
      amount: amount,
      fee: 0,
      note: note,
    );
  }

  factory TransferDraft.bank({
    required String recipientName,
    required String bankName,
    required String accountNumber,
    required double amount,
    double fee = 26,
    String? note,
  }) {
    return TransferDraft(
      type: TransferType.bank,
      recipientName: recipientName,
      amount: amount,
      fee: fee,
      bankName: bankName,
      accountNumber: accountNumber,
      note: note,
    );
  }

  final TransferType type;
  final String recipientName;
  final double amount;
  final double fee;
  final String? bankName;
  final String? accountNumber;
  final String? note;

  double get totalDeducted => amount + fee;
}
