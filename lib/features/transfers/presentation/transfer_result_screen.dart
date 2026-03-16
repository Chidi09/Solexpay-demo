import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../mock/demo_app_state.dart';
import '../../../../mock/mock_transfer_service.dart';
import '../../../../shared/models/transfer_draft.dart';
import '../../../../shared/utils/currency_formatter.dart';
import '../../../../shared/widgets/demo_device_shell.dart';
import '../../../../shared/widgets/flat_illustration.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/primary_button.dart';

class TransferResultArguments {
  const TransferResultArguments({required this.draft, required this.outcome});

  final TransferDraft draft;
  final TransferOutcome outcome;
}

class TransferResultScreen extends StatelessWidget {
  const TransferResultScreen({
    super.key,
    this.draft,
    this.outcome = TransferOutcome.success,
  });

  final TransferDraft? draft;
  final TransferOutcome outcome;

  @override
  Widget build(BuildContext context) {
    final TransferDraft? resolvedDraft =
        draft ?? context.watch<DemoAppState>().activeTransferDraft;

    if (resolvedDraft == null) {
      return Scaffold(
        body: DemoDeviceShell(
          child: Scaffold(
            backgroundColor: AppColors.shell,
            body: SafeArea(
              child: Column(
                children: <Widget>[
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
                        const Text(
                          'Transfer result',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Expanded(
                    child: Center(child: Text('No transfer result available.')),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final _ResultUi ui = _resolveUi(outcome);

    return Scaffold(
      body: DemoDeviceShell(
        child: Scaffold(
          backgroundColor: AppColors.shell,
          resizeToAvoidBottomInset: false,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Back button header
                    Row(
                      children: <Widget>[
                        IconButton(
                          onPressed: () {
                            context.read<DemoAppState>().clearTransferDraft();
                            context.go('/home');
                          },
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
                        Text(
                          'Transfer result',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),

                    // Illustration centred
                    Center(
                      child: FlatIllustration(
                        scene: ui.scene,
                        width: 180,
                        height: 150,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Status chip
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: ui.chipBg,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Icon(ui.icon, color: ui.iconColor, size: 14),
                            const SizedBox(width: 5),
                            Text(
                              ui.badgeLabel,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: ui.iconColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    Center(
                      child: Text(
                        ui.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Center(
                      child: Text(
                        ui.subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Transfer detail card
                    GlassCard(
                      child: Column(
                        children: <Widget>[
                          _DetailRow(
                            label: 'Recipient',
                            value: resolvedDraft.recipientName,
                          ),
                          const SizedBox(height: 8),
                          _DetailRow(
                            label: 'Amount',
                            value: CurrencyFormatter.format(
                              resolvedDraft.amount,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 1,
                            color: AppColors.outline.withValues(alpha: 0.4),
                          ),
                          const SizedBox(height: 8),
                          _DetailRow(
                            label: 'Total deducted',
                            value: CurrencyFormatter.format(
                              resolvedDraft.totalDeducted,
                            ),
                            bold: true,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    PrimaryButton(
                      label: ui.actionLabel,
                      onPressed: () {
                        context.read<DemoAppState>().clearTransferDraft();
                        context.go(ui.nextRoute);
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  _ResultUi _resolveUi(TransferOutcome value) {
    switch (value) {
      case TransferOutcome.success:
        return const _ResultUi(
          title: 'Transfer sent!',
          subtitle: 'Funds have been delivered to the recipient.',
          icon: Icons.check_circle_rounded,
          iconColor: Color(0xFF0F7A50),
          chipBg: Color(0xFFE2F7EC),
          badgeLabel: 'Successful',
          scene: IllustrationScene.success,
          actionLabel: 'Back to home',
          nextRoute: '/home',
        );
      case TransferOutcome.pending:
        return const _ResultUi(
          title: 'Transfer pending',
          subtitle:
              'Awaiting receiving bank confirmation. Usually a few minutes.',
          icon: Icons.hourglass_bottom_rounded,
          iconColor: Color(0xFF8A5A00),
          chipBg: Color(0xFFFFF1D9),
          badgeLabel: 'Pending',
          scene: IllustrationScene.empty,
          actionLabel: 'View history',
          nextRoute: '/history',
        );
      case TransferOutcome.failed:
        return const _ResultUi(
          title: 'Transfer failed',
          subtitle: 'No debit was made. Please check your details and retry.',
          icon: Icons.error_rounded,
          iconColor: Color(0xFF9A1D2D),
          chipBg: Color(0xFFFCE2E5),
          badgeLabel: 'Failed',
          scene: IllustrationScene.empty,
          actionLabel: 'Try again',
          nextRoute: '/transfer',
        );
    }
  }
}

class _ResultUi {
  const _ResultUi({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.chipBg,
    required this.badgeLabel,
    required this.scene,
    required this.actionLabel,
    required this.nextRoute,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color chipBg;
  final String badgeLabel;
  final IllustrationScene scene;
  final String actionLabel;
  final String nextRoute;
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.bold = false,
  });
  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
