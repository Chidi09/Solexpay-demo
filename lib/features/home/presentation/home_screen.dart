import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../mock/demo_app_state.dart';
import '../../../../shared/models/transaction_item.dart';
import '../../../../shared/utils/currency_formatter.dart';
import '../../../../shared/widgets/app_header.dart';
import '../../../../shared/widgets/branded_icons.dart';
import '../../../../shared/widgets/demo_device_shell.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isBalanceVisible = true;

  void _toggleBalanceVisibility() {
    setState(() {
      _isBalanceVisible = !_isBalanceVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    final DemoAppState appState = context.watch<DemoAppState>();
    final List<TransactionItem> recent = appState.transactions
        .take(3)
        .toList(growable: false);

    return Scaffold(
      body: DemoDeviceShell(
        child: Scaffold(
          backgroundColor: AppColors.surface,
          resizeToAvoidBottomInset: false,
          body: SafeArea(
            child: Column(
              children: <Widget>[
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    children: <Widget>[
                      // ── Header ──────────────────────────────────────────
                      AppHeader.home(
                        unreadCount: appState.unreadNotifications,
                        onProfileTap: () => context.go('/notifications'),
                      ),
                      const SizedBox(height: 12),

                      // ── Balance card ────────────────────────────────────
                      _BalanceCard(
                        balance: appState.balance,
                        accountNumber: appState.userProfile.accountNumber,
                        isVisible: _isBalanceVisible,
                        onToggleVisibility: _toggleBalanceVisibility,
                      ),
                      const SizedBox(height: 14),

                      // ── Quick actions ───────────────────────────────────
                      _QuickActions(
                        onSend: () => context.go('/transfer'),
                        onReceive: () => context.go('/receive-money'),
                        onFund: () => context.go('/fund-account'),
                        onMore: () => _showMoreSheet(context),
                      ),
                      const SizedBox(height: 24),

                      // ── Services grid ───────────────────────────────────
                      _ServicesSection(),
                      const SizedBox(height: 18),

                      // ── Recent activity ─────────────────────────────────
                      Row(
                        children: <Widget>[
                          const Expanded(
                            child: Text(
                              'Recent activity',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.onSurface,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => context.go('/history'),
                            child: const Text(
                              'See all',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.secondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.outlineVariant.withValues(
                              alpha: 0.5,
                            ),
                          ),
                        ),
                        child: Column(
                          children: <Widget>[
                            for (int i = 0; i < recent.length; i++) ...<Widget>[
                              _RecentTxRow(item: recent[i]),
                              if (i < recent.length - 1)
                                Divider(
                                  height: 1,
                                  indent: 60,
                                  color: AppColors.outlineVariant.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
                // Manual bottom nav (avoids overlap with home pill - §8.4)
                _BottomNav(
                  selectedIndex: 0,
                  onTap: (int i) {
                    const List<String> routes = <String>[
                      '/home',
                      '/history',
                      '/transfer',
                      '/profile',
                    ];
                    context.go(routes[i]);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showMoreSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.outline,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'More Services',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                _MoreOption(
                  icon: Icons.credit_card_rounded,
                  label: 'Virtual Card',
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/virtual-card');
                  },
                ),
                _MoreOption(
                  icon: Icons.local_offer_rounded,
                  label: 'Promos & Deals',
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/promos');
                  },
                ),
                _MoreOption(
                  icon: Icons.history_rounded,
                  label: 'Transaction History',
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/history');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Balance Card ──────────────────────────────────────────────────────────────

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({
    required this.balance,
    required this.accountNumber,
    required this.isVisible,
    required this.onToggleVisibility,
  });

  final double balance;
  final String accountNumber;
  final bool isVisible;
  final VoidCallback onToggleVisibility;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[AppColors.primary, AppColors.primaryContainer],
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: <Widget>[
            // Geometric shapes
            Positioned(
              top: -30,
              right: -20,
              child: Transform.rotate(
                angle: 0.5,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -15,
              left: -10,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.03),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      const Text(
                        'Available balance',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Colors.white70,
                        ),
                      ),
                      GestureDetector(
                        onTap: onToggleVisibility,
                        child: Icon(
                          isVisible
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                          color: Colors.white70,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      isVisible ? CurrencyFormatter.format(balance) : '••••••',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isVisible
                          ? 'Account: $accountNumber'
                          : 'Account: ••••••••••',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white70,
                      ),
                    ),
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

// ── Quick Actions ─────────────────────────────────────────────────────────────

class _QuickActions extends StatelessWidget {
  const _QuickActions({
    required this.onSend,
    required this.onReceive,
    required this.onFund,
    required this.onMore,
  });

  final VoidCallback onSend;
  final VoidCallback onReceive;
  final VoidCallback onFund;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        _ActionButton(icon: Icons.send_rounded, label: 'Send', onTap: onSend),
        _ActionButton(
          icon: Icons.call_received_rounded,
          label: 'Receive',
          onTap: onReceive,
        ),
        _ActionButton(
          icon: Icons.add_card_rounded,
          label: 'Fund',
          onTap: onFund,
        ),
        _ActionButton(
          icon: Icons.grid_view_rounded,
          label: 'More',
          onTap: onMore,
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primaryFixed,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Services Section ───────────────────────────────────────────────────────────

class _ServicesSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final List<_ServiceItem> items = <_ServiceItem>[
      const _ServiceItem(
        service: 'savings',
        label: 'Savings',
        color: AppColors.secondary,
        route: '/savings',
      ),
      const _ServiceItem(
        service: 'loans',
        label: 'Loans',
        color: Color(0xFF6C63FF),
        route: '/loans',
      ),
      const _ServiceItem(
        service: 'airtime',
        label: 'Airtime',
        color: Color(0xFFFFAA00),
        route: '/airtime',
      ),
      const _ServiceItem(
        service: 'data',
        label: 'Data',
        color: Color(0xFF00875A),
        route: '/data',
      ),
      const _ServiceItem(
        service: 'card',
        label: 'Card',
        color: Color(0xFFFF6B35),
        route: '/virtual-card',
      ),
      const _ServiceItem(
        service: 'transfer',
        label: 'Deals',
        color: Color(0xFFE53935),
        route: '/promos',
      ),
    ];

    // Split into rows of 3
    final List<List<_ServiceItem>> rows = <List<_ServiceItem>>[];
    for (int i = 0; i < items.length; i += 3) {
      rows.add(items.sublist(i, i + 3 > items.length ? items.length : i + 3));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'Services',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 10),
        ...rows.map((List<_ServiceItem> group) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: <Widget>[
                for (int i = 0; i < group.length; i++) ...<Widget>[
                  if (i > 0) const SizedBox(width: 8),
                  Expanded(child: _ServiceCard(item: group[i])),
                ],
                // Fill remaining space if row is incomplete
                for (int i = group.length; i < 3; i++) ...<Widget>[
                  const SizedBox(width: 8),
                  const Expanded(child: SizedBox()),
                ],
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.item});

  final _ServiceItem item;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go(item.route),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.outlineVariant.withValues(alpha: 0.3),
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AppColors.onSurface.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: item.color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: ServiceIcon(
                service: item.service,
                size: 16,
                color: item.color,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              item.label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceItem {
  const _ServiceItem({
    required this.service,
    required this.label,
    required this.color,
    required this.route,
  });

  final String service;
  final String label;
  final Color color;
  final String route;
}

// ── Recent Activity Row ────────────────────────────────────────────────────────

class _RecentTxRow extends StatelessWidget {
  const _RecentTxRow({required this.item});

  final TransactionItem item;

  (IconData icon, Color bgColor, Color iconColor) _getIconConfig() {
    final String title = item.title.toLowerCase();
    final bool isIncoming = item.type == TransactionType.credit;

    if (title.contains('scholarship') ||
        title.contains('payout') ||
        title.contains('grant')) {
      return (Icons.school_rounded, AppColors.primaryFixed, AppColors.primary);
    } else if (title.contains('cafe') ||
        title.contains('lunch') ||
        title.contains('food') ||
        title.contains('restaurant')) {
      return (
        Icons.restaurant_rounded,
        const Color(0xFFFFF3E0),
        const Color(0xFFFF6F00),
      );
    } else if (title.contains('data') ||
        title.contains('airtime') ||
        title.contains('bundle')) {
      return (
        Icons.wifi_rounded,
        const Color(0xFFE3F2FD),
        const Color(0xFF1565C0),
      );
    } else if (title.contains('savings') || title.contains('save')) {
      return (
        Icons.savings_rounded,
        const Color(0xFFE8F5E9),
        const Color(0xFF2E7D32),
      );
    } else if (title.contains('refund') || title.contains('repay')) {
      return (
        Icons.replay_rounded,
        const Color(0xFFF3E5F5),
        const Color(0xFF7B1FA2),
      );
    } else if (title.contains('book') ||
        title.contains('shop') ||
        title.contains('store')) {
      return (
        Icons.shopping_bag_rounded,
        const Color(0xFFFFEBEE),
        const Color(0xFFC62828),
      );
    } else if (title.contains('transfer') || title.contains('send')) {
      return (
        Icons.send_rounded,
        isIncoming ? AppColors.secondaryFixed : AppColors.tertiaryFixed,
        isIncoming ? AppColors.secondary : AppColors.tertiary,
      );
    } else if (isIncoming) {
      return (
        Icons.arrow_downward_rounded,
        AppColors.secondaryFixed,
        AppColors.secondary,
      );
    } else {
      return (
        Icons.arrow_upward_rounded,
        AppColors.tertiaryFixed,
        AppColors.tertiary,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final (icon, bgColor, iconColor) = _getIconConfig();
    final bool isIncoming = item.type == TransactionType.credit;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: <Widget>[
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  item.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppColors.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 1),
                Text(
                  DateFormat('MMM d, h:mm a').format(item.occurredAt),
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${isIncoming ? '+' : '-'}${CurrencyFormatter.format(item.amount)}',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: isIncoming ? AppColors.secondary : AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Bottom Nav ─────────────────────────────────────────────────────────────────

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.selectedIndex, required this.onTap});

  final int selectedIndex;
  final void Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    const List<_NavItem> items = <_NavItem>[
      _NavItem(icon: Icons.home_rounded, label: 'Home'),
      _NavItem(icon: Icons.history_rounded, label: 'Activity'),
      _NavItem(icon: Icons.payments_rounded, label: 'Pay'),
      _NavItem(icon: Icons.person_rounded, label: 'Profile'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border(
          top: BorderSide(
            color: AppColors.outlineVariant.withValues(alpha: 0.5),
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 56,
          child: Row(
            children: items.asMap().entries.map((MapEntry<int, _NavItem> e) {
              final bool selected = e.key == selectedIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(e.key),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        e.value.icon,
                        size: 22,
                        color: selected
                            ? AppColors.primary
                            : AppColors.onSurfaceVariant,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        e.value.label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: selected
                              ? AppColors.primary
                              : AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

// ── More Option (Bottom Sheet) ─────────────────────────────────────────────────

class _MoreOption extends StatelessWidget {
  const _MoreOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primaryFixed,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary),
      ),
      title: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.onSurface,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: AppColors.onSurfaceVariant,
      ),
      onTap: onTap,
    );
  }
}
