import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/utils/currency_formatter.dart';
import '../../../../shared/widgets/app_header.dart';
import '../../../../shared/widgets/demo_device_shell.dart';
import '../../../../shared/widgets/glass_card.dart';

class KycTiersScreen extends StatelessWidget {
  const KycTiersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DemoDeviceShell(
        child: Scaffold(
          backgroundColor: AppColors.shell,
          resizeToAvoidBottomInset: false,
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        AppHeader.withBack(
                          title: 'Account Limits',
                          subtitle: 'Upgrade your KYC tier for higher limits',
                          onBack: () {
                            // FIX: Safely check if we can pop, otherwise route to profile
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go('/profile');
                            }
                          },
                        ),
                        const SizedBox(height: 20),

                        // Current Status Banner
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0F4C3A), Color(0xFF19B37D)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.verified_user_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 14),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'You are on Tier 2',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Your identity is verified. You can send up to ₦200,000 daily.',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 11,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05),

                        const SizedBox(height: 24),
                        const Text(
                          'CBN KYC Tiers',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Tier 1
                        _TierCard(
                          tier: 'Tier 1',
                          status: _TierStatus.completed,
                          dailyLimit: 50000,
                          maxBalance: 300000,
                          requirements: const ['Phone Number', 'BVN'],
                        ).animate().fadeIn(delay: 100.ms, duration: 300.ms),

                        const SizedBox(height: 12),

                        // Tier 2
                        _TierCard(
                          tier: 'Tier 2',
                          status: _TierStatus.current,
                          dailyLimit: 200000,
                          maxBalance: 500000,
                          requirements: const ['NIN', 'Selfie / Liveness'],
                        ).animate().fadeIn(delay: 150.ms, duration: 300.ms),

                        const SizedBox(height: 12),

                        // Tier 3
                        _TierCard(
                          tier: 'Tier 3',
                          status: _TierStatus.locked,
                          dailyLimit: 5000000,
                          maxBalance: double
                              .infinity, // Using a flag in the widget for unlimited
                          requirements: const [
                            'Proof of Address (Utility Bill)',
                          ],
                        ).animate().fadeIn(delay: 200.ms, duration: 300.ms),

                        const SizedBox(height: 32),

                        // Safety & Anti-Fraud Rules
                        const Text(
                          'Safety & Anti-Fraud Center',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        GlassCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _SafetyRow(
                                icon: Icons.password_rounded,
                                title: 'Never share your PIN or OTP',
                                subtitle:
                                    'SolexPay staff will NEVER call or message you to ask for your PIN, password, or OTP.',
                              ),
                              const Divider(height: 24),
                              _SafetyRow(
                                icon: Icons.support_agent_rounded,
                                title: 'Beware of fake support',
                                subtitle:
                                    'Only contact us through the app or our official handle @SolexPayHQ. Scammers use fake pages.',
                              ),
                              const Divider(height: 24),
                              _SafetyRow(
                                icon: Icons.report_gmailerrorred_rounded,
                                title: 'Report suspicious activity',
                                subtitle:
                                    'If you lose your phone or notice strange transfers, use the "Freeze Account" button immediately.',
                                iconColor: const Color(0xFFD32F2F),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(delay: 250.ms, duration: 300.ms),

                        const SizedBox(height: 24),
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
}

enum _TierStatus { completed, current, locked }

class _TierCard extends StatelessWidget {
  const _TierCard({
    required this.tier,
    required this.status,
    required this.dailyLimit,
    required this.maxBalance,
    required this.requirements,
  });

  final String tier;
  final _TierStatus status;
  final double dailyLimit;
  final double maxBalance;
  final List<String> requirements;

  @override
  Widget build(BuildContext context) {
    final bool isLocked = status == _TierStatus.locked;
    final bool isCurrent = status == _TierStatus.current;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCurrent
            ? AppColors.accentSoft.withValues(alpha: 0.3)
            : AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrent
              ? AppColors.accent
              : AppColors.outline.withValues(alpha: 0.3),
          width: isCurrent ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                tier,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              _buildStatusBadge(),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _LimitInfo(
                  label: 'Daily Limit',
                  value: CurrencyFormatter.format(dailyLimit),
                ),
              ),
              Expanded(
                child: _LimitInfo(
                  label: 'Max Balance',
                  value: maxBalance == double.infinity
                      ? 'Unlimited'
                      : CurrencyFormatter.format(maxBalance),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isLocked
                  ? AppColors.shell
                  : AppColors.accentSoft.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isLocked ? 'Requirements to unlock:' : 'Requirements met:',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isLocked
                        ? AppColors.textSecondary
                        : AppColors.accent,
                  ),
                ),
                const SizedBox(height: 6),
                ...requirements.map(
                  (req) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 1),
                          child: Icon(
                            isLocked
                                ? Icons.circle_outlined
                                : Icons.check_circle_rounded,
                            size: 14,
                            color: isLocked
                                ? AppColors.textSecondary
                                : AppColors.accent,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // FIX: Wrapped text in Expanded to prevent RenderFlex overflow
                        Expanded(
                          child: Text(
                            req,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isLocked) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.accent,
                  side: const BorderSide(color: AppColors.accent),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Upgrade to Tier 3',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    switch (status) {
      case _TierStatus.completed:
        return const Icon(Icons.check_circle_rounded, color: Color(0xFF0F7A50));
      case _TierStatus.current:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'Current',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        );
      case _TierStatus.locked:
        return const Icon(
          Icons.lock_rounded,
          color: AppColors.textSecondary,
          size: 20,
        );
    }
  }
}

class _LimitInfo extends StatelessWidget {
  const _LimitInfo({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 2),
        // FIX: Added FittedBox to gracefully scale down huge amounts instead of overflowing
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

class _SafetyRow extends StatelessWidget {
  const _SafetyRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.iconColor = AppColors.accent,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
