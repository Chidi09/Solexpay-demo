import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_header.dart';
import '../../../../shared/widgets/demo_device_shell.dart';

class SendChoiceScreen extends StatelessWidget {
  const SendChoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DemoDeviceShell(
        child: Scaffold(
          backgroundColor: AppColors.surface,
          resizeToAvoidBottomInset: false,
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              children: <Widget>[
                AppHeader.withBack(
                  title: 'Send Money',
                  subtitle: 'Choose transfer method',
                  onBack: () => context.go('/home'),
                ),
                const SizedBox(height: 32),

                // ── Action Cards ───────────────────────────────────────────
                _ActionCard(
                  icon: Icons.person_rounded,
                  iconBgColor: AppColors.primary,
                  iconColor: AppColors.onPrimary,
                  title: 'To a SolexPay user',
                  subtitle: 'Instant peer-to-peer transfer',
                  onTap: () => context.go('/transfer/p2p'),
                ),
                const SizedBox(height: 16),
                _ActionCard(
                  icon: Icons.account_balance_rounded,
                  iconBgColor: AppColors.secondaryFixed,
                  iconColor: AppColors.onSecondaryFixed,
                  title: 'To a bank account',
                  subtitle: 'External transfer (1-2 business days)',
                  onTap: () => context.go('/transfer/bank'),
                ),

                const SizedBox(height: 40),

                // ── Recent Contacts ────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    // FIX: Wrapped title in Expanded to prevent RenderFlex overflow
                    const Expanded(
                      child: Text(
                        'RECENT TRANSFERS',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                          color: AppColors.onSurfaceVariant,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: const Text(
                        'View All',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.secondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: <Widget>[
                      _ContactAvatar(name: 'Alex M.', isNew: false),
                      const SizedBox(width: 16),
                      _ContactAvatar(name: 'Sarah K.', isNew: false),
                      const SizedBox(width: 16),
                      _ContactAvatar(name: 'James T.', isNew: false),
                      const SizedBox(width: 16),
                      _ContactAvatar(name: 'New', isNew: true),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Action Card ───────────────────────────────────────────────────────────────

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AppColors.onSurface.withValues(alpha: 0.05),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.primary,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Contact Avatar ────────────────────────────────────────────────────────────

class _ContactAvatar extends StatelessWidget {
  const _ContactAvatar({required this.name, required this.isNew});

  final String name;
  final bool isNew;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: isNew
                ? AppColors.surfaceContainerLow
                : AppColors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: isNew ? AppColors.outlineVariant : AppColors.surface,
              width: isNew ? 2 : 2,
              style: isNew ? BorderStyle.none : BorderStyle.solid,
            ),
          ),
          child: isNew
              ? Icon(Icons.add, color: AppColors.outline)
              : Center(
                  child: Text(
                    name.substring(0, 1),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: isNew ? AppColors.onSurfaceVariant : AppColors.onSurface,
          ),
        ),
      ],
    );
  }
}
