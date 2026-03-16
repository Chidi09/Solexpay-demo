import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../mock/demo_app_state.dart';
import '../../../../shared/utils/currency_formatter.dart';
import '../../../../shared/widgets/demo_device_shell.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/trust_badge_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final DemoAppState appState = context.watch<DemoAppState>();
    final profile = appState.userProfile;

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
                    const SizedBox(width: 4),
                    const Text(
                      'Profile',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.settings_rounded, size: 20),
                      color: AppColors.textSecondary,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Avatar + name
                _ProfileHero(
                  fullName: profile.fullName,
                  tag: profile.tag,
                  school: profile.school,
                ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.05),

                const SizedBox(height: 12),

                // Stats cards
                Row(
                  children: <Widget>[
                    Expanded(
                      child: _MiniStatCard(
                        label: 'Wallet',
                        value: CurrencyFormatter.format(appState.balance),
                        icon: Icons.account_balance_wallet_rounded,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _MiniStatCard(
                        label: 'Savings',
                        value: CurrencyFormatter.format(
                          appState.savingsBalance,
                        ),
                        icon: Icons.savings_rounded,
                        iconColor: const Color(0xFF6C63FF),
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 80.ms, duration: 350.ms),

                const SizedBox(height: 12),

                // Personal info
                _SectionCard(
                  title: 'Personal information',
                  items: <_InfoItem>[
                    _InfoItem(
                      icon: Icons.person_rounded,
                      label: 'Full name',
                      value: profile.fullName,
                    ),
                    _InfoItem(
                      icon: Icons.phone_rounded,
                      label: 'Phone',
                      value: profile.phoneNumber,
                    ),
                    _InfoItem(
                      icon: Icons.school_rounded,
                      label: 'School',
                      value: profile.school,
                    ),
                    _InfoItem(
                      icon: Icons.tag_rounded,
                      label: 'SolexPay tag',
                      value: profile.tag,
                    ),
                    _InfoItem(
                      icon: Icons.account_balance_rounded,
                      label: 'Account number',
                      value: profile.accountNumber,
                    ),
                    _InfoItem(
                      icon: Icons.badge_rounded,
                      label: 'Wallet ID',
                      value: profile.walletId,
                    ),
                  ],
                ).animate().fadeIn(delay: 130.ms, duration: 350.ms),

                const SizedBox(height: 12),

                // KYC status
                GlassCard(
                  onTap: () => context.go('/kyc-tiers'),
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.accentSoft,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.verified_user_rounded,
                          color: AppColors.accent,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'KYC Verified',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              'Tap to view your limits and tiers',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accentSoft,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Tier 2',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.accent,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 180.ms, duration: 350.ms),

                const SizedBox(height: 12),

                // Trust Badge - Government approvals
                const TrustBadgeCard().animate().fadeIn(
                  delay: 200.ms,
                  duration: 350.ms,
                ),

                const SizedBox(height: 12),

                // Quick links
                _SectionCard(
                  title: 'Quick links',
                  actions: <_QuickLink>[
                    _QuickLink(
                      icon: Icons.credit_card_rounded,
                      label: 'Virtual Card',
                      onTap: () => context.go('/virtual-card'),
                    ),
                    _QuickLink(
                      icon: Icons.savings_rounded,
                      label: 'Savings',
                      onTap: () => context.go('/savings'),
                    ),
                    _QuickLink(
                      icon: Icons.local_offer_rounded,
                      label: 'Deals',
                      onTap: () => context.go('/promos'),
                    ),
                    _QuickLink(
                      icon: Icons.help_outline_rounded,
                      label: 'Support',
                      onTap: () {},
                    ),
                  ],
                ).animate().fadeIn(delay: 220.ms, duration: 350.ms),

                const SizedBox(height: 12),

                // Sign out
                GlassCard(
                  onTap: () => context.go('/welcome'),
                  padding: const EdgeInsets.all(14),
                  child: const Row(
                    children: <Widget>[
                      Icon(
                        Icons.logout_rounded,
                        color: Color(0xFFE53935),
                        size: 18,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Sign out',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Color(0xFFE53935),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 260.ms, duration: 350.ms),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({
    required this.fullName,
    required this.tag,
    required this.school,
  });
  final String fullName;
  final String tag;
  final String school;

  @override
  Widget build(BuildContext context) {
    final String initials = fullName
        .split(' ')
        .where((String s) => s.isNotEmpty)
        .take(2)
        .map((String s) => s[0])
        .join();

    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: <Widget>[
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: <Color>[Color(0xFF19B37D), Color(0xFF0F4C3A)],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  fullName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 1),
                Text(
                  tag,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.accent,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  school,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.edit_rounded, size: 16),
            color: AppColors.accent,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  const _MiniStatCard({
    required this.label,
    required this.value,
    required this.icon,
    this.iconColor = AppColors.accent,
  });
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, color: iconColor, size: 18),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: AppColors.textPrimary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 1),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, this.items, this.actions});
  final String title;
  final List<_InfoItem>? items;
  final List<_QuickLink>? actions;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          if (items != null)
            ...items!.map(
              (_InfoItem item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: <Widget>[
                    Icon(item.icon, color: AppColors.accent, size: 14),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            item.label,
                            style: const TextStyle(
                              fontSize: 9,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            item.value,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (actions != null)
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: actions!.map((_QuickLink link) {
                return GestureDetector(
                  onTap: link.onTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accentSoft,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(link.icon, color: AppColors.accent, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          link.label,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}

class _InfoItem {
  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;
}

class _QuickLink {
  const _QuickLink({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
}
