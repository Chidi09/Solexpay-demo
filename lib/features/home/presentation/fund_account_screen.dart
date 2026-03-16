import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_copy.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../mock/demo_app_state.dart';
import '../../../../shared/utils/currency_formatter.dart';
import '../../../../shared/widgets/balance_card.dart';
import '../../../../shared/widgets/demo_device_shell.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/page_header.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/trust_badge_card.dart';

class FundAccountScreen extends StatelessWidget {
  const FundAccountScreen({super.key});

  void _showFundSheet(BuildContext context, _FundMethod method) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (BuildContext ctx) => _FundSheet(
        method: method,
        onDone: () {
          Navigator.pop(ctx);
          context.go('/home');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final DemoAppState appState = context.watch<DemoAppState>();

    return Scaffold(
      body: DemoDeviceShell(
        child: Scaffold(
          backgroundColor: AppColors.shell,
          resizeToAvoidBottomInset: false,
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: <Widget>[
                Row(
                  children: <Widget>[
                    IconButton(
                      onPressed: () => context.go('/home'),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      padding: EdgeInsets.zero,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: PageHeader(
                        title: 'Fund Account',
                        subtitle: 'Top up your wallet instantly.',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                BalanceCard(
                  label: AppCopy.walletLabel,
                  balance: appState.balance,
                  accountNumber: appState.userProfile.accountNumber,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Choose a funding method',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                _MethodCard(
                  icon: Icons.account_balance_rounded,
                  title: 'Bank transfer',
                  subtitle: 'Transfer from any Nigerian bank account',
                  color: AppColors.accent,
                  onTap: () => _showFundSheet(context, _FundMethod.bank),
                ),
                const SizedBox(height: 10),
                _MethodCard(
                  icon: Icons.credit_card_rounded,
                  title: 'Debit card',
                  subtitle: 'Instant top-up using your card',
                  color: const Color(0xFF6C63FF),
                  onTap: () => _showFundSheet(context, _FundMethod.card),
                ),
                const SizedBox(height: 10),
                _MethodCard(
                  icon: Icons.person_add_alt_1_rounded,
                  title: 'Request from contact',
                  subtitle: 'Send a payment request to someone',
                  color: const Color(0xFFFF8A3D),
                  onTap: () => _showFundSheet(context, _FundMethod.request),
                ),
                const SizedBox(height: 24),
                // Account details section for bank transfer reference
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        'Your dedicated account',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Transfer to this number from any bank — funds arrive instantly.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _AccountRow(label: 'Bank', value: 'Providus Bank'),
                      const SizedBox(height: 8),
                      _AccountRow(
                        label: 'Account number',
                        value: appState.userProfile.accountNumber,
                        copyable: true,
                      ),
                      const SizedBox(height: 8),
                      _AccountRow(
                        label: 'Account name',
                        value: appState.userProfile.fullName,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Trust Badge
                const TrustBadgeCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MethodCard extends StatelessWidget {
  const _MethodCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: <Widget>[
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}

class _AccountRow extends StatelessWidget {
  const _AccountRow({
    required this.label,
    required this.value,
    this.copyable = false,
  });

  final String label;
  final String value;
  final bool copyable;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        if (copyable) ...<Widget>[
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account number copied'),
                  backgroundColor: AppColors.accent,
                ),
              );
            },
            child: const Icon(
              Icons.copy_rounded,
              size: 16,
              color: AppColors.accent,
            ),
          ),
        ],
      ],
    );
  }
}

enum _FundMethod { bank, card, request }

class _FundSheet extends StatefulWidget {
  const _FundSheet({required this.method, required this.onDone});
  final _FundMethod method;
  final VoidCallback onDone;

  @override
  State<_FundSheet> createState() => _FundSheetState();
}

class _FundSheetState extends State<_FundSheet> {
  final List<double> _quickAmounts = <double>[
    1000,
    2000,
    5000,
    10000,
    20000,
    50000,
  ];
  double? _selectedAmount;
  bool _isLoading = false;
  bool _success = false;

  Future<void> _handleFund() async {
    if (_selectedAmount == null) return;
    setState(() => _isLoading = true);
    await Future<void>.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;
    context.read<DemoAppState>().updateWalletBalance(
      context.read<DemoAppState>().balance + _selectedAmount!,
    );
    setState(() {
      _isLoading = false;
      _success = true;
    });
  }

  String get _title {
    switch (widget.method) {
      case _FundMethod.bank:
        return 'Bank transfer top-up';
      case _FundMethod.card:
        return 'Card top-up';
      case _FundMethod.request:
        return 'Request payment';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        20 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (_success) ...<Widget>[
            const Center(
              child: Icon(
                Icons.check_circle_rounded,
                color: AppColors.accent,
                size: 56,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'Wallet funded!',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 6),
            Center(
              child: Text(
                '${CurrencyFormatter.format(_selectedAmount!)} added to your wallet.',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: 24),
            PrimaryButton(label: 'Back to home', onPressed: widget.onDone),
          ] else ...<Widget>[
            Text(
              _title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Select an amount to add to your wallet.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _quickAmounts.map((double amt) {
                final bool selected = _selectedAmount == amt;
                return GestureDetector(
                  onTap: () => setState(() => _selectedAmount = amt),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.accent
                          : AppColors.outline.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      CurrencyFormatter.format(amt),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: selected
                            ? AppColors.ink
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: _selectedAmount == null
                  ? 'Select an amount'
                  : 'Add ${CurrencyFormatter.format(_selectedAmount!)}',
              isLoading: _isLoading,
              onPressed: _selectedAmount == null ? null : _handleFund,
            ),
          ],
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
