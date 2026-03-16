import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../mock/demo_app_state.dart';
import '../../../../shared/widgets/demo_device_shell.dart';
import '../../../../shared/widgets/flat_illustration.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/app_header.dart';

class ReceiveMoneyScreen extends StatelessWidget {
  const ReceiveMoneyScreen({super.key});

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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: <Widget>[
                AppHeader.withBack(
                  title: 'Receive Money',
                  subtitle: 'Share your account details to receive payments',
                  onBack: () => context.go('/home'),
                ),

                const SizedBox(height: 8),

                // Illustration
                Center(
                  child: const FlatIllustration(
                    scene: IllustrationScene.receive,
                    width: 220,
                    height: 160,
                  ),
                ),

                const SizedBox(height: 16),

                // Account number card
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        'Account number',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              appState.userProfile.accountNumber,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Clipboard.setData(
                                ClipboardData(
                                  text: appState.userProfile.accountNumber,
                                ),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Account number copied'),
                                  backgroundColor: AppColors.accent,
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.accentSoft,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.copy_rounded,
                                color: AppColors.accent,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        height: 1,
                        color: AppColors.outline.withValues(alpha: 0.4),
                      ),
                      const SizedBox(height: 12),
                      _AccountRow(label: 'Bank', value: 'Providus Bank'),
                      const SizedBox(height: 8),
                      _AccountRow(
                        label: 'Account name',
                        value: appState.userProfile.fullName,
                      ),
                      const SizedBox(height: 8),
                      _AccountRow(
                        label: 'Wallet ID',
                        value: appState.userProfile.walletId,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Tip card
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accentSoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: <Widget>[
                      Icon(
                        Icons.info_outline_rounded,
                        color: AppColors.accent,
                        size: 16,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Funds sent to your account number arrive within seconds from any Nigerian bank.',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textPrimary,
                            height: 1.45,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                PrimaryButton(
                  label: 'Share account details',
                  leading: const Icon(Icons.share_rounded, size: 16),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Account details copied to clipboard.'),
                        backgroundColor: AppColors.accent,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AccountRow extends StatelessWidget {
  const _AccountRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
