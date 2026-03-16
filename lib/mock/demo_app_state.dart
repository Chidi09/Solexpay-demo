import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../core/constants/demo_data.dart';
import 'mock_transfer_service.dart';
import '../shared/models/loan_state.dart';
import '../shared/models/notification_item.dart';
import '../shared/models/transaction_item.dart';
import '../shared/models/transfer_draft.dart';
import '../shared/models/user_profile.dart';

class DemoAppState extends ChangeNotifier {
  DemoAppState({
    required UserProfile userProfile,
    required double balance,
    required double savingsBalance,
    required LoanState loanState,
    required List<TransactionItem> transactions,
    required List<NotificationItem> notifications,
  }) : _userProfile = userProfile,
       _balance = balance,
       _savingsBalance = savingsBalance,
       _loanState = loanState,
       _transactions = List<TransactionItem>.of(transactions),
       _notifications = List<NotificationItem>.of(notifications);

  factory DemoAppState.seeded() {
    return DemoAppState(
      userProfile: demoUserProfile,
      balance: demoWalletBalance,
      savingsBalance: demoSavingsBalance,
      loanState: demoLoanState,
      transactions: demoTransactions,
      notifications: demoNotifications,
    );
  }

  UserProfile _userProfile;
  double _balance;
  double _savingsBalance;
  LoanState _loanState;
  final List<TransactionItem> _transactions;
  final List<NotificationItem> _notifications;
  TransferDraft? _activeTransferDraft;

  UserProfile get userProfile => _userProfile;
  double get balance => _balance;
  double get savingsBalance => _savingsBalance;
  LoanState get loanState => _loanState;
  UnmodifiableListView<TransactionItem> get transactions =>
      UnmodifiableListView<TransactionItem>(_transactions);
  UnmodifiableListView<NotificationItem> get notifications =>
      UnmodifiableListView<NotificationItem>(_notifications);
  TransferDraft? get activeTransferDraft => _activeTransferDraft;

  int get unreadNotifications =>
      _notifications.where((NotificationItem item) => item.isUnread).length;

  void updateWalletBalance(double newBalance) {
    _balance = newBalance;
    notifyListeners();
  }

  void updateSavingsBalance(double newSavingsBalance) {
    _savingsBalance = newSavingsBalance;
    notifyListeners();
  }

  void replaceUserProfile(UserProfile profile) {
    _userProfile = profile;
    notifyListeners();
  }

  void updateLoanState(LoanState value) {
    _loanState = value;
    notifyListeners();
  }

  void prependTransaction(TransactionItem item) {
    _transactions.insert(0, item);
    notifyListeners();
  }

  void addNotification(NotificationItem item) {
    _notifications.insert(0, item);
    notifyListeners();
  }

  void setTransferDraft(TransferDraft draft) {
    _activeTransferDraft = draft;
    notifyListeners();
  }

  void clearTransferDraft() {
    _activeTransferDraft = null;
    notifyListeners();
  }

  Future<void> completeTransfer(
    TransferDraft draft, {
    TransferOutcome outcome = TransferOutcome.success,
  }) async {
    final DateTime now = DateTime.now();
    if (outcome == TransferOutcome.success) {
      _balance -= draft.totalDeducted;
    }

    final TransactionStatus status;
    switch (outcome) {
      case TransferOutcome.success:
        status = TransactionStatus.completed;
      case TransferOutcome.pending:
        status = TransactionStatus.pending;
      case TransferOutcome.failed:
        status = TransactionStatus.failed;
    }

    _transactions.insert(
      0,
      TransactionItem(
        id: 'txn_${now.microsecondsSinceEpoch}',
        title: 'Transfer to ${draft.recipientName}',
        subtitle:
            draft.note ??
            (draft.type == TransferType.bank
                ? 'Bank transfer'
                : 'SolexPay transfer'),
        amount: draft.amount,
        occurredAt: now,
        type: TransactionType.debit,
        status: status,
      ),
    );

    notifyListeners();
  }
}
