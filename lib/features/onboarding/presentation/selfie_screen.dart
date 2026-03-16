import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/demo_device_shell.dart';
import '../../../../shared/widgets/primary_button.dart';

class SelfieScreen extends StatefulWidget {
  const SelfieScreen({super.key});

  @override
  State<SelfieScreen> createState() => _SelfieScreenState();
}

class _SelfieScreenState extends State<SelfieScreen>
    with SingleTickerProviderStateMixin {
  bool _isProcessing = false;
  bool _isCapturing = false;
  late final AnimationController _scanController;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  Future<void> _captureAndVerify() async {
    setState(() => _isCapturing = true);
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    setState(() {
      _isCapturing = false;
      _isProcessing = true;
    });
    await Future<void>.delayed(const Duration(milliseconds: 1600));
    if (!mounted) return;
    context.go('/account-created');
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(height: 16),

                  // Header row
                  Row(
                    children: <Widget>[
                      GestureDetector(
                        onTap: (_isProcessing || _isCapturing)
                            ? null
                            : () => Navigator.of(context).maybePop(),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppColors.outline.withValues(alpha: 0.4),
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
                      _StepPills(current: 4, total: 5),
                    ],
                  ),

                  const SizedBox(height: 20),

                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _isProcessing
                        ? Column(
                            key: const ValueKey('processing'),
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              const Text(
                                'Analyzing selfie…',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Hold still while we verify your identity.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          )
                        : Column(
                            key: const ValueKey('capture'),
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              const Text(
                                'Selfie verification',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Position your face in the frame and tap Capture.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                  ),

                  const SizedBox(height: 20),

                  // Camera frame
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        color: const Color(0xFF1A1D2E),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Stack(
                          alignment: Alignment.center,
                          children: <Widget>[
                            // Subtle gradient bg simulating low light
                            Container(
                              decoration: const BoxDecoration(
                                gradient: RadialGradient(
                                  center: Alignment.center,
                                  radius: 0.8,
                                  colors: <Color>[
                                    Color(0xFF2A2D42),
                                    Color(0xFF0F1120),
                                  ],
                                ),
                              ),
                            ),

                            // Oval face guide
                            AnimatedBuilder(
                              animation: _scanController,
                              builder: (context, child) {
                                return CustomPaint(
                                  painter: _OvalGuidePainter(
                                    progress: _scanController.value,
                                    isProcessing: _isProcessing,
                                  ),
                                  child: const SizedBox(
                                    width: 180,
                                    height: 220,
                                  ),
                                );
                              },
                            ),

                            // Face icon in centre
                            Icon(
                              _isProcessing
                                  ? Icons.face_retouching_natural_rounded
                                  : Icons.person_rounded,
                              size: 80,
                              color: Colors.white.withValues(alpha: 0.15),
                            ),

                            // Processing overlay
                            if (_isProcessing)
                              Positioned(
                                bottom: 20,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.6),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      SizedBox(
                                        width: 12,
                                        height: 12,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 1.5,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                AppColors.accent,
                                              ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'Matching face…',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                            // Corner brackets
                            ..._corners(),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
                  ),

                  const SizedBox(height: 16),

                  // Tips row
                  if (!_isProcessing)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        _Tip(
                          icon: Icons.wb_sunny_outlined,
                          label: 'Good light',
                        ),
                        const SizedBox(width: 16),
                        _Tip(icon: Icons.face_outlined, label: 'Face centered'),
                        const SizedBox(width: 16),
                        _Tip(
                          icon: Icons.remove_red_eye_rounded,
                          label: 'Remove glasses',
                        ),
                      ],
                    ).animate().fadeIn(delay: 200.ms),

                  const SizedBox(height: 14),

                  PrimaryButton(
                    label: _isCapturing
                        ? 'Focusing…'
                        : _isProcessing
                        ? 'Verifying…'
                        : 'Capture Selfie',
                    onPressed: (_isProcessing || _isCapturing)
                        ? null
                        : _captureAndVerify,
                    isLoading: _isProcessing || _isCapturing,
                    leading: (_isProcessing || _isCapturing)
                        ? null
                        : const Icon(Icons.camera_alt_rounded, size: 18),
                  ).animate().fadeIn(delay: 220.ms),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _corners() {
    const double size = 20;
    const double stroke = 2.5;
    const Color color = AppColors.accent;

    Widget corner(
      double top,
      double bottom,
      double left,
      double right, {
      required bool flipX,
      required bool flipY,
    }) {
      return Positioned(
        top: top == -1 ? null : top,
        bottom: bottom == -1 ? null : bottom,
        left: left == -1 ? null : left,
        right: right == -1 ? null : right,
        child: Transform.scale(
          scaleX: flipX ? -1 : 1,
          scaleY: flipY ? -1 : 1,
          child: SizedBox(
            width: size,
            height: size,
            child: CustomPaint(
              painter: _CornerPainter(color: color, stroke: stroke),
            ),
          ),
        ),
      );
    }

    return <Widget>[
      corner(16, -1, 16, -1, flipX: false, flipY: false),
      corner(16, -1, -1, 16, flipX: true, flipY: false),
      corner(-1, 16, 16, -1, flipX: false, flipY: true),
      corner(-1, 16, -1, 16, flipX: true, flipY: true),
    ];
  }
}

class _OvalGuidePainter extends CustomPainter {
  _OvalGuidePainter({required this.progress, required this.isProcessing});
  final double progress;
  final bool isProcessing;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final Paint borderPaint = Paint()
      ..color = isProcessing
          ? AppColors.accent.withValues(alpha: 0.9)
          : Colors.white.withValues(alpha: 0.4 + progress * 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawOval(rect, borderPaint);

    if (isProcessing) {
      // Animated scan line
      final double y = size.height * progress;
      final Paint scanPaint = Paint()
        ..shader = LinearGradient(
          colors: <Color>[
            AppColors.accent.withValues(alpha: 0),
            AppColors.accent.withValues(alpha: 0.6),
            AppColors.accent.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromLTWH(0, y - 10, size.width, 20));
      canvas.drawRect(Rect.fromLTWH(0, y - 8, size.width, 16), scanPaint);
    }
  }

  @override
  bool shouldRepaint(_OvalGuidePainter old) =>
      old.progress != progress || old.isProcessing != isProcessing;
}

class _CornerPainter extends CustomPainter {
  _CornerPainter({required this.color, required this.stroke});
  final Color color;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint p = Paint()
      ..color = color
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(0, size.height), const Offset(0, 0), p);
    canvas.drawLine(const Offset(0, 0), Offset(size.width, 0), p);
  }

  @override
  bool shouldRepaint(_CornerPainter old) => false;
}

class _Tip extends StatelessWidget {
  const _Tip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
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
