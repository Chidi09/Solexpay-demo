class LoanState {
  const LoanState({
    required this.isEligible,
    this.activeProduct,
    this.outstandingBalance = 0,
    this.monthlyRepayment = 0,
    this.nextDueDate,
  });

  final bool isEligible;
  final String? activeProduct;
  final double outstandingBalance;
  final double monthlyRepayment;
  final DateTime? nextDueDate;

  bool get hasActiveLoan => activeProduct != null && outstandingBalance > 0;
}
