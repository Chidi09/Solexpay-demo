import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../mock/demo_app_state.dart';
import '../../../../shared/models/loan_state.dart';
import '../../../../shared/utils/currency_formatter.dart';
import '../../../../shared/widgets/demo_device_shell.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/primary_button.dart';

class LoanStatusScreen extends StatefulWidget {
  const LoanStatusScreen({super.key});

  @override
  State<LoanStatusScreen> createState() => _LoanStatusScreenState();
}

class _LoanStatusScreenState extends State<LoanStatusScreen> {
  bool _isRepaying = false;

  Future<void> _handleRepayment(DemoAppState appState) async {
    final LoanState loan = appState.loanState;
    if (!loan.hasActiveLoan) return;
    setState(() => _isRepaying = true);
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    final double newBalance = loan.outstandingBalance - loan.monthlyRepayment;
    appState.updateLoanState(
      LoanState(
        isEligible: loan.isEligible,
        activeProduct: newBalance > 0 ? loan.activeProduct : null,
        outstandingBalance: newBalance > 0 ? newBalance : 0,
        monthlyRepayment: loan.monthlyRepayment,
        nextDueDate: newBalance > 0
            ? loan.nextDueDate?.add(const Duration(days: 30))
            : null,
      ),
    );
    appState.updateWalletBalance(appState.balance - loan.monthlyRepayment);
    setState(() => _isRepaying = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Repayment successful!'),
        backgroundColor: AppColors.accent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final DemoAppState appState = context.watch<DemoAppState>();
    final LoanState loan = appState.loanState;

    return Scaffold(
      body: DemoDeviceShell(
        child: Scaffold(
          backgroundColor: AppColors.shell,
          resizeToAvoidBottomInset: false,
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: <Widget>[
                Row(
                  children: <Widget>[
                    IconButton(
                      onPressed: () => context.go('/loans'),
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
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Loan Tracker',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'Monitor and manage your repayments.',
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
                const SizedBox(height: 14),

                if (loan.hasActiveLoan) ...<Widget>[
                  // Status card
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: <Color>[Color(0xFF1A2F4A), Color(0xFF0D1B2A)],
                      ),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFFFF8A3D,
                                ).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Active',
                                style: TextStyle(
                                  color: Color(0xFFFF8A3D),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              loan.activeProduct ?? '',
                              style: const TextStyle(
                                color: Color(0xCCFFFFFF),
                                fontSize: 11,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Outstanding Balance',
                          style: TextStyle(
                            color: Color(0xCCFFFFFF),
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 3),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            CurrencyFormatter.format(loan.outstandingBalance),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        if (loan.nextDueDate != null)
                          Row(
                            children: <Widget>[
                              const Icon(
                                Icons.calendar_today_rounded,
                                color: AppColors.accent,
                                size: 12,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Next due: Mar ${loan.nextDueDate!.day}, 2026',
                                style: const TextStyle(
                                  color: Color(0xCCFFFFFF),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.06),

                  const SizedBox(height: 12),

                  // Monthly breakdown
                  GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text(
                          "This month's repayment",
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _RepayRow(
                          label: 'Principal',
                          value: CurrencyFormatter.format(
                            loan.monthlyRepayment * 0.85,
                          ),
                        ),
                        const SizedBox(height: 6),
                        _RepayRow(
                          label: 'Interest',
                          value: CurrencyFormatter.format(
                            loan.monthlyRepayment * 0.15,
                          ),
                          valueColor: const Color(0xFFFF8A3D),
                        ),
                        const Divider(height: 18),
                        _RepayRow(
                          label: 'Total due',
                          value: CurrencyFormatter.format(
                            loan.monthlyRepayment,
                          ),
                          bold: true,
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 100.ms, duration: 350.ms),

                  const SizedBox(height: 16),

                  PrimaryButton(
                    label:
                        'Pay NGN ${(loan.monthlyRepayment / 1000).round()}k Now',
                    isLoading: _isRepaying,
                    onPressed: () => _handleRepayment(appState),
                  ).animate().fadeIn(delay: 150.ms, duration: 300.ms),

                  const SizedBox(height: 8),

                  Center(
                    child: TextButton(
                      onPressed: () => context.go('/home'),
                      child: const Text(
                        'Back to home',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ] else ...<Widget>[
                  // Fully repaid
                  GlassCard(
                        child: Column(
                          children: <Widget>[
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: AppColors.accentSoft,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.check_circle_rounded,
                                color: AppColors.accent,
                                size: 28,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Loan fully repaid!',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Your credit score has improved. You\'re eligible for a larger loan.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 14),
                            PrimaryButton(
                              label: 'Apply for new loan',
                              onPressed: () => context.go('/loans/preview'),
                            ),
                          ],
                        ),
                      )
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .scale(begin: const Offset(0.96, 0.96)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RepayRow extends StatelessWidget {
  const _RepayRow({
    required this.label,
    required this.value,
    this.valueColor = AppColors.textPrimary,
    this.bold = false,
  });
  final String label;
  final String value;
  final Color valueColor;
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
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
