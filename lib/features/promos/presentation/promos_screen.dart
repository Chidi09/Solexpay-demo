import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/demo_device_shell.dart';
import '../../../../shared/widgets/glass_card.dart';
import 'widgets/custom_promo_card.dart';

class PromosScreen extends StatelessWidget {
  const PromosScreen({super.key});

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
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Deals & Promos',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'Exclusive offers for SolexPay users.',
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
                const SizedBox(height: 12),

                // Custom illustrated promo card
                CustomPromoCard(
                  title: 'Student Loan Bonus',
                  subtitle:
                      'Get up to NGN 5,000 with zero interest for 30 days',
                  onTap: () => context.go('/loans'),
                ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.05),

                const SizedBox(height: 12),

                // Featured banners
                _FeaturedPromo(
                  title: 'Double your savings interest',
                  subtitle: 'Save NGN 10,000+ this month and earn 16% p.a.',
                  cta: 'Start Saving',
                  onTap: () => context.go('/savings'),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[Color(0xFF0F4C3A), Color(0xFF19B37D)],
                  ),
                  icon: Icons.savings_rounded,
                ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.05),

                const SizedBox(height: 10),

                _FeaturedPromo(
                      title: 'Free first loan',
                      subtitle:
                          'Zero interest on your first Campus Flex Loan up to NGN 5,000.',
                      cta: 'Get Loan',
                      onTap: () => context.go('/loans'),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: <Color>[Color(0xFF1A2F4A), Color(0xFF6C63FF)],
                      ),
                      icon: Icons.bolt_rounded,
                    )
                    .animate()
                    .fadeIn(delay: 80.ms, duration: 350.ms)
                    .slideY(begin: 0.05),

                const SizedBox(height: 16),

                const Text(
                  'All offers',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),

                ...<_PromoItem>[
                  _PromoItem(
                    icon: Icons.local_phone_rounded,
                    color: const Color(0xFFFFCC00),
                    title: '3% airtime Cashback',
                    desc: 'Every top-up until March 31st',
                    badge: 'Active',
                    onTap: () => context.go('/airtime'),
                  ),
                  _PromoItem(
                    icon: Icons.wifi_rounded,
                    color: const Color(0xFF006633),
                    title: 'Student data deal',
                    desc: '15GB for NGN 3,500 — MTN only',
                    badge: 'Limited',
                    onTap: () => context.go('/data'),
                  ),
                  _PromoItem(
                    icon: Icons.credit_card_rounded,
                    color: const Color(0xFF6C63FF),
                    title: 'Virtual card launch',
                    desc: 'Get a free virtual dollar card',
                    badge: 'New',
                    onTap: () => context.go('/virtual-card'),
                  ),
                  _PromoItem(
                    icon: Icons.people_alt_rounded,
                    color: const Color(0xFFFF8A3D),
                    title: 'Refer & earn',
                    desc: 'NGN 500 for every friend you invite',
                    badge: 'Ongoing',
                    onTap: () {},
                  ),
                ].asMap().entries.map((MapEntry<int, _PromoItem> entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child:
                        GlassCard(
                          onTap: entry.value.onTap,
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: <Widget>[
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: entry.value.color.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(11),
                                ),
                                child: Icon(
                                  entry.value.icon,
                                  color: entry.value.color,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      entry.value.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 1),
                                    Text(
                                      entry.value.desc,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.accentSoft,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  entry.value.badge,
                                  style: const TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.accent,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(
                          delay: Duration(milliseconds: 150 + entry.key * 60),
                          duration: 300.ms,
                        ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeaturedPromo extends StatelessWidget {
  const _FeaturedPromo({
    required this.title,
    required this.subtitle,
    required this.cta,
    required this.onTap,
    required this.gradient,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final String cta;
  final VoidCallback onTap;
  final LinearGradient gradient;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.75),
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      cta,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Icon(icon, color: Colors.white.withValues(alpha: 0.2), size: 40),
          ],
        ),
      ),
    );
  }
}

class _PromoItem {
  const _PromoItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.desc,
    required this.badge,
    required this.onTap,
  });
  final IconData icon;
  final Color color;
  final String title;
  final String desc;
  final String badge;
  final VoidCallback onTap;
}
