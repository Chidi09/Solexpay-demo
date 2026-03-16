import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../mock/demo_app_state.dart';
import '../../../../shared/models/transaction_item.dart';
import '../../../../shared/utils/currency_formatter.dart';
import '../../../../shared/widgets/demo_device_shell.dart';
import '../../../../shared/widgets/glass_card.dart';

class TransactionDetailScreen extends StatelessWidget {
  const TransactionDetailScreen({super.key, required this.transactionId});

  final String transactionId;

  @override
  Widget build(BuildContext context) {
    final DemoAppState appState = context.watch<DemoAppState>();
    final TransactionItem? item = _findTransaction(appState.transactions);

    return Scaffold(
      body: DemoDeviceShell(
        child: Scaffold(
          backgroundColor: AppColors.shell,
          resizeToAvoidBottomInset: false,
          body: SafeArea(
            child: Column(
              children: <Widget>[
                // ── Header ────────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(6, 4, 16, 0),
                  child: Row(
                    children: <Widget>[
                      IconButton(
                        onPressed: () => context.go('/history'),
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
                      const Text(
                        'Transaction details',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // ── Content ───────────────────────────────────────────────
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: item == null
                        ? const Center(
                            child: Text('Transaction not found.'),
                          )
                        : ListView(
                            children: <Widget>[
                              // ── Amount hero card ──────────────────────
                              _AmountHeroCard(item: item)
                                  .animate()
                                  .fadeIn(duration: 300.ms)
                                  .slideY(begin: 0.08),

                              const SizedBox(height: 14),

                              // ── Details card ──────────────────────────
                              GlassCard(
                                child: Column(
                                  children: <Widget>[
                                    _DetailRow(
                                      label: 'Status',
                                      value: _statusLabel(item.status),
                                      trailing: _StatusBadge(status: item.status),
                                    ),
                                    _Divider(),
                                    _DetailRow(
                                      label: 'Type',
                                      value: item.type == TransactionType.credit
                                          ? 'Credit'
                                          : 'Debit',
                                      trailing: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: item.type ==
                                                  TransactionType.credit
                                              ? const Color(0xFFE2F7EC)
                                              : const Color(0xFFEAF1FB),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Icon(
                                              item.type ==
                                                      TransactionType.credit
                                                  ? Icons.south_west_rounded
                                                  : Icons.north_east_rounded,
                                              size: 12,
                                              color: item.type ==
                                                      TransactionType.credit
                                                  ? const Color(0xFF0F7A50)
                                                  : AppColors.textPrimary,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              item.type ==
                                                      TransactionType.credit
                                                  ? 'Credit'
                                                  : 'Debit',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                                color: item.type ==
                                                        TransactionType.credit
                                                    ? const Color(0xFF0F7A50)
                                                    : AppColors.textPrimary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    _Divider(),
                                    _DetailRow(
                                      label: 'Date',
                                      value: DateFormat(
                                        'dd MMM yyyy, hh:mm a',
                                      ).format(item.occurredAt),
                                    ),
                                    _Divider(),
                                    _DetailRow(
                                      label: 'Reference',
                                      value: item.id,
                                      canCopy: true,
                                    ),
                                  ],
                                ),
                              ).animate().fadeIn(delay: 100.ms, duration: 300.ms),

                              const SizedBox(height: 20),

                              // ── Actions ───────────────────────────────
                              OutlinedButton.icon(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text('Generating PDF receipt…'),
                                      backgroundColor: AppColors.accent,
                                    ),
                                  );
                                },
                                icon: const Icon(
                                  Icons.ios_share_rounded,
                                  size: 16,
                                ),
                                label: const Text('Share Receipt'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.accent,
                                  side: const BorderSide(
                                    color: AppColors.accent,
                                  ),
                                  minimumSize: const Size.fromHeight(48),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                              ).animate().fadeIn(delay: 180.ms),

                              const SizedBox(height: 12),

                              // Report issue button
                              TextButton.icon(
                                onPressed: () {},
                                icon: const Icon(
                                  Icons.flag_outlined,
                                  size: 15,
                                ),
                                label: const Text('Report an issue'),
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.textSecondary,
                                  minimumSize: const Size.fromHeight(40),
                                ),
                              ).animate().fadeIn(delay: 220.ms),

                              const SizedBox(height: 16),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  TransactionItem? _findTransaction(Iterable<TransactionItem> transactions) {
    for (final TransactionItem item in transactions) {
      if (item.id == transactionId) return item;
    }
    return null;
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
}

// ── Amount hero card ──────────────────────────────────────────────────────────

class _AmountHeroCard extends StatelessWidget {
  const _AmountHeroCard({required this.item});
  final TransactionItem item;

  @override
  Widget build(BuildContext context) {
    final bool isCredit = item.type == TransactionType.credit;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isCredit
              ? const <Color>[Color(0xFF0F7A50), Color(0xFF1AA367)]
              : const <Color>[Color(0xFF1A2340), Color(0xFF2D3A5C)],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: (isCredit ? const Color(0xFF0F7A50) : const Color(0xFF1A2340))
                .withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isCredit
                      ? Icons.south_west_rounded
                      : Icons.north_east_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            isCredit ? 'Amount received' : 'Amount sent',
            style: TextStyle(
              fontSize: 11,
              letterSpacing: 0.8,
              color: Colors.white.withValues(alpha: 0.65),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              '${isCredit ? '+' : '-'}${CurrencyFormatter.format(item.amount)}',
              style: const TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Status badge ──────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final TransactionStatus status;

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;
    final IconData icon;
    switch (status) {
      case TransactionStatus.completed:
        bg = const Color(0xFFE2F7EC);
        fg = const Color(0xFF0F7A50);
        icon = Icons.check_circle_rounded;
      case TransactionStatus.pending:
        bg = const Color(0xFFFFF8E1);
        fg = const Color(0xFFD4A017);
        icon = Icons.schedule_rounded;
      case TransactionStatus.failed:
        bg = const Color(0xFFFFEBED);
        fg = const Color(0xFFD03040);
        icon = Icons.cancel_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 12, color: fg),
          const SizedBox(width: 4),
          Text(
            status.name[0].toUpperCase() + status.name.substring(1),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Detail row ────────────────────────────────────────────────────────────────

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.trailing,
    this.canCopy = false,
  });

  final String label;
  final String value;
  final Widget? trailing;
  final bool canCopy;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 2),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: trailing ??
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
          ),
          if (canCopy)
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: value));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Reference copied'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              child: const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(
                  Icons.copy_rounded,
                  size: 15,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Divider(
        height: 1,
        thickness: 0.5,
        color: AppColors.outline.withValues(alpha: 0.35),
      );
}
