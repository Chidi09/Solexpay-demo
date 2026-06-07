import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/state/registration_state.dart';
import '../../../../shared/widgets/demo_device_shell.dart';
import '../../../../shared/widgets/primary_button.dart';

class BvnScreen extends StatefulWidget {
  const BvnScreen({super.key});

  @override
  State<BvnScreen> createState() => _BvnScreenState();
}

class _BvnScreenState extends State<BvnScreen> {
  late final TextEditingController _bvnController;
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _bvnController = TextEditingController();
    _focusNode.addListener(
      () => setState(() => _isFocused = _focusNode.hasFocus),
    );
  }

  @override
  void dispose() {
    _bvnController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  bool get _isValidBvn =>
      RegExp(r'^\d{11}$').hasMatch(_bvnController.text.trim());

  Future<void> _verifyBvn() async {
    if (!_isValidBvn || _isLoading) return;
    setState(() => _isLoading = true);

    try {
      final apiService = context.read<ApiService>();
      final bvn = _bvnController.text.trim();
      
      await apiService.verifyBvn(bvn);
      if (mounted) {
        context.read<RegistrationState>().setBvn(bvn);
        context.go('/selfie');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final int len = _bvnController.text.length;

    return Scaffold(
      body: DemoDeviceShell(
        child: Scaffold(
          backgroundColor: AppColors.shell,
          resizeToAvoidBottomInset: false,
          body: SafeArea(
            child: GestureDetector(
              onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
              behavior: HitTestBehavior.translucent,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const SizedBox(height: 16),

                      // Back + step indicator
                      Row(
                        children: <Widget>[
                          GestureDetector(
                            onTap: () => Navigator.of(context).maybePop(),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: AppColors.outline.withValues(
                                    alpha: 0.4,
                                  ),
                                ),
                              ),
                              child: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                size: 16,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          const Spacer(),
                          _StepPills(current: 3, total: 5),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Shield icon badge
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppColors.accentSoft,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.verified_user_rounded,
                          color: AppColors.accent,
                          size: 26,
                        ),
                      ).animate().scale(
                        begin: const Offset(0.8, 0.8),
                        duration: 400.ms,
                        curve: Curves.elasticOut,
                      ),

                      const SizedBox(height: 16),

                      const Text(
                        'Verify your BVN',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.4,
                        ),
                      ).animate().fadeIn(delay: 80.ms),

                      const SizedBox(height: 6),

                      const Text(
                        'Required by CBN regulations to open your account.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ).animate().fadeIn(delay: 120.ms),

                      const SizedBox(height: 28),

                      // BVN input
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _isValidBvn
                                ? const Color(0xFF0F7A50)
                                : _isFocused
                                ? AppColors.accent
                                : AppColors.outline.withValues(alpha: 0.4),
                            width: _isFocused || _isValidBvn ? 1.5 : 1,
                          ),
                          boxShadow: _isFocused
                              ? <BoxShadow>[
                                  BoxShadow(
                                    color: AppColors.accent.withValues(
                                      alpha: 0.08,
                                    ),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : null,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: TextField(
                                  controller: _bvnController,
                                  focusNode: _focusNode,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  maxLength: 11,
                                  onChanged: (_) => setState(() {}),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 2,
                                    color: AppColors.textPrimary,
                                  ),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    counterText: '',
                                    hintText: '• • • • • • • • • • •',
                                    hintStyle: TextStyle(
                                      fontSize: 16,
                                      letterSpacing: 3,
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    labelText: 'Bank Verification Number',
                                    labelStyle: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.always,
                                  ),
                                ),
                              ),
                              // Validation indicator
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                child: _isValidBvn
                                    ? const Icon(
                                        Icons.check_circle_rounded,
                                        color: Color(0xFF0F7A50),
                                        size: 20,
                                        key: ValueKey('valid'),
                                      )
                                    : Text(
                                        '$len/11',
                                        key: const ValueKey('count'),
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: len > 0
                                              ? AppColors.accent
                                              : AppColors.textSecondary,
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(delay: 150.ms, duration: 300.ms),

                      const SizedBox(height: 14),

                      // Why BVN box
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.accentSoft.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.accent.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const Icon(
                              Icons.lock_person_rounded,
                              color: AppColors.accent,
                              size: 16,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  const Text(
                                    'Why do we need your BVN?',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'CBN requires BVN to verify your identity. Dial *565*0# to retrieve it. We cannot access your bank accounts or funds.',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecondary,
                                      height: 1.45,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  // Trust badges
                                  Row(
                                    children: <Widget>[
                                      _TrustBadge(
                                        icon: Icons.security_rounded,
                                        label: 'SSL Encrypted',
                                      ),
                                      const SizedBox(width: 8),
                                      _TrustBadge(
                                        icon: Icons.verified_rounded,
                                        label: 'CBN Approved',
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 200.ms, duration: 350.ms),

                      const SizedBox(height: 32),

                      PrimaryButton(
                        label: 'Continue',
                        isLoading: _isLoading,
                        onPressed: _isValidBvn ? _verifyBvn : null,
                      ).animate().fadeIn(delay: 250.ms),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TrustBadge extends StatelessWidget {
  const _TrustBadge({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 10, color: AppColors.accent),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.accent,
            ),
          ),
        ],
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
        final bool active = i < current;
        final bool isCurrent = i == current - 1;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.only(left: 4),
          height: 4,
          width: isCurrent ? 20 : 8,
          decoration: BoxDecoration(
            color: active
                ? AppColors.accent
                : AppColors.outline.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }
}
