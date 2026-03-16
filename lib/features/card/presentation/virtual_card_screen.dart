import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../mock/demo_app_state.dart';
import '../../../../shared/widgets/demo_device_shell.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/app_header.dart';

class VirtualCardScreen extends StatefulWidget {
  const VirtualCardScreen({super.key});

  @override
  State<VirtualCardScreen> createState() => _VirtualCardScreenState();
}

class _VirtualCardScreenState extends State<VirtualCardScreen>
    with SingleTickerProviderStateMixin {
  bool _isFlipped = false;
  bool _isNumberRevealed = false;
  late final AnimationController _flipController;
  late final Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _flipAnimation = Tween<double>(begin: 0, end: math.pi).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _handleFlip() {
    HapticFeedback.mediumImpact();
    if (_isFlipped) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
    setState(() => _isFlipped = !_isFlipped);
  }

  @override
  Widget build(BuildContext context) {
    final DemoAppState appState = context.watch<DemoAppState>();
    final String firstName = appState.userProfile.fullName.split(' ').first;
    final String lastName = appState.userProfile.fullName.split(' ').last;

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
                  title: 'Virtual Card',
                  subtitle: 'Manage your card settings',
                  onBack: () => context.go('/home'),
                ),
                const SizedBox(height: 14),

                // Flip card
                GestureDetector(
                  onTap: _handleFlip,
                  child: AnimatedBuilder(
                    animation: _flipAnimation,
                    builder: (BuildContext context, Widget? child) {
                      final bool showBack = _flipAnimation.value > math.pi / 2;
                      return Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..rotateY(_flipAnimation.value),
                        child: Transform(
                          alignment: Alignment.center,
                          transform: showBack
                              ? (Matrix4.identity()..rotateY(math.pi))
                              : Matrix4.identity(),
                          child: showBack
                              ? _CardBack(cardHolder: '$firstName $lastName')
                              : _CardFront(
                                  cardHolder: '$firstName $lastName',
                                  isRevealed: _isNumberRevealed,
                                ),
                        ),
                      );
                    },
                  ),
                ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.06),

                const SizedBox(height: 6),

                Center(
                  child: Text(
                    _isFlipped ? 'Tap to flip back' : 'Tap card to flip',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // Card controls
                Row(
                  children: <Widget>[
                    Expanded(
                      child: _CardActionButton(
                        icon: _isNumberRevealed
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                        label: _isNumberRevealed ? 'Hide' : 'Reveal',
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(
                            () => _isNumberRevealed = !_isNumberRevealed,
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _CardActionButton(
                        icon: Icons.copy_rounded,
                        label: 'Copy',
                        onTap: () {
                          Clipboard.setData(
                            const ClipboardData(text: '4242 4242 4242 4242'),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Card number copied'),
                              backgroundColor: AppColors.accent,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _CardActionButton(
                        icon: Icons.ac_unit_rounded,
                        label: 'Freeze',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Card frozen'),
                              backgroundColor: Color(0xFF1A2F4A),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 100.ms, duration: 350.ms),

                const SizedBox(height: 14),

                // Card details
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        'Card details',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _DetailRow(
                        label: 'Card number',
                        value: _isNumberRevealed
                            ? '4242 4242 4242 4242'
                            : '•••• •••• •••• 4242',
                      ),
                      const SizedBox(height: 8),
                      _DetailRow(label: 'Expiry', value: '12/28'),
                      const SizedBox(height: 8),
                      _DetailRow(
                        label: 'CVV',
                        value: _isNumberRevealed ? '123' : '•••',
                      ),
                      const SizedBox(height: 8),
                      _DetailRow(label: 'Name', value: '$firstName $lastName'),
                      const SizedBox(height: 8),
                      _DetailRow(label: 'Type', value: 'Visa · Virtual'),
                      const SizedBox(height: 8),
                      _DetailRow(label: 'Currency', value: 'USD'),
                    ],
                  ),
                ).animate().fadeIn(delay: 150.ms, duration: 350.ms),

                const SizedBox(height: 10),

                // Spending limit
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        'Spending limit',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            '\$18.50 used',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '\$500 limit',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: const LinearProgressIndicator(
                          value: 18.50 / 500,
                          minHeight: 6,
                          backgroundColor: AppColors.outline,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.accent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 200.ms, duration: 350.ms),

                const SizedBox(height: 14),

                PrimaryButton(
                  label: 'Top up card',
                  onPressed: () => context.go('/fund-account'),
                ).animate().fadeIn(delay: 250.ms, duration: 300.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CardFront extends StatelessWidget {
  const _CardFront({required this.cardHolder, required this.isRevealed});
  final String cardHolder;
  final bool isRevealed;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment(-1, -1),
          end: Alignment(1, 1),
          colors: <Color>[
            Color(0xFF0D1B2A),
            Color(0xFF1B3A56),
            Color(0xFF19B37D),
          ],
          stops: <double>[0, 0.6, 1],
        ),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x3019B37D),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const Text(
                'SolexPay',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
              Image.asset(
                'assets/visa_logo.png',
                height: 16,
                errorBuilder: (BuildContext ctx, Object e, StackTrace? st) =>
                    const Text(
                      'VISA',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            width: 30,
            height: 22,
            decoration: BoxDecoration(
              color: const Color(0xFFD4AF37),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            isRevealed ? '4242  4242  4242  4242' : '••••  ••••  ••••  4242',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                cardHolder.toUpperCase(),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 10,
                  letterSpacing: 0.8,
                ),
              ),
              Text(
                '12/28',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CardBack extends StatelessWidget {
  const _CardBack({required this.cardHolder});
  final String cardHolder;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFF1B3A56), Color(0xFF0D1B2A)],
        ),
      ),
      child: Column(
        children: <Widget>[
          const SizedBox(height: 26),
          Container(height: 34, color: Colors.black45),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: const Text(
                      '123',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'CVV',
                  style: TextStyle(color: Color(0x80FFFFFF), fontSize: 10),
                ),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(bottom: 12, right: 18),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                'VISA',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardActionButton extends StatelessWidget {
  const _CardActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: <Widget>[
          Icon(icon, color: AppColors.accent, size: 18),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});
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
        Flexible(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
