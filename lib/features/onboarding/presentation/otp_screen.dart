import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/token_service.dart';
import '../../../../core/state/registration_state.dart';
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
    if (!_canVerify || _isVerifying) return;
    setState(() => _isVerifying = true);

    try {
      final regState = context.read<RegistrationState>();
      final phone = regState.phoneNumber ?? '';
      final otp = _otpController.text.trim();
      final apiService = context.read<ApiService>();
      final tokenService = context.read<TokenService>();

      final response = await apiService.register(
        phoneNumber: phone,
        otpCode: otp,
        firstName: 'Demo',
        lastName: 'User',
      );

      regState.setOtpCode(otp);

      final token = response['data']?['token'] as String?;
      if (token != null && token.isNotEmpty) {
        await tokenService.saveToken(token);
      }

      if (mounted) {
        context.go('/bvn');
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
        setState(() => _isVerifying = false);
      }
    }
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

                      Builder(
                        builder: (context) {
                          final phone = context.watch<RegistrationState>().phoneNumber ?? '';
                          final displayPhone = phone.length >= 11
                              ? '${phone.substring(0, 4)} *** *${phone.substring(7)}'
                              : phone;
                          return RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                                height: 1.5,
                              ),
                              children: <InlineSpan>[
                                const TextSpan(text: 'Code sent to '),
                                TextSpan(
                                  text: displayPhone,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
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
                                ),
                                child: Center(
                                  child: Text(
                                    filled ? raw[i] : '',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                          // Hidden text field overlay
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
                                 onTap: () async {
                                   _otpController.clear();
                                   setState(() {});
                                   _startResendTimer();
                                   try {
                                     final regState = context.read<RegistrationState>();
                                     final apiService = context.read<ApiService>();
                                     final phone = regState.phoneNumber ?? '';
                                     if (phone.isNotEmpty) {
                                       await apiService.sendRegistrationOtp(phone);
                                     }
                                   } catch (e) {
                                     if (context.mounted) {
                                       ScaffoldMessenger.of(context).showSnackBar(
                                         SnackBar(
                                           content: Text(e.toString().replaceAll('Exception: ', '')),
                                           backgroundColor: AppColors.error,
                                         ),
                                       );
                                     }
                                   }
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
