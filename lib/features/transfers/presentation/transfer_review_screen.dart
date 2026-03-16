import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../mock/demo_app_state.dart';
import '../../../../shared/models/transfer_draft.dart';
import '../../../../shared/utils/currency_formatter.dart';
import '../../../../shared/widgets/app_header.dart';
import '../../../../shared/widgets/demo_device_shell.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/primary_button.dart';

class TransferReviewScreen extends StatelessWidget {
  const TransferReviewScreen({super.key, this.draft});

  final TransferDraft? draft;

  @override
  Widget build(BuildContext context) {
    final TransferDraft? resolvedDraft =
        draft ?? context.watch<DemoAppState>().activeTransferDraft;

    return Scaffold(
      body: DemoDeviceShell(
        child: Scaffold(
          backgroundColor: AppColors.shell,
          resizeToAvoidBottomInset: false,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: resolvedDraft == null
                  ? _EmptyDraftState(onStart: () => context.go('/transfer'))
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        AppHeader.withBack(
                          title: 'Review Transfer',
                          subtitle: 'Confirm details',
                          onBack: () {
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go('/transfer');
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        GlassCard(
                          child: Column(
                            children: <Widget>[
                              _ReviewRow(
                                label: 'Recipient',
                                value: resolvedDraft.recipientName,
                              ),
                              if (resolvedDraft.bankName case final String bank)
                                _ReviewRow(label: 'Bank', value: bank),
                              if (resolvedDraft.accountNumber
                                  case final String account)
                                _ReviewRow(label: 'Account', value: account),
                              _ReviewRow(
                                label: 'Amount',
                                value: CurrencyFormatter.format(
                                  resolvedDraft.amount,
                                ),
                              ),
                              _ReviewRow(
                                label: 'Fee',
                                value: CurrencyFormatter.format(
                                  resolvedDraft.fee,
                                ),
                              ),
                              const Divider(height: 26),
                              _ReviewRow(
                                label: 'Total deducted',
                                value: CurrencyFormatter.format(
                                  resolvedDraft.totalDeducted,
                                ),
                                emphasize: true,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        PrimaryButton(
                          label: 'Confirm and continue',
                          onPressed: () => context.go('/transfer/pin-confirm'),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final TextStyle? valueStyle = emphasize
        ? Theme.of(context).textTheme.titleMedium
        : Theme.of(context).textTheme.bodyLarge;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          Text(value, style: valueStyle),
        ],
      ),
    );
  }
}

class _EmptyDraftState extends StatelessWidget {
  const _EmptyDraftState({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Header with back button
        Row(
          children: <Widget>[
            IconButton(
              onPressed: () => context.go('/home'),
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            ),
            const SizedBox(width: 4),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'No transfer to review',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Start a transfer first to continue.',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        PrimaryButton(label: 'Start transfer', onPressed: onStart),
      ],
    );
  }
}
