import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/demo_device_shell.dart';
import '../../../../shared/widgets/primary_button.dart';

class AccountCreatedScreen extends StatefulWidget {
  const AccountCreatedScreen({super.key});

  @override
  State<AccountCreatedScreen> createState() => _AccountCreatedScreenState();
}

class _AccountCreatedScreenState extends State<AccountCreatedScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _confettiController;
  bool _copied = false;

  // Mock account number revealed on success
  static const String _accountNumber = '9012 3456 78';
  static const String _bankName = 'SolexPay MFB';

  @override
  void initState() {
    super.initState();
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _copyAccountNumber() {
    Clipboard.setData(const ClipboardData(text: '9012345678'));
    setState(() => _copied = true);
    Future<void>.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DemoDeviceShell(
        child: Scaffold(
          backgroundColor: AppColors.shell,
          resizeToAvoidBottomInset: false,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    const SizedBox(height: 16),
                    // Step pills (complete)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[_StepPills(current: 5, total: 5)],
                    ),

                    const SizedBox(height: 40),

                    // Success lottie-style stack
                    Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        // Outer pulse ring
                        Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(
                                  0xFF0F7A50,
                                ).withValues(alpha: 0.08),
                              ),
                            )
                            .animate(controller: _confettiController)
                            .scale(
                              begin: const Offset(0.4, 0.4),
                              end: const Offset(1, 1),
                              duration: 700.ms,
                              curve: Curves.elasticOut,
                            ),
                        // Inner circle
                        Container(
                              width: 100,
                              height: 100,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF0F7A50),
                                boxShadow: <BoxShadow>[
                                  BoxShadow(
                                    color: Color(0x300F7A50),
                                    blurRadius: 24,
                                    offset: Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 48,
                              ),
                            )
                            .animate(controller: _confettiController)
                            .scale(
                              begin: const Offset(0.2, 0.2),
                              delay: 200.ms,
                              duration: 600.ms,
                              curve: Curves.elasticOut,
                            )
                            .fadeIn(delay: 150.ms, duration: 300.ms),
                      ],
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      'You\'re all set! 🎉',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(delay: 400.ms, duration: 400.ms),

                    const SizedBox(height: 8),

                    const Text(
                      'Your SolexPay wallet is live. Here\'s your\nnew account number.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.55,
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(delay: 500.ms, duration: 350.ms),

                    const SizedBox(height: 28),

                    // Account number card
                    GestureDetector(
                          onTap: _copyAccountNumber,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: _copied
                                  ? const Color(0xFFE2F7EC)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: _copied
                                    ? const Color(0xFF0F7A50)
                                    : AppColors.outline.withValues(alpha: 0.35),
                              ),
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      const Text(
                                        'Account Number',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textSecondary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _accountNumber,
                                        style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.textPrimary,
                                          letterSpacing: 1.5,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      const Text(
                                        _bankName,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 200),
                                  child: _copied
                                      ? const Icon(
                                          Icons.check_circle_rounded,
                                          color: Color(0xFF0F7A50),
                                          key: ValueKey('check'),
                                        )
                                      : Icon(
                                          Icons.copy_rounded,
                                          color: AppColors.textSecondary,
                                          key: const ValueKey('copy'),
                                          size: 20,
                                        ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .animate()
                        .fadeIn(delay: 600.ms, duration: 400.ms)
                        .slideY(begin: 0.1, delay: 600.ms),

                    if (_copied)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: const Text(
                          'Copied to clipboard ✓',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF0F7A50),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                    const SizedBox(height: 48),

                    PrimaryButton(
                      label: 'Set Transaction PIN',
                      onPressed: () => context.go('/pin-setup'),
                      leading: const Icon(Icons.lock_rounded, size: 16),
                    ).animate().fadeIn(delay: 700.ms, duration: 350.ms),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StepPills extends StatelessWidget {
  const _StepPills({required this.current, required this.total});
  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (i) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.only(left: 4),
          height: 4,
          width: 8,
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }
}
