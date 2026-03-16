import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/utils/currency_formatter.dart';
import '../../../../shared/widgets/demo_device_shell.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/primary_button.dart';

class LoanPreviewScreen extends StatefulWidget {
  const LoanPreviewScreen({super.key});

  @override
  State<LoanPreviewScreen> createState() => _LoanPreviewScreenState();
}

class _LoanPreviewScreenState extends State<LoanPreviewScreen> {
  double _amount = 20000;
  int _tenorMonths = 3;
  bool _termsAccepted = false; // Added state for checkbox

  double get _monthlyRate => 0.04;
  double get _monthlyRepayment =>
      _amount * _monthlyRate * _tenorMonths / _tenorMonths +
      _amount / _tenorMonths;
  double get _totalRepayment => _monthlyRepayment * _tenorMonths;
  double get _interest => _totalRepayment - _amount;

  // New method for the E-Signature Bottom Sheet
  void _showSignatureSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateSheet) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.outlineVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Review & Sign',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Please review the loan terms and provide your digital signature to proceed.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Terms Checkbox
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.shell,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.outline.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Checkbox(
                            value: _termsAccepted,
                            activeColor: AppColors.accent,
                            onChanged: (val) {
                              setStateSheet(
                                () => _termsAccepted = val ?? false,
                              );
                              setState(() => _termsAccepted = val ?? false);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'I have read and agree to the SolexPay Campus Flex Loan Terms & Conditions. I authorize automatic deductions from my wallet on the due dates.',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textPrimary,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  const Text(
                    'Digital Signature (Type full name)',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Signature Input
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'e.g. Ifeoma Adeyemi',
                      filled: true,
                      fillColor: AppColors.shell,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    style: const TextStyle(
                      fontFamily: 'Caveat',
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ), // Makes it look like a signature
                  ),

                  const SizedBox(height: 32),
                  PrimaryButton(
                    label: 'Sign & Accept Loan',
                    onPressed: _termsAccepted
                        ? () {
                            Navigator.pop(context);
                            context.go('/loans/status');
                          }
                        : null,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
                            'Campus Flex Loan',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'Adjust your amount and tenor.',
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

                // Amount picker
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        'Loan amount',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        CurrencyFormatter.format(_amount),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Slider(
                        value: _amount,
                        min: 5000,
                        max: 50000,
                        divisions: 45,
                        activeColor: AppColors.accent,
                        inactiveColor: AppColors.outline,
                        onChanged: (double v) {
                          HapticFeedback.selectionClick();
                          setState(() => _amount = v);
                        },
                      ),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            'NGN 5,000',
                            style: TextStyle(
                              fontSize: 9,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            'NGN 50,000',
                            style: TextStyle(
                              fontSize: 9,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.05),

                const SizedBox(height: 10),

                // Tenor picker
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        'Repayment period',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: <int>[1, 2, 3, 6].map((int m) {
                          final bool selected = _tenorMonths == m;
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 2,
                              ),
                              child: GestureDetector(
                                onTap: () => setState(() => _tenorMonths = m),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? AppColors.accent
                                        : AppColors.outline.withValues(
                                            alpha: 0.4,
                                          ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    '${m}mo',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                      color: selected
                                          ? AppColors.ink
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 100.ms, duration: 350.ms),

                const SizedBox(height: 16),
                const Text(
                  'Repayment Breakdown',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),

                GlassCard(
                  child: Column(
                    children: [
                      // Visual Bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Row(
                          children: [
                            Expanded(
                              flex: (_amount / _totalRepayment * 100).toInt(),
                              child: Container(
                                height: 8,
                                color: AppColors.accent,
                              ), // Principal
                            ),
                            Expanded(
                              flex: (_interest / _totalRepayment * 100).toInt(),
                              child: Container(
                                height: 8,
                                color: const Color(0xFFFF8A3D),
                              ), // Interest
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Legend
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: AppColors.accent,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Expanded(
                            child: Text(
                              'Principal',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              CurrencyFormatter.format(_amount),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFF8A3D),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Expanded(
                            child: Text(
                              'Interest & Fees',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              CurrencyFormatter.format(_interest),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFFF8A3D),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      _SummaryRow(
                        label: 'Total to repay',
                        value: CurrencyFormatter.format(_totalRepayment),
                        bold: true,
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 150.ms, duration: 350.ms),

                const SizedBox(height: 10),

                // Summary
                GlassCard(
                  child: Column(
                    children: <Widget>[
                      _SummaryRow(
                        label: 'Monthly repayment',
                        value: CurrencyFormatter.format(_monthlyRepayment),
                        bold: true,
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ).animate().fadeIn(delay: 150.ms, duration: 350.ms),

                const SizedBox(height: 16),

                PrimaryButton(
                  label: 'Confirm & Apply',
                  onPressed: _showSignatureSheet, // Changed from context.go()
                ).animate().fadeIn(delay: 200.ms, duration: 300.ms),

                const SizedBox(height: 8),

                Center(
                  child: TextButton(
                    onPressed: () => context.go('/loans'),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
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
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
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
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: TextStyle(
              fontSize: bold ? 16 : 13,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
