import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/demo_device_shell.dart';
import '../../../../shared/widgets/primary_button.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  late final TextEditingController _otpController;
  bool _isVerifying = false;
  int _resendSeconds = 30;
  Timer? _resendTimer;

  @override
  void initState() {
    super.initState();
    _otpController = TextEditingController();
    _startResendTimer();
  }

  @override
  void dispose() {
    _otpController.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    setState(() => _resendSeconds = 30);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        _resendSeconds--;
        if (_resendSeconds <= 0) t.cancel();
      });
    });
  }

  bool get _canVerify =>
      RegExp(r'^\d{6}$').hasMatch(_otpController.text.trim());

  Future<void> _verifyOtp() async {
    if (!_canVerify) return;
    setState(() => _isVerifying = true);
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    context.go('/bvn');
  }

  @override
  Widget build(BuildContext context) {
    final String raw = _otpController.text;

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

                      // Back + step row
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
                          _StepPills(current: 2, total: 5),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Icon badge
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppColors.accentSoft,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.mark_email_read_rounded,
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
                        'Enter OTP',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.4,
                        ),
                      ).animate().fadeIn(delay: 80.ms),

                      const SizedBox(height: 6),

                      RichText(
                        text: const TextSpan(
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                          children: <InlineSpan>[
                            TextSpan(text: 'Code sent to '),
                            TextSpan(
                              text: '+234 *** **** **78',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 120.ms),

                      const SizedBox(height: 28),

                      // OTP digit boxes (visual) backed by hidden field
                      Stack(
                        children: <Widget>[
                          // Visible digit boxes
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(6, (i) {
                              final bool filled = i < raw.length;
                              final bool active = i == raw.length;
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                width: 44,
                                height: 54,
                                decoration: BoxDecoration(
                                  color: filled
                                      ? AppColors.accentSoft
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: active
                                        ? AppColors.accent
                                        : filled
                                        ? AppColors.accent.withValues(
                                            alpha: 0.5,
                                          )
                                        : AppColors.outline.withValues(
                                            alpha: 0.4,
                                          ),
                                    width: active ? 2 : 1,
                                  ),
                                  boxShadow: active
                                      ? <BoxShadow>[
                                          BoxShadow(
                                            color: AppColors.accent.withValues(
                                              alpha: 0.12,
                                            ),
                                            blurRadius: 8,
                                            offset: const Offset(0, 3),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Center(
                                  child: filled
                                      ? Text(
                                          raw[i],
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.accent,
                                          ),
                                        )
                                      : active
                                      ? Container(
                                          width: 2,
                                          height: 20,
                                          color: AppColors.accent,
                                        )
                                      : null,
                                ),
                              );
                            }),
                          ),
                          // Invisible full-width text field that captures input
                          Positioned.fill(
                            child: Opacity(
                              opacity: 0,
                              child: TextField(
                                controller: _otpController,
                                keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                maxLength: 6,
                                autofocus: true,
                                onChanged: (_) => setState(() {}),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  counterText: '',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ).animate().fadeIn(delay: 150.ms, duration: 300.ms),

                      const SizedBox(height: 20),

                      // Resend row
                      Center(
                        child: _resendSeconds > 0
                            ? Text(
                                'Resend code in ${_resendSeconds}s',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              )
                            : GestureDetector(
                                onTap: () {
                                  _otpController.clear();
                                  setState(() {});
                                  _startResendTimer();
                                },
                                child: const Text(
                                  'Resend OTP',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.accent,
                                  ),
                                ),
                              ),
                      ).animate().fadeIn(delay: 200.ms),

                      const SizedBox(height: 32),

                      PrimaryButton(
                        label: 'Verify OTP',
                        onPressed: _isVerifying || !_canVerify
                            ? null
                            : _verifyOtp,
                        isLoading: _isVerifying,
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
