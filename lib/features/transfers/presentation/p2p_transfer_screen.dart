import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../mock/demo_app_state.dart';
import '../../../../shared/models/transfer_draft.dart';
import '../../../../shared/widgets/app_header.dart';
import '../../../../shared/widgets/demo_device_shell.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/primary_button.dart';

class P2pTransferScreen extends StatefulWidget {
  const P2pTransferScreen({super.key});

  @override
  State<P2pTransferScreen> createState() => _P2pTransferScreenState();
}

class _P2pTransferScreenState extends State<P2pTransferScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _recipientController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  final List<double> _quickAmounts = [
    500,
    1000,
    2000,
    5000,
    9999,
    10000,
    20000,
  ];

  @override
  void dispose() {
    _recipientController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _continueToReview() {
    if (!_formKey.currentState!.validate()) return;

    final double amount =
        double.tryParse(
          _amountController.text.replaceAll(',', '').replaceAll(' ', ''),
        ) ??
        0;
    final TransferDraft draft = TransferDraft.p2p(
      recipientName: _recipientController.text.trim(),
      amount: amount,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
    );

    context.read<DemoAppState>().setTransferDraft(draft);
    context.go('/transfer/review');
  }

  void _selectQuickAmount(double amount) {
    HapticFeedback.selectionClick();
    setState(() {
      // Format without decimals if it's a whole number for a cleaner input
      _amountController.text = amount.toInt().toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DemoDeviceShell(
        child: Scaffold(
          backgroundColor: AppColors.shell,
          body: SafeArea(
            child: GestureDetector(
              onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
              behavior: HitTestBehavior.translucent,
              child: CustomScrollView(
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            AppHeader.withBack(
                              title: 'Send to User',
                              subtitle: 'Instant P2P transfer',
                              onBack: () {
                                if (context.canPop()) {
                                  context.pop();
                                } else {
                                  context.go('/home');
                                }
                              },
                            ),
                            const SizedBox(height: 24),

                            GlassCard(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Recipient Details',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: _recipientController,
                                    textInputAction: TextInputAction.next,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'Email, Phone, or Account No.',
                                      prefixIcon: Icon(
                                        Icons.person_search_rounded,
                                        color: AppColors.accent,
                                        size: 20,
                                      ),
                                      prefixIconConstraints: BoxConstraints(
                                        minWidth: 36,
                                      ),
                                    ),
                                    validator: (String? value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Please enter recipient details';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 12),

                            GlassCard(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Amount',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),

                                  // FIX: Replaced `prefixText` with a clean Row layout for perfect alignment
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      const Text(
                                        '₦',
                                        style: TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: TextFormField(
                                          controller: _amountController,
                                          keyboardType:
                                              const TextInputType.numberWithOptions(
                                                decimal: true,
                                              ),
                                          textInputAction: TextInputAction.next,
                                          style: const TextStyle(
                                            fontSize: 28,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.textPrimary,
                                          ),
                                          decoration: const InputDecoration(
                                            border: InputBorder.none,
                                            hintText: '0',
                                          ),
                                          validator: (String? value) {
                                            final cleanValue = (value ?? '')
                                                .replaceAll(',', '')
                                                .replaceAll(' ', '');
                                            final double? parsed =
                                                double.tryParse(cleanValue);
                                            if (parsed == null || parsed <= 0) {
                                              return 'Enter a valid amount';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 16),
                                  // Quick Amount Chips
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: _quickAmounts.map((amt) {
                                      return GestureDetector(
                                        onTap: () => _selectQuickAmount(amt),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.accentSoft
                                                .withValues(alpha: 0.5),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Text(
                                            '₦${amt.toInt()}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.accent,
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 12),

                            GlassCard(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 4,
                              ),
                              child: TextFormField(
                                controller: _noteController,
                                textInputAction: TextInputAction.done,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'What is this for? (Optional)',
                                  prefixIcon: Icon(
                                    Icons.edit_note_rounded,
                                    color: AppColors.textSecondary,
                                    size: 20,
                                  ),
                                  prefixIconConstraints: BoxConstraints(
                                    minWidth: 36,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 32),

                            PrimaryButton(
                              label: 'Review transfer',
                              onPressed: _continueToReview,
                            ),
                          ],
                        ),
                      ),
                    ),
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
