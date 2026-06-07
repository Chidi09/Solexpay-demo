import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/api_service.dart';
import '../../../../mock/demo_app_state.dart';
import '../../../../shared/utils/currency_formatter.dart';
import '../../../../shared/widgets/app_header.dart';
import '../../../../shared/widgets/demo_device_shell.dart';

class SavingsScreen extends StatefulWidget {
  const SavingsScreen({super.key});

  @override
  State<SavingsScreen> createState() => _SavingsScreenState();
}

class _SavingsScreenState extends State<SavingsScreen>
    with SingleTickerProviderStateMixin {
  bool _isTopUpLoading = false;
  bool _isWithdrawLoading = false;
  bool _isLoadingSavings = false;
  String? _primarySavingsAccountId;
  late final AnimationController _ringController;

  @override
  void initState() {
    super.initState();
    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSavingsData();
    });
  }

  Future<void> _loadSavingsData() async {
    if (_isLoadingSavings) return;
    setState(() => _isLoadingSavings = true);

    try {
      final apiService = context.read<ApiService>();
      final res = await apiService.getSavingsAccounts();
      final list = res['data'] as List<dynamic>? ?? [];
      
      double totalSavings = 0;
      String? firstActiveId;
      for (final item in list) {
        final Map<String, dynamic> map = item as Map<String, dynamic>;
        if (map['status'] == 'ACTIVE') {
          totalSavings += (map['balanceNaira'] as num?)?.toDouble() ?? 0.0;
          firstActiveId ??= map['id'] as String?;
        }
      }

      if (mounted) {
        context.read<DemoAppState>().updateSavingsBalance(totalSavings);
        setState(() => _primarySavingsAccountId = firstActiveId);
      }
    } catch (e) {
      debugPrint('Error loading savings accounts: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingSavings = false);
      }
    }
  }

  @override
  void dispose() {
    _ringController.dispose();
    super.dispose();
  }

  Future<void> _handleTopUp(DemoAppState appState) async {
    final accountId = _primarySavingsAccountId;
    if (accountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No active savings account found')),
      );
      return;
    }
    setState(() => _isTopUpLoading = true);
    try {
      final apiService = context.read<ApiService>();
      await apiService.depositToSavings(
        savingsAccountId: accountId,
        amountNaira: 5000,
      );
      if (!mounted) return;
      appState.updateSavingsBalance(appState.savingsBalance + 5000);
      appState.updateWalletBalance(appState.balance - 5000);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('₦5,000 added to savings'),
          backgroundColor: AppColors.secondary,
        ),
      );
      _ringController
        ..reset()
        ..forward();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Top-up failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _isTopUpLoading = false);
    }
  }

  Future<void> _handleWithdraw(DemoAppState appState) async {
    if (appState.savingsBalance <= 0) return;
    final accountId = _primarySavingsAccountId;
    if (accountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No active savings account found')),
      );
      return;
    }
    final double amount =
        appState.savingsBalance >= 2000 ? 2000 : appState.savingsBalance;
    setState(() => _isWithdrawLoading = true);
    try {
      final apiService = context.read<ApiService>();
      await apiService.withdrawFromSavings(
        savingsAccountId: accountId,
        amountNaira: amount,
      );
      if (!mounted) return;
      appState.updateSavingsBalance(appState.savingsBalance - amount);
      appState.updateWalletBalance(appState.balance + amount);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${CurrencyFormatter.format(amount)} withdrawn to wallet'),
          backgroundColor: AppColors.secondary,
        ),
      );
      _ringController
        ..reset()
        ..forward();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Withdrawal failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _isWithdrawLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final DemoAppState appState = context.watch<DemoAppState>();

    return Scaffold(
      body: DemoDeviceShell(
        child: Scaffold(
          backgroundColor: AppColors.surface,
          resizeToAvoidBottomInset: false,
          body: SafeArea(
            child: ListView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              children: <Widget>[
                AppHeader.withBack(
                  title: 'Savings',
                  subtitle: 'Grow your money',
                  onBack: () => context.go('/home'),
                ),
                const SizedBox(height: 16),

                // ── Hero card with ring ────────────────────────────────────
                _SavingsHeroCard(
                  savingsBalance: appState.savingsBalance,
                  ringController: _ringController,
                  onTopUp: () => _handleTopUp(appState),
                  onWithdraw: () => _handleWithdraw(appState),
                  isTopUpLoading: _isTopUpLoading,
                  isWithdrawLoading: _isWithdrawLoading,
                ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.06),

                const SizedBox(height: 20),

                // ── Metrics bento ──────────────────────────────────────────
                Row(
                  children: <Widget>[
                    Expanded(
                      child: _MetricCard(
                        icon: Icons.local_fire_department_rounded,
                        iconBgColor: AppColors.tertiaryFixed,
                        iconColor: AppColors.tertiary,
                        label: 'Weekly Streak',
                        value: '14 Weeks',
                        trend: '+2 this month',
                        trendPositive: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _MetricCard(
                        icon: Icons.stacked_line_chart_rounded,
                        iconBgColor: AppColors.secondaryFixed,
                        iconColor: AppColors.secondary,
                        label: 'Interest Earned',
                        value:
                            '+${CurrencyFormatter.format(appState.savingsBalance * 0.08)}',
                        trend: '8% p.a.',
                        trendPositive: true,
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 100.ms, duration: 350.ms),

                const SizedBox(height: 24),

                // ── Goals section ──────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    const Text(
                      'Active Goals',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                    Row(
                      children: <Widget>[
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
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () {},
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: AppColors.secondaryFixed,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.add_rounded,
                              size: 14,
                              color: AppColors.secondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const _GoalCard(
                  title: 'Laptop Fund',
                  target: 240000,
                  current: 60000,
                  icon: Icons.laptop_mac_rounded,
                  isPrimary: true,
                  deadline: 'Dec 2025',
                ).animate().fadeIn(delay: 150.ms, duration: 350.ms),
                const SizedBox(height: 10),
                const _GoalCard(
                  title: 'House Deposit',
                  target: 800000,
                  current: 96000,
                  icon: Icons.home_rounded,
                  isPrimary: false,
                  deadline: 'Mar 2026',
                ).animate().fadeIn(delay: 200.ms, duration: 350.ms),

                const SizedBox(height: 24),

                // ── Smart tip ──────────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: <Color>[Color(0xFF2D5BE3), Color(0xFF6C63FF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: const Color(0xFF2D5BE3).withValues(alpha: 0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    '✨ Smart Tip',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Boost your Laptop Fund by enabling round-ups on daily purchases.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                height: 1.45,
                              ),
                            ),
                            const SizedBox(height: 10),
                            GestureDetector(
                              onTap: () {},
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'Enable Round-Ups',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF2D5BE3),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.auto_awesome_rounded,
                        color: Colors.white,
                        size: 40,
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 250.ms, duration: 350.ms),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Hero card ─────────────────────────────────────────────────────────────────

class _SavingsHeroCard extends StatelessWidget {
  const _SavingsHeroCard({
    required this.savingsBalance,
    required this.ringController,
    required this.onTopUp,
    required this.onWithdraw,
    required this.isTopUpLoading,
    required this.isWithdrawLoading,
  });

  final double savingsBalance;
  final AnimationController ringController;
  final VoidCallback onTopUp;
  final VoidCallback onWithdraw;
  final bool isTopUpLoading;
  final bool isWithdrawLoading;

  static const double _monthlyGoal = 120000;

  @override
  Widget build(BuildContext context) {
    final double progress =
        (savingsBalance / _monthlyGoal).clamp(0.0, 1.0);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[AppColors.primary, AppColors.primaryContainer],
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: <Widget>[
            // Decorative BG icon
            Positioned(
              right: -24,
              bottom: -24,
              child: Transform.rotate(
                angle: 0.2,
                child: Icon(
                  Icons.savings_rounded,
                  size: 150,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Top row: label + ring
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const Text(
                              'TOTAL SAVED',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.5,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 8),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                CurrencyFormatter.format(savingsBalance),
                                style: const TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: -1,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${(progress * 100).round()}% of monthly goal',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.white60,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Circular progress ring
                      AnimatedBuilder(
                        animation: ringController,
                        builder: (context, _) {
                          final double animatedProgress =
                              progress * ringController.value;
                          return SizedBox(
                            width: 72,
                            height: 72,
                            child: CustomPaint(
                              painter: _RingPainter(
                                progress: animatedProgress,
                              ),
                              child: Center(
                                child: Text(
                                  '${(animatedProgress * 100).round()}%',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Action buttons
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: _HeroButton(
                          label: 'Add Funds',
                          icon: Icons.add_rounded,
                          isLoading: isTopUpLoading,
                          onTap: isTopUpLoading ? null : onTopUp,
                          primary: true,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _HeroButton(
                          label: 'Withdraw',
                          icon: Icons.remove_rounded,
                          isLoading: isWithdrawLoading,
                          onTap: isWithdrawLoading ? null : onWithdraw,
                          primary: false,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.progress});
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    final double cy = size.height / 2;
    final double radius = (size.width / 2) - 5;

    // Track
    canvas.drawCircle(
      Offset(cx, cy),
      radius,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6,
    );

    // Progress arc
    final Paint arcPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}

class _HeroButton extends StatelessWidget {
  const _HeroButton({
    required this.label,
    required this.icon,
    required this.primary,
    this.isLoading = false,
    this.onTap,
  });

  final String label;
  final IconData icon;
  final bool primary;
  final bool isLoading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: primary
              ? Colors.white
              : Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: primary
              ? null
              : Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                ),
        ),
        child: isLoading
            ? Center(
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      primary ? AppColors.primary : Colors.white,
                    ),
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    icon,
                    size: 16,
                    color: primary ? AppColors.primary : Colors.white,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: primary ? AppColors.primary : Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// ── Metric card ───────────────────────────────────────────────────────────────

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.trend,
    required this.trendPositive,
  });

  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String label;
  final String value;
  final String trend;
  final bool trendPositive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.onSurface.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 14),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          // Trend tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: trendPositive
                  ? const Color(0xFFE2F7EC)
                  : const Color(0xFFFFEBED),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              trend,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: trendPositive
                    ? const Color(0xFF0F7A50)
                    : const Color(0xFFD03040),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Goal card ─────────────────────────────────────────────────────────────────

class _GoalCard extends StatelessWidget {
  const _GoalCard({
    required this.title,
    required this.target,
    required this.current,
    required this.icon,
    required this.isPrimary,
    required this.deadline,
  });

  final String title;
  final double target;
  final double current;
  final IconData icon;
  final bool isPrimary;
  final String deadline;

  @override
  Widget build(BuildContext context) {
    final double progress = (current / target).clamp(0.0, 1.0);
    final String percentage = '${(progress * 100).round()}%';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isPrimary
            ? AppColors.surfaceContainerLow
            : AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isPrimary
              ? AppColors.primary.withValues(alpha: 0.2)
              : AppColors.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isPrimary
                      ? AppColors.surfaceContainerLowest
                      : AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: isPrimary
                      ? AppColors.primary
                      : AppColors.onSurfaceVariant,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: <Widget>[
                        const Icon(
                          Icons.flag_outlined,
                          size: 11,
                          color: AppColors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          'By $deadline',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                    percentage,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: isPrimary
                          ? AppColors.primary
                          : AppColors.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    'done',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Progress bar
          Stack(
            children: <Widget>[
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: isPrimary
                      ? AppColors.surfaceContainer
                      : AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: progress,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isPrimary
                          ? <Color>[AppColors.primary, AppColors.primaryContainer]
                          : <Color>[AppColors.secondary, AppColors.secondaryContainer],
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                '${CurrencyFormatter.format(current)} saved',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
              Text(
                '${CurrencyFormatter.format(target - current)} left',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
