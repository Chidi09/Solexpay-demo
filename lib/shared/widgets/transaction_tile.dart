import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../models/transaction_item.dart';
import '../utils/currency_formatter.dart';
import 'status_badge.dart';

class TransactionTile extends StatelessWidget {
  const TransactionTile({super.key, required this.item, this.onTap});

  final TransactionItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool isCredit = item.type == TransactionType.credit;
    final String amountPrefix = isCredit ? '+' : '-';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.outline.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isCredit
                    ? const Color(0xFFE2F7EC)
                    : const Color(0xFFEAF1FB),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isCredit ? Icons.south_west_rounded : Icons.north_east_rounded,
                color: isCredit
                    ? const Color(0xFF0F7A50)
                    : AppColors.textPrimary,
                size: 16,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  StatusBadge(
                    label: _statusLabel(item.status),
                    tone: _statusTone(item.status),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  '$amountPrefix${CurrencyFormatter.format(item.amount)}',
                  style: TextStyle(
                    color: isCredit ? const Color(0xFF0F7A50) : AppColors.ink,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat('dd MMM').format(item.occurredAt),
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _statusLabel(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.completed:
        return 'Completed';
      case TransactionStatus.pending:
        return 'Pending';
      case TransactionStatus.failed:
        return 'Failed';
    }
  }

  StatusBadgeTone _statusTone(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.completed:
        return StatusBadgeTone.success;
      case TransactionStatus.pending:
        return StatusBadgeTone.warning;
      case TransactionStatus.failed:
        return StatusBadgeTone.danger;
    }
  }
}
