enum TransactionType { credit, debit }

enum TransactionStatus { completed, pending, failed }

class TransactionItem {
  const TransactionItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.occurredAt,
    required this.type,
    required this.status,
  });

  final String id;
  final String title;
  final String subtitle;
  final double amount;
  final DateTime occurredAt;
  final TransactionType type;
  final TransactionStatus status;
}
