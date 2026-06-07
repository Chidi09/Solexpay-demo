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

class PinSetupScreen extends StatefulWidget {
  const PinSetupScreen({super.key});

  @override
  State<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen> {
  late final TextEditingController _pinController;
  late final TextEditingController _confirmController;
  bool _isSaving = false;
  bool _pinVisible = false;
  bool _confirmVisible = false;

  @override
  void initState() {
    super.initState();
    _pinController = TextEditingController();
    _confirmController = TextEditingController();
  }

  @override
  void dispose() {
    _pinController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  bool get _pinValid => RegExp(r'^\d{4}$').hasMatch(_pinController.text.trim());
  bool get _pinsMatch =>
      _pinController.text.trim() == _confirmController.text.trim();
  bool get _canSubmit => _pinValid && _pinsMatch;

  String? get _mismatchError {
    final String confirm = _confirmController.text.trim();
    if (confirm.length == 4 && !_pinsMatch) return 'PINs don\'t match';
    return null;
  }

  _PinStrength get _pinStrength {
    final String p = _pinController.text.trim();
    if (p.length < 4) return _PinStrength.none;
    // Weak: all same digit or sequential
    if (RegExp(r'^(.)\1{3}$').hasMatch(p)) return _PinStrength.weak;
    if (p == '1234' || p == '0000' || p == '1111') return _PinStrength.weak;
    return _PinStrength.strong;
  }

  Future<void> _finishSetup() async {
    if (!_canSubmit || _isSaving) return;
    setState(() => _isSaving = true);

    try {
      final regState = context.read<RegistrationState>();
      final phone = regState.phoneNumber ?? '08012345678';
      final otp = regState.otpCode ?? '123456';
      final pinVal = _pinController.text.trim();

      await context.read<ApiService>().setPin(
        phoneNumber: phone,
        otpCode: otp,
        pin: pinVal,
      );

      if (mounted) {
        context.go('/home');
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
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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

                      // Back + step
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
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Lock icon
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppColors.accentSoft,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.lock_rounded,
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
                        'Create your PIN',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.4,
                        ),
                      ).animate().fadeIn(delay: 80.ms),

                      const SizedBox(height: 6),

                      const Text(
                        'You\'ll use this 4-digit PIN to authorise every transaction.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ).animate().fadeIn(delay: 120.ms),

                      const SizedBox(height: 28),

                      // PIN dot indicators
                      _PinDots(
                        length: _pinController.text.length,
                        total: 4,
                        isValid: _pinValid,
                      ).animate().fadeIn(delay: 150.ms),

                      const SizedBox(height: 16),

                      // PIN input field
                      _PinField(
                        controller: _pinController,
                        label: 'PIN',
                        visible: _pinVisible,
                        onToggleVisible: () =>
                            setState(() => _pinVisible = !_pinVisible),
                        onChanged: (_) => setState(() {}),
                      ).animate().fadeIn(delay: 170.ms),

                      // Strength indicator
                      if (_pinController.text.length == 4)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: _StrengthRow(strength: _pinStrength),
                        ).animate().fadeIn(duration: 200.ms),

                      const SizedBox(height: 14),

                      // Confirm PIN dot indicators
                      _PinDots(
                        length: _confirmController.text.length,
                        total: 4,
                        isValid: _canSubmit,
                        hasError: _mismatchError != null,
                      ).animate().fadeIn(delay: 200.ms),

                      const SizedBox(height: 16),

                      // Confirm input
                      _PinField(
                        controller: _confirmController,
                        label: 'Confirm PIN',
                        visible: _confirmVisible,
                        onToggleVisible: () =>
                            setState(() => _confirmVisible = !_confirmVisible),
                        onChanged: (_) => setState(() {}),
                        errorText: _mismatchError,
                      ).animate().fadeIn(delay: 220.ms),

                      const SizedBox(height: 32),

                      PrimaryButton(
                        label: 'Finish Setup',
                        onPressed: _isSaving || !_canSubmit
                            ? null
                            : _finishSetup,
                        isLoading: _isSaving,
                        leading: (_isSaving || !_canSubmit)
                            ? null
                            : const Icon(Icons.check_rounded, size: 18),
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

// ── PIN dot indicator ────────────────────────────────────────────────────────

class _PinDots extends StatelessWidget {
  const _PinDots({
    required this.length,
    required this.total,
    this.isValid = false,
    this.hasError = false,
  });

  final int length;
  final int total;
  final bool isValid;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (i) {
        final bool filled = i < length;
        Color color;
        if (filled && isValid) {
          color = const Color(0xFF0F7A50);
        } else if (hasError && filled) {
          color = const Color(0xFFD03040);
        } else if (filled) {
          color = AppColors.accent;
        } else {
          color = AppColors.outline.withValues(alpha: 0.35);
        }

        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.only(right: 10),
          width: filled ? 14 : 12,
          height: filled ? 14 : 12,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        );
      }),
    );
  }
}

// ── PIN field ─────────────────────────────────────────────────────────────────

class _PinField extends StatefulWidget {
  const _PinField({
    required this.controller,
    required this.label,
    required this.visible,
    required this.onToggleVisible,
    required this.onChanged,
    this.errorText,
  });

  final TextEditingController controller;
  final String label;
  final bool visible;
  final VoidCallback onToggleVisible;
  final ValueChanged<String> onChanged;
  final String? errorText;

  @override
  State<_PinField> createState() => _PinFieldState();
}

class _PinFieldState extends State<_PinField> {
  final FocusNode _focus = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() => _isFocused = _focus.hasFocus));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool hasError = widget.errorText != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: hasError
                  ? const Color(0xFFD03040)
                  : _isFocused
                  ? AppColors.accent
                  : AppColors.outline.withValues(alpha: 0.4),
              width: _isFocused ? 1.5 : 1,
            ),
            boxShadow: _isFocused
                ? <BoxShadow>[
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focus,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  obscureText: !widget.visible,
                  maxLength: 4,
                  onChanged: widget.onChanged,
                  style: TextStyle(
                    fontSize: widget.visible ? 22 : 28,
                    fontWeight: FontWeight.w700,
                    letterSpacing: widget.visible ? 4 : 8,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    counterText: '',
                    labelText: widget.label,
                    labelStyle: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    contentPadding: const EdgeInsets.fromLTRB(16, 20, 0, 14),
                    hintText: '••••',
                    hintStyle: const TextStyle(
                      fontSize: 22,
                      letterSpacing: 8,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: widget.onToggleVisible,
                icon: Icon(
                  widget.visible
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                  color: AppColors.textSecondary,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(left: 4, top: 6),
            child: Row(
              children: <Widget>[
                const Icon(
                  Icons.error_outline_rounded,
                  size: 12,
                  color: Color(0xFFD03040),
                ),
                const SizedBox(width: 4),
                Text(
                  widget.errorText!,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFFD03040),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// ── PIN strength row ──────────────────────────────────────────────────────────

enum _PinStrength { none, weak, strong }

class _StrengthRow extends StatelessWidget {
  const _StrengthRow({required this.strength});
  final _PinStrength strength;

  @override
  Widget build(BuildContext context) {
    final bool isStrong = strength == _PinStrength.strong;
    return Row(
      children: <Widget>[
        Icon(
          isStrong ? Icons.shield_rounded : Icons.warning_amber_rounded,
          size: 12,
          color: isStrong ? const Color(0xFF0F7A50) : const Color(0xFFD4A017),
        ),
        const SizedBox(width: 5),
        Text(
          isStrong ? 'Strong PIN' : 'Weak PIN — avoid repeating digits',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isStrong ? const Color(0xFF0F7A50) : const Color(0xFFD4A017),
          ),
        ),
      ],
    );
  }
}
