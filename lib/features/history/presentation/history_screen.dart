import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../mock/demo_app_state.dart';
import '../../../../shared/models/transaction_item.dart';
import '../../../../shared/utils/currency_formatter.dart';
import '../../../../shared/widgets/demo_device_shell.dart';

enum _Filter { all, credit, debit }

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  _Filter _activeFilter = _Filter.all;

  List<TransactionItem> _applyFilter(List<TransactionItem> txns) {
    switch (_activeFilter) {
      case _Filter.all:
        return txns;
      case _Filter.credit:
        return txns.where((t) => t.type == TransactionType.credit).toList();
      case _Filter.debit:
        return txns.where((t) => t.type == TransactionType.debit).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final DemoAppState appState = context.watch<DemoAppState>();
    final List<TransactionItem> filtered =
        _applyFilter(appState.transactions.toList());
    final Map<String, List<TransactionItem>> grouped = _groupByDate(filtered);

    return Scaffold(
      body: DemoDeviceShell(
        child: Scaffold(
          backgroundColor: AppColors.shell,
          resizeToAvoidBottomInset: false,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // ── Header ─────────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(6, 6, 16, 0),
                  child: Row(
                    children: <Widget>[
                      IconButton(
                        onPressed: () => context.go('/home'),
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 18,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const <Widget>[
                            Text(
                              'Transaction history',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 1),
                            Text(
                              'Every inflow and outflow in one place.',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Search icon
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.outline.withValues(alpha: 0.35),
                          ),
                        ),
                        child: const Icon(
                          Icons.search_rounded,
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Filter chips ───────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                  child: Row(
                    children: <Widget>[
                      _FilterChip(
                        label: 'All',
                        isActive: _activeFilter == _Filter.all,
                        onTap: () =>
                            setState(() => _activeFilter = _Filter.all),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Money In',
                        icon: Icons.south_west_rounded,
                        iconColor: const Color(0xFF0F7A50),
                        isActive: _activeFilter == _Filter.credit,
                        onTap: () =>
                            setState(() => _activeFilter = _Filter.credit),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Money Out',
                        icon: Icons.north_east_rounded,
                        iconColor: AppColors.textPrimary,
                        isActive: _activeFilter == _Filter.debit,
                        onTap: () =>
                            setState(() => _activeFilter = _Filter.debit),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 300.ms),

                const SizedBox(height: 14),

                // ── Transaction list ───────────────────────────────────────
                Expanded(
                  child: grouped.isEmpty
                      ? _EmptyState(filter: _activeFilter)
                      : ListView.builder(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: grouped.length,
                          itemBuilder: (BuildContext context, int index) {
                            final String dateLabel =
                                grouped.keys.elementAt(index);
                            final List<TransactionItem> items =
                                grouped.values.elementAt(index);
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: _DateGroup(
                                dateLabel: dateLabel,
                                items: items,
                              ),
                            ).animate().fadeIn(
                                  delay: Duration(milliseconds: index * 40),
                                  duration: 300.ms,
                                );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Map<String, List<TransactionItem>> _groupByDate(
    List<TransactionItem> transactions,
  ) {
    final Map<String, List<TransactionItem>> groups =
        <String, List<TransactionItem>>{};
    for (final TransactionItem tx in transactions) {
      final String key = _dateKey(tx.occurredAt);
      groups.putIfAbsent(key, () => <TransactionItem>[]).add(tx);
    }
    return groups;
  }

  String _dateKey(DateTime dt) {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime txDay = DateTime(dt.year, dt.month, dt.day);
    final int diff = today.difference(txDay).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return DateFormat('EEEE').format(dt);
    return DateFormat('dd MMM yyyy').format(dt);
  }
}

// ── Filter chip ───────────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isActive,
    required this.onTap,
    this.icon,
    this.iconColor,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final IconData? icon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isActive ? AppColors.accent : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive
                ? AppColors.accent
                : AppColors.outline.withValues(alpha: 0.4),
          ),
          boxShadow: isActive
              ? <BoxShadow>[
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (icon != null) ...<Widget>[
              Icon(
                icon,
                size: 12,
                color: isActive ? Colors.white : iconColor,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.filter});
  final _Filter filter;

  @override
  Widget build(BuildContext context) {
    final String label = filter == _Filter.credit
        ? 'No incoming transactions yet'
        : filter == _Filter.debit
            ? 'No outgoing transactions yet'
            : 'No transactions yet';

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.accentSoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.receipt_long_rounded,
              color: AppColors.accent,
              size: 28,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Your transactions will appear here.',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ).animate().fadeIn(duration: 300.ms),
    );
  }
}

// ── Date group card ───────────────────────────────────────────────────────────

class _DateGroup extends StatelessWidget {
  const _DateGroup({required this.dateLabel, required this.items});

  final String dateLabel;
  final List<TransactionItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 8),
          child: Row(
            children: <Widget>[
              Text(
                dateLabel,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 1,
                  color: AppColors.outline.withValues(alpha: 0.2),
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.outline.withValues(alpha: 0.4),
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: <Widget>[
              for (int i = 0; i < items.length; i++) ...<Widget>[
                _HistoryRow(item: items[i]),
                if (i < items.length - 1)
                  Divider(
                    height: 1,
                    thickness: 0.5,
                    color: AppColors.outline.withValues(alpha: 0.35),
                    indent: 56,
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ── Transaction row ───────────────────────────────────────────────────────────

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.item});

  final TransactionItem item;

  @override
  Widget build(BuildContext context) {
    final bool isCredit = item.type == TransactionType.credit;

    return GestureDetector(
      onTap: () => context.go('/history/tx/${item.id}'),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(
          children: <Widget>[
            // Direction icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isCredit
                    ? const Color(0xFFE2F7EC)
                    : const Color(0xFFEAF1FB),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isCredit
                    ? Icons.south_west_rounded
                    : Icons.north_east_rounded,
                color: isCredit
                    ? const Color(0xFF0F7A50)
                    : AppColors.textPrimary,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),

            // Title + subtitle + status dot
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
                  const SizedBox(height: 4),
                  Row(
                    children: <Widget>[
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: _statusColor(item.status),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          item.subtitle,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),

            // Amount + time
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  '${isCredit ? '+' : '-'}${CurrencyFormatter.format(item.amount)}',
                  style: TextStyle(
                    color: isCredit
                        ? const Color(0xFF0F7A50)
                        : AppColors.ink,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('h:mm a').format(item.occurredAt),
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

  Color _statusColor(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.completed:
        return const Color(0xFF0F7A50);
      case TransactionStatus.pending:
        return const Color(0xFFD4A017);
      case TransactionStatus.failed:
        return const Color(0xFFD03040);
    }
  }
}
