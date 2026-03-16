import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../mock/demo_app_state.dart';
import '../../../../shared/models/loan_state.dart';
import '../../../../shared/utils/currency_formatter.dart';
import '../../../../shared/widgets/app_header.dart';
import '../../../../shared/widgets/demo_device_shell.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/primary_button.dart';

class LoansScreen extends StatelessWidget {
  const LoansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final LoanState loanState = context.watch<DemoAppState>().loanState;

    return Scaffold(
      body: DemoDeviceShell(
        child: Scaffold(
          backgroundColor: AppColors.shell,
          resizeToAvoidBottomInset: false,
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: <Widget>[
                AppHeader.withBack(
                  title: 'Loans',
                  subtitle: 'Manage your loans and explore new offers',
                  onBack: () => context.go('/home'),
                ),
                const SizedBox(height: 14),
                if (loanState.hasActiveLoan)
                  _ActiveLoanSection(
                    loanState: loanState,
                  ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.06)
                else
                  _EligibilitySection(
                    loanState: loanState,
                  ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.06),
                const SizedBox(height: 16),
                const _LoanProductsSection().animate().fadeIn(
                  delay: 100.ms,
                  duration: 350.ms,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActiveLoanSection extends StatelessWidget {
  const _ActiveLoanSection({required this.loanState});
  final LoanState loanState;

  @override
  Widget build(BuildContext context) {
    final double paid = loanState.outstandingBalance > 0
        ? (18000 - loanState.outstandingBalance) / 18000
        : 1.0;

    return Column(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[Color(0xFF1A2F4A), Color(0xFF0D1B2A)],
            ),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x2019B37D),
                blurRadius: 16,
                offset: Offset(0, 6),
              ),
            ],
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
                      color: AppColors.accent.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Active Loan',
                      style: TextStyle(
                        color: AppColors.accent,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.credit_card_rounded,
                    color: AppColors.accent,
                    size: 16,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                loanState.activeProduct ?? 'Active Loan',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: <Widget>[
                  Expanded(
                    child: _LoanMetric(
                      label: 'Outstanding',
                      value: CurrencyFormatter.format(
                        loanState.outstandingBalance,
                      ),
                      valueColor: const Color(0xFFFF8A6A),
                    ),
                  ),
                  Expanded(
                    child: _LoanMetric(
                      label: 'Monthly',
                      value: CurrencyFormatter.format(
                        loanState.monthlyRepayment,
                      ),
                      valueColor: Colors.white,
                    ),
                  ),
                  Expanded(
                    child: _LoanMetric(
                      label: 'Due',
                      value: loanState.nextDueDate != null
                          ? 'Mar ${loanState.nextDueDate!.day}'
                          : '—',
                      valueColor: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Repaid ${(paid * 100).round()}%',
                    style: const TextStyle(
                      color: Color(0xCCFFFFFF),
                      fontSize: 10,
                    ),
                  ),
                  Text(
                    'NGN 18,000 total',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: paid,
                  minHeight: 6,
                  backgroundColor: Colors.white.withValues(alpha: 0.12),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.accent,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        PrimaryButton(
          label: 'Make a Repayment',
          onPressed: () => context.go('/loans/status'),
        ),
      ],
    );
  }
}

class _LoanMetric extends StatelessWidget {
  const _LoanMetric({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _EligibilitySection extends StatelessWidget {
  const _EligibilitySection({required this.loanState});
  final LoanState loanState;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.accentSoft,
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.verified_rounded,
              color: AppColors.accent,
              size: 22,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            loanState.isEligible
                ? 'You\'re eligible for a loan'
                : 'Build your profile to unlock loans',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Get up to NGN 50,000 instantly with no collateral.',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 14),
          if (loanState.isEligible)
            PrimaryButton(
              label: 'Apply for a Loan',
              onPressed: () => context.go('/loans/preview'),
            ),
        ],
      ),
    );
  }
}

class _LoanProductsSection extends StatelessWidget {
  const _LoanProductsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'Loan products',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        _LoanProductCard(
          name: 'Campus Flex Loan',
          amount: 'Up to NGN 50,000',
          tenor: '3 months',
          rate: '4% monthly',
          icon: Icons.school_rounded,
          color: AppColors.accent,
          onTap: () => context.go('/loans/preview'),
        ),
        const SizedBox(height: 8),
        _LoanProductCard(
          name: 'Emergency Advance',
          amount: 'Up to NGN 10,000',
          tenor: '1 month',
          rate: '2.5% flat',
          icon: Icons.bolt_rounded,
          color: const Color(0xFFFF8A3D),
          onTap: () => context.go('/loans/preview'),
        ),
        const SizedBox(height: 8),
        _LoanProductCard(
          name: 'Tuition Shield',
          amount: 'Up to NGN 200,000',
          tenor: '12 months',
          rate: '3% monthly',
          icon: Icons.menu_book_rounded,
          color: const Color(0xFF6C63FF),
          onTap: () => context.go('/loans/preview'),
        ),
      ],
    );
  }
}

class _LoanProductCard extends StatelessWidget {
  const _LoanProductCard({
    required this.name,
    required this.amount,
    required this.tenor,
    required this.rate,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String name;
  final String amount;
  final String tenor;
  final String rate;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: <Widget>[
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  '$amount · $tenor',
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                rate,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  color: color,
                ),
              ),
              const SizedBox(height: 1),
              const Text(
                'Apply',
                style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
