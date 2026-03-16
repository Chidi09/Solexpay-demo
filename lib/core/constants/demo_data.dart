import '../../shared/models/loan_state.dart';
import '../../shared/models/notification_item.dart';
import '../../shared/models/transaction_item.dart';
import '../../shared/models/user_profile.dart';

const double demoWalletBalance = 47500;
const double demoSavingsBalance = 12500;

final UserProfile demoUserProfile = UserProfile(
  id: 'usr_student_001',
  fullName: 'Ifeoma Adeyemi',
  tag: '@ifeoma.a',
  phoneNumber: '+234 803 555 0198',
  school: 'University of Lagos',
  accountNumber: '0123456789',
  walletId: 'SPY-220491',
);

final LoanState demoLoanState = LoanState(
  isEligible: true,
  activeProduct: 'Campus Flex Loan',
  outstandingBalance: 18000,
  monthlyRepayment: 6000,
  nextDueDate: DateTime(2026, 3, 28),
);

final List<NotificationItem> demoNotifications = <NotificationItem>[
  NotificationItem(
    id: 'notif_001',
    title: 'Scholarship received',
    message: 'NGN 15,000 has landed in your wallet from Greenlight Scholars.',
    createdAt: DateTime(2026, 3, 13, 8, 15),
  ),
  NotificationItem(
    id: 'notif_002',
    title: 'Savings streak intact',
    message: 'You saved for the fourth week in a row. Keep it going.',
    createdAt: DateTime(2026, 3, 12, 18, 40),
  ),
  NotificationItem(
    id: 'notif_003',
    title: 'Loan repayment due soon',
    message: 'Your Campus Flex repayment is due in 15 days.',
    createdAt: DateTime(2026, 3, 11, 11, 0),
    isUnread: false,
  ),
];

final List<TransactionItem> demoTransactions = <TransactionItem>[
  TransactionItem(
    id: 'txn_001',
    title: 'Scholarship payout',
    subtitle: 'Greenlight Scholars',
    amount: 15000,
    occurredAt: DateTime(2026, 3, 13, 8, 12),
    type: TransactionType.credit,
    status: TransactionStatus.completed,
  ),
  TransactionItem(
    id: 'txn_002',
    title: 'Cafe lunch',
    subtitle: 'SolexPay QR at Campus Cafe',
    amount: 2800,
    occurredAt: DateTime(2026, 3, 12, 13, 5),
    type: TransactionType.debit,
    status: TransactionStatus.completed,
  ),
  TransactionItem(
    id: 'txn_003',
    title: 'Data bundle top-up',
    subtitle: 'MTN 15GB student plan',
    amount: 3500,
    occurredAt: DateTime(2026, 3, 11, 19, 45),
    type: TransactionType.debit,
    status: TransactionStatus.completed,
  ),
  TransactionItem(
    id: 'txn_004',
    title: 'Savings auto-save',
    subtitle: 'Weekly target pot',
    amount: 5000,
    occurredAt: DateTime(2026, 3, 10, 7, 0),
    type: TransactionType.debit,
    status: TransactionStatus.completed,
  ),
  TransactionItem(
    id: 'txn_005',
    title: 'Roommate refund',
    subtitle: 'Aisha Bello',
    amount: 4200,
    occurredAt: DateTime(2026, 3, 9, 20, 18),
    type: TransactionType.credit,
    status: TransactionStatus.completed,
  ),
  TransactionItem(
    id: 'txn_006',
    title: 'Bookshop transfer',
    subtitle: 'Pending settlement',
    amount: 1800,
    occurredAt: DateTime(2026, 3, 8, 16, 10),
    type: TransactionType.debit,
    status: TransactionStatus.pending,
  ),
];
