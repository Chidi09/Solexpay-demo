import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

// ---------------------------------------------------------------------------
// Scene enum — add more as needed
// ---------------------------------------------------------------------------
enum IllustrationScene {
  welcome, // person holding phone, geometric bg shapes
  success, // person celebrating / checkmark scene
  savings, // person watering a money plant
  receive, // person with open hands / QR card
  empty, // person shrugging / empty box
  promoRelax, // person lounging with laptop on yellow background
}

// ---------------------------------------------------------------------------
// Public widget — drop anywhere
// ---------------------------------------------------------------------------
class FlatIllustration extends StatelessWidget {
  const FlatIllustration({
    super.key,
    required this.scene,
    this.width = 220,
    this.height = 180,
  });

  final IllustrationScene scene;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(painter: _IllustrationPainter(scene: scene)),
    );
  }
}

// ---------------------------------------------------------------------------
// Painter dispatcher
// ---------------------------------------------------------------------------
class _IllustrationPainter extends CustomPainter {
  const _IllustrationPainter({required this.scene});
  final IllustrationScene scene;

  @override
  void paint(Canvas canvas, Size size) {
    switch (scene) {
      case IllustrationScene.welcome:
        _paintWelcome(canvas, size);
      case IllustrationScene.success:
        _paintSuccess(canvas, size);
      case IllustrationScene.savings:
        _paintSavings(canvas, size);
      case IllustrationScene.receive:
        _paintReceive(canvas, size);
      case IllustrationScene.empty:
        _paintEmpty(canvas, size);
      case IllustrationScene.promoRelax:
        _paintPromoRelax(canvas, size);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;

  // ── Colour palette (flat illustration palette from reference) ─────────────
  static const Color _mint = Color(0xFFB8EDD9); // soft mint bg blob
  static const Color _green = Color(0xFF19B37D); // accent green
  static const Color _darkGreen = Color(0xFF0F4C3A); // deep green
  static const Color _skin = Color(0xFF8B5E3C); // face/hands
  static const Color _skinLight = Color(0xFFBE8A6A); // lighter skin tone
  static const Color _orange = Color(0xFFE8845C); // earthy orange
  static const Color _yellow = Color(0xFFF5C842); // warm yellow
  static const Color _purple = Color(0xFF8B6FD4); // soft purple
  static const Color _white = Color(0xFFFFFFFF);
  static const Color _near = Color(0xFF102033); // near-black for outlines
  static const Color _bgBlob = Color(0xFFDFF7EE); // lightest mint
  static const Color _red = Color(0xFFE55A4E); // coral red

  Paint _fill(Color c) => Paint()
    ..color = c
    ..style = PaintingStyle.fill;
  Paint _stroke(Color c, double w) => Paint()
    ..color = c
    ..style = PaintingStyle.stroke
    ..strokeWidth = w
    ..strokeCap = StrokeCap.round;

  // ── SCENE: Welcome — person holding a glowing phone ───────────────────────
  void _paintWelcome(Canvas canvas, Size s) {
    final double w = s.width, h = s.height;

    // Background blob (mint circle)
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.48),
        width: w * 0.88,
        height: h * 0.82,
      ),
      _fill(_bgBlob),
    );

    // Ground shadow
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.91),
        width: w * 0.55,
        height: h * 0.06,
      ),
      _fill(const Color(0x22000000)),
    );

    // Legs (dark trousers)
    _roundRect(
      canvas,
      Rect.fromLTWH(w * 0.35, h * 0.64, w * 0.12, h * 0.25),
      6,
      _fill(_near),
    );
    _roundRect(
      canvas,
      Rect.fromLTWH(w * 0.50, h * 0.64, w * 0.12, h * 0.25),
      6,
      _fill(_near),
    );

    // Shoes
    _roundRect(
      canvas,
      Rect.fromLTWH(w * 0.33, h * 0.87, w * 0.15, h * 0.07),
      5,
      _fill(const Color(0xFF1A1A2E)),
    );
    _roundRect(
      canvas,
      Rect.fromLTWH(w * 0.49, h * 0.87, w * 0.15, h * 0.07),
      5,
      _fill(const Color(0xFF1A1A2E)),
    );

    // Body (orange/terracotta top)
    final Path body = Path()
      ..moveTo(w * 0.32, h * 0.66)
      ..quadraticBezierTo(w * 0.3, h * 0.44, w * 0.5, h * 0.42)
      ..quadraticBezierTo(w * 0.7, h * 0.44, w * 0.68, h * 0.66)
      ..close();
    canvas.drawPath(body, _fill(_orange));

    // Left arm (stretched forward holding phone)
    final Path lArm = Path()
      ..moveTo(w * 0.32, h * 0.52)
      ..quadraticBezierTo(w * 0.15, h * 0.54, w * 0.18, h * 0.68)
      ..quadraticBezierTo(w * 0.22, h * 0.69, w * 0.34, h * 0.60)
      ..close();
    canvas.drawPath(lArm, _fill(_orange));

    // Right arm
    final Path rArm = Path()
      ..moveTo(w * 0.68, h * 0.52)
      ..quadraticBezierTo(w * 0.80, h * 0.50, w * 0.82, h * 0.62)
      ..quadraticBezierTo(w * 0.78, h * 0.65, w * 0.68, h * 0.60)
      ..close();
    canvas.drawPath(rArm, _fill(_orange));

    // Phone in left hand
    _roundRect(
      canvas,
      Rect.fromLTWH(w * 0.13, h * 0.60, w * 0.12, h * 0.19),
      5,
      _fill(_near),
    );
    _roundRect(
      canvas,
      Rect.fromLTWH(w * 0.145, h * 0.625, w * 0.09, h * 0.14),
      3,
      _fill(_green),
    );
    // Screen glow lines
    canvas.drawLine(
      Offset(w * 0.155, h * 0.66),
      Offset(w * 0.225, h * 0.66),
      _stroke(_white, 1.5),
    );
    canvas.drawLine(
      Offset(w * 0.155, h * 0.70),
      Offset(w * 0.225, h * 0.70),
      _stroke(_white, 1.5),
    );
    canvas.drawLine(
      Offset(w * 0.155, h * 0.74),
      Offset(w * 0.21, h * 0.74),
      _stroke(_white, 1.5),
    );

    // Neck
    _roundRect(
      canvas,
      Rect.fromLTWH(w * 0.455, h * 0.32, w * 0.09, h * 0.12),
      4,
      _fill(_skin),
    );

    // Head
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.25),
        width: w * 0.22,
        height: h * 0.24,
      ),
      _fill(_skin),
    );
    // Hair
    final Path hair = Path()
      ..moveTo(w * 0.38, h * 0.22)
      ..quadraticBezierTo(w * 0.40, h * 0.10, w * 0.5, h * 0.11)
      ..quadraticBezierTo(w * 0.62, h * 0.10, w * 0.62, h * 0.22)
      ..quadraticBezierTo(w * 0.60, h * 0.16, w * 0.5, h * 0.15)
      ..quadraticBezierTo(w * 0.40, h * 0.16, w * 0.38, h * 0.22)
      ..close();
    canvas.drawPath(hair, _fill(_near));

    // Eyes
    canvas.drawCircle(Offset(w * 0.46, h * 0.24), w * 0.018, _fill(_near));
    canvas.drawCircle(Offset(w * 0.54, h * 0.24), w * 0.018, _fill(_near));
    canvas.drawCircle(Offset(w * 0.462, h * 0.236), w * 0.007, _fill(_white));
    canvas.drawCircle(Offset(w * 0.542, h * 0.236), w * 0.007, _fill(_white));

    // Smile
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.285),
        width: w * 0.1,
        height: h * 0.06,
      ),
      0,
      math.pi,
      false,
      _stroke(_near, 1.8),
    );

    // Floating sparkles
    _drawSparkle(canvas, Offset(w * 0.78, h * 0.18), w * 0.025, _yellow);
    _drawSparkle(canvas, Offset(w * 0.82, h * 0.32), w * 0.018, _green);
    _drawSparkle(canvas, Offset(w * 0.22, h * 0.16), w * 0.022, _orange);

    // Coin badge (top right corner)
    canvas.drawCircle(Offset(w * 0.85, h * 0.12), w * 0.065, _fill(_yellow));
    canvas.drawCircle(
      Offset(w * 0.85, h * 0.12),
      w * 0.065,
      _stroke(_orange, 1.5),
    );
    canvas.drawLine(
      Offset(w * 0.85, h * 0.08),
      Offset(w * 0.85, h * 0.16),
      _stroke(_orange, 2),
    );
  }

  // ── SCENE: Success — person celebrating ────────────────────────────────────
  void _paintSuccess(Canvas canvas, Size s) {
    final double w = s.width, h = s.height;

    // Soft background circle
    canvas.drawCircle(Offset(w * 0.5, h * 0.48), w * 0.42, _fill(_bgBlob));

    // Confetti blobs
    final List<Offset> confetti = <Offset>[
      Offset(w * 0.15, h * 0.18),
      Offset(w * 0.82, h * 0.14),
      Offset(w * 0.88, h * 0.42),
      Offset(w * 0.10, h * 0.55),
      Offset(w * 0.70, h * 0.72),
      Offset(w * 0.25, h * 0.78),
    ];
    final List<Color> confettiColors = <Color>[
      _yellow,
      _orange,
      _purple,
      _green,
      _red,
      _mint,
    ];
    for (int i = 0; i < confetti.length; i++) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: confetti[i],
            width: w * 0.04,
            height: h * 0.025,
          ),
          const Radius.circular(3),
        ),
        _fill(confettiColors[i % confettiColors.length]),
      );
    }

    // Legs
    _roundRect(
      canvas,
      Rect.fromLTWH(w * 0.37, h * 0.63, w * 0.11, h * 0.22),
      5,
      _fill(_purple),
    );
    _roundRect(
      canvas,
      Rect.fromLTWH(w * 0.52, h * 0.63, w * 0.11, h * 0.22),
      5,
      _fill(_purple),
    );

    // Shoes
    _roundRect(
      canvas,
      Rect.fromLTWH(w * 0.34, h * 0.83, w * 0.16, h * 0.06),
      4,
      _fill(_near),
    );
    _roundRect(
      canvas,
      Rect.fromLTWH(w * 0.50, h * 0.83, w * 0.16, h * 0.06),
      4,
      _fill(_near),
    );

    // Body
    final Path body = Path()
      ..moveTo(w * 0.34, h * 0.64)
      ..quadraticBezierTo(w * 0.30, h * 0.44, w * 0.5, h * 0.40)
      ..quadraticBezierTo(w * 0.70, h * 0.44, w * 0.66, h * 0.64)
      ..close();
    canvas.drawPath(body, _fill(_green));

    // Arms up (celebrating)
    final Path lArm = Path()
      ..moveTo(w * 0.34, h * 0.50)
      ..quadraticBezierTo(w * 0.16, h * 0.42, w * 0.18, h * 0.28)
      ..quadraticBezierTo(w * 0.24, h * 0.24, w * 0.38, h * 0.46)
      ..close();
    canvas.drawPath(lArm, _fill(_green));

    final Path rArm = Path()
      ..moveTo(w * 0.66, h * 0.50)
      ..quadraticBezierTo(w * 0.84, h * 0.42, w * 0.82, h * 0.28)
      ..quadraticBezierTo(w * 0.76, h * 0.24, w * 0.62, h * 0.46)
      ..close();
    canvas.drawPath(rArm, _fill(_green));

    // Hands (open)
    canvas.drawCircle(Offset(w * 0.20, h * 0.26), w * 0.045, _fill(_skinLight));
    canvas.drawCircle(Offset(w * 0.80, h * 0.26), w * 0.045, _fill(_skinLight));

    // Neck
    _roundRect(
      canvas,
      Rect.fromLTWH(w * 0.455, h * 0.30, w * 0.09, h * 0.12),
      4,
      _fill(_skinLight),
    );

    // Head
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.23),
        width: w * 0.22,
        height: h * 0.22,
      ),
      _fill(_skinLight),
    );
    // Hair (afro)
    canvas.drawCircle(Offset(w * 0.5, h * 0.19), w * 0.13, _fill(_near));
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.23),
        width: w * 0.18,
        height: h * 0.18,
      ),
      _fill(_skinLight),
    );

    // Big smile
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.265),
        width: w * 0.12,
        height: h * 0.08,
      ),
      0,
      math.pi,
      false,
      _stroke(_near, 2),
    );
    // Eyes (happy arcs)
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(w * 0.455, h * 0.22),
        width: w * 0.06,
        height: h * 0.04,
      ),
      math.pi,
      math.pi,
      false,
      _stroke(_near, 2),
    );
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(w * 0.545, h * 0.22),
        width: w * 0.06,
        height: h * 0.04,
      ),
      math.pi,
      math.pi,
      false,
      _stroke(_near, 2),
    );

    // Big checkmark badge
    canvas.drawCircle(Offset(w * 0.5, h * 0.92), w * 0.1, _fill(_green));
    final Path check = Path()
      ..moveTo(w * 0.44, h * 0.92)
      ..lineTo(w * 0.48, h * 0.96)
      ..lineTo(w * 0.56, h * 0.88);
    canvas.drawPath(check, _stroke(_white, 3));
  }

  // ── SCENE: Savings — person watering a money plant ─────────────────────────
  void _paintSavings(Canvas canvas, Size s) {
    final double w = s.width, h = s.height;

    // Background blob
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.5),
        width: w * 0.9,
        height: h * 0.8,
      ),
      _fill(_bgBlob),
    );

    // Pot
    final Path pot = Path()
      ..moveTo(w * 0.55, h * 0.78)
      ..lineTo(w * 0.50, h * 0.94)
      ..lineTo(w * 0.72, h * 0.94)
      ..lineTo(w * 0.67, h * 0.78)
      ..close();
    canvas.drawPath(pot, _fill(_orange));
    _roundRect(
      canvas,
      Rect.fromLTWH(w * 0.48, h * 0.75, w * 0.21, h * 0.06),
      3,
      _fill(_red),
    );

    // Soil
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.61, h * 0.77),
        width: w * 0.20,
        height: h * 0.05,
      ),
      _fill(_darkGreen),
    );

    // Plant stem
    canvas.drawLine(
      Offset(w * 0.61, h * 0.76),
      Offset(w * 0.61, h * 0.48),
      _stroke(_darkGreen, 3),
    );
    canvas.drawLine(
      Offset(w * 0.61, h * 0.60),
      Offset(w * 0.72, h * 0.52),
      _stroke(_darkGreen, 2.5),
    );
    canvas.drawLine(
      Offset(w * 0.61, h * 0.54),
      Offset(w * 0.50, h * 0.46),
      _stroke(_darkGreen, 2.5),
    );

    // Leaves
    _drawLeaf(
      canvas,
      Offset(w * 0.72, h * 0.52),
      w * 0.1,
      h * 0.08,
      -0.4,
      _green,
    );
    _drawLeaf(
      canvas,
      Offset(w * 0.50, h * 0.46),
      w * 0.1,
      h * 0.08,
      2.8,
      _mint,
    );
    // Coin on top of plant
    canvas.drawCircle(Offset(w * 0.61, h * 0.45), w * 0.048, _fill(_yellow));
    canvas.drawLine(
      Offset(w * 0.61, h * 0.42),
      Offset(w * 0.61, h * 0.48),
      _stroke(_orange, 1.8),
    );

    // Ground
    canvas.drawLine(
      Offset(w * 0.0, h * 0.93),
      Offset(w, h * 0.93),
      _stroke(AppColors.outline, 1),
    );

    // Person standing watering
    // Legs
    _roundRect(
      canvas,
      Rect.fromLTWH(w * 0.18, h * 0.65, w * 0.10, h * 0.26),
      5,
      _fill(_purple),
    );
    _roundRect(
      canvas,
      Rect.fromLTWH(w * 0.30, h * 0.65, w * 0.10, h * 0.26),
      5,
      _fill(_purple),
    );
    // Shoes
    _roundRect(
      canvas,
      Rect.fromLTWH(w * 0.16, h * 0.89, w * 0.14, h * 0.055),
      4,
      _fill(_near),
    );
    _roundRect(
      canvas,
      Rect.fromLTWH(w * 0.29, h * 0.89, w * 0.14, h * 0.055),
      4,
      _fill(_near),
    );
    // Body
    final Path personBody = Path()
      ..moveTo(w * 0.16, h * 0.67)
      ..quadraticBezierTo(w * 0.14, h * 0.46, w * 0.29, h * 0.43)
      ..quadraticBezierTo(w * 0.44, h * 0.46, w * 0.42, h * 0.67)
      ..close();
    canvas.drawPath(personBody, _fill(_orange));
    // Arm reaching to water
    final Path armReach = Path()
      ..moveTo(w * 0.42, h * 0.52)
      ..quadraticBezierTo(w * 0.54, h * 0.48, w * 0.56, h * 0.60)
      ..quadraticBezierTo(w * 0.52, h * 0.64, w * 0.42, h * 0.58)
      ..close();
    canvas.drawPath(armReach, _fill(_orange));
    // Watering can
    _roundRect(
      canvas,
      Rect.fromLTWH(w * 0.53, h * 0.56, w * 0.10, h * 0.09),
      4,
      _fill(_red),
    );
    canvas.drawLine(
      Offset(w * 0.63, h * 0.60),
      Offset(w * 0.70, h * 0.56),
      _stroke(_red, 3),
    );
    // Water drops
    for (int i = 0; i < 3; i++) {
      canvas.drawCircle(
        Offset(w * (0.68 + i * 0.03), h * (0.58 + i * 0.04)),
        w * 0.012,
        _fill(_mint),
      );
    }
    // Other arm (back)
    _roundRect(
      canvas,
      Rect.fromLTWH(w * 0.13, h * 0.50, w * 0.07, h * 0.18),
      4,
      _fill(const Color(0xFFCC6644)),
    );
    // Neck
    _roundRect(
      canvas,
      Rect.fromLTWH(w * 0.27, h * 0.33, w * 0.08, h * 0.12),
      4,
      _fill(_skin),
    );
    // Head
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.30, h * 0.26),
        width: w * 0.20,
        height: h * 0.22,
      ),
      _fill(_skin),
    );
    // Hair
    final Path hair2 = Path()
      ..moveTo(w * 0.20, h * 0.22)
      ..quadraticBezierTo(w * 0.22, h * 0.12, w * 0.30, h * 0.13)
      ..quadraticBezierTo(w * 0.40, h * 0.12, w * 0.40, h * 0.22)
      ..quadraticBezierTo(w * 0.36, h * 0.16, w * 0.30, h * 0.16)
      ..quadraticBezierTo(w * 0.24, h * 0.16, w * 0.20, h * 0.22)
      ..close();
    canvas.drawPath(hair2, _fill(_near));
    // Eye (side profile visible)
    canvas.drawCircle(Offset(w * 0.33, h * 0.25), w * 0.016, _fill(_near));
    // Smile
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(w * 0.32, h * 0.30),
        width: w * 0.08,
        height: h * 0.05,
      ),
      0,
      math.pi,
      false,
      _stroke(_near, 1.5),
    );

    // Floating stars
    _drawSparkle(canvas, Offset(w * 0.76, h * 0.22), w * 0.022, _yellow);
    _drawSparkle(canvas, Offset(w * 0.84, h * 0.38), w * 0.016, _green);
  }

  // ── SCENE: Receive — person holding a QR card ─────────────────────────────
  void _paintReceive(Canvas canvas, Size s) {
    final double w = s.width, h = s.height;

    // Background blob
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.48),
        width: w * 0.88,
        height: h * 0.80,
      ),
      _fill(_bgBlob),
    );

    // Legs
    _roundRect(
      canvas,
      Rect.fromLTWH(w * 0.36, h * 0.64, w * 0.11, h * 0.24),
      5,
      _fill(_near),
    );
    _roundRect(
      canvas,
      Rect.fromLTWH(w * 0.51, h * 0.64, w * 0.11, h * 0.24),
      5,
      _fill(_near),
    );
    _roundRect(
      canvas,
      Rect.fromLTWH(w * 0.34, h * 0.86, w * 0.14, h * 0.055),
      4,
      _fill(const Color(0xFF1A1A2E)),
    );
    _roundRect(
      canvas,
      Rect.fromLTWH(w * 0.50, h * 0.86, w * 0.14, h * 0.055),
      4,
      _fill(const Color(0xFF1A1A2E)),
    );

    // Body (green top)
    final Path body = Path()
      ..moveTo(w * 0.33, h * 0.65)
      ..quadraticBezierTo(w * 0.30, h * 0.44, w * 0.5, h * 0.41)
      ..quadraticBezierTo(w * 0.70, h * 0.44, w * 0.67, h * 0.65)
      ..close();
    canvas.drawPath(body, _fill(_green));

    // Both arms extended forward presenting the card
    final Path lArm = Path()
      ..moveTo(w * 0.33, h * 0.52)
      ..quadraticBezierTo(w * 0.22, h * 0.54, w * 0.24, h * 0.68)
      ..quadraticBezierTo(w * 0.28, h * 0.70, w * 0.36, h * 0.60)
      ..close();
    canvas.drawPath(lArm, _fill(_green));
    final Path rArm = Path()
      ..moveTo(w * 0.67, h * 0.52)
      ..quadraticBezierTo(w * 0.78, h * 0.54, w * 0.76, h * 0.68)
      ..quadraticBezierTo(w * 0.72, h * 0.70, w * 0.64, h * 0.60)
      ..close();
    canvas.drawPath(rArm, _fill(_green));

    // QR-card (held out)
    _roundRect(
      canvas,
      Rect.fromLTWH(w * 0.30, h * 0.60, w * 0.40, h * 0.28),
      10,
      _fill(_white),
    );
    _roundRect(
      canvas,
      Rect.fromLTWH(w * 0.30, h * 0.60, w * 0.40, h * 0.28),
      10,
      Paint()
        ..color = AppColors.outline
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    // QR code pattern (abstract)
    final double qx = w * 0.335, qy = h * 0.625, qcell = w * 0.045;
    final List<List<int>> qr = <List<int>>[
      <int>[1, 1, 0, 1, 1],
      <int>[1, 0, 0, 0, 1],
      <int>[0, 1, 1, 1, 0],
      <int>[1, 0, 0, 1, 1],
      <int>[1, 1, 0, 1, 1],
    ];
    for (int row = 0; row < 5; row++) {
      for (int col = 0; col < 5; col++) {
        if (qr[row][col] == 1) {
          _roundRect(
            canvas,
            Rect.fromLTWH(
              qx + col * qcell,
              qy + row * qcell * 0.85,
              qcell * 0.75,
              qcell * 0.75,
            ),
            2,
            _fill(_near),
          );
        }
      }
    }

    // "SolexPay" text area (orange rectangle)
    _roundRect(
      canvas,
      Rect.fromLTWH(w * 0.565, h * 0.625, w * 0.12, h * 0.12),
      4,
      _fill(_mint),
    );
    canvas.drawLine(
      Offset(w * 0.570, h * 0.64),
      Offset(w * 0.680, h * 0.64),
      _stroke(_green, 1.5),
    );
    canvas.drawLine(
      Offset(w * 0.570, h * 0.66),
      Offset(w * 0.680, h * 0.66),
      _stroke(_green, 1.5),
    );
    canvas.drawLine(
      Offset(w * 0.570, h * 0.68),
      Offset(w * 0.660, h * 0.68),
      _stroke(_green, 1.5),
    );

    // Amount text line
    canvas.drawLine(
      Offset(w * 0.335, h * 0.81),
      Offset(w * 0.665, h * 0.81),
      _stroke(AppColors.outline, 1),
    );
    _roundRect(
      canvas,
      Rect.fromLTWH(w * 0.42, h * 0.83, w * 0.16, h * 0.025),
      3,
      _fill(_mint),
    );

    // Neck + Head
    _roundRect(
      canvas,
      Rect.fromLTWH(w * 0.455, h * 0.31, w * 0.09, h * 0.12),
      4,
      _fill(_skinLight),
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.24),
        width: w * 0.22,
        height: h * 0.22,
      ),
      _fill(_skinLight),
    );
    // Hair
    canvas.drawCircle(Offset(w * 0.5, h * 0.20), w * 0.12, _fill(_near));
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.24),
        width: w * 0.17,
        height: h * 0.17,
      ),
      _fill(_skinLight),
    );
    // Eyes
    canvas.drawCircle(Offset(w * 0.46, h * 0.23), w * 0.017, _fill(_near));
    canvas.drawCircle(Offset(w * 0.54, h * 0.23), w * 0.017, _fill(_near));
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.275),
        width: w * 0.10,
        height: h * 0.055,
      ),
      0,
      math.pi,
      false,
      _stroke(_near, 1.5),
    );

    // Sparkles
    _drawSparkle(canvas, Offset(w * 0.14, h * 0.22), w * 0.022, _yellow);
    _drawSparkle(canvas, Offset(w * 0.86, h * 0.20), w * 0.020, _orange);
  }

  // ── SCENE: Empty state ─────────────────────────────────────────────────────
  void _paintEmpty(Canvas canvas, Size s) {
    final double w = s.width, h = s.height;

    // Background blob
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.48),
        width: w * 0.80,
        height: h * 0.72,
      ),
      _fill(_bgBlob),
    );

    // Box
    _roundRect(
      canvas,
      Rect.fromLTWH(w * 0.28, h * 0.40, w * 0.44, h * 0.40),
      8,
      _fill(_white),
    );
    _roundRect(
      canvas,
      Rect.fromLTWH(w * 0.28, h * 0.40, w * 0.44, h * 0.40),
      8,
      Paint()
        ..color = AppColors.outline
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    // Box flaps
    canvas.drawLine(
      Offset(w * 0.28, h * 0.50),
      Offset(w * 0.50, h * 0.46),
      _stroke(AppColors.outline, 1.5),
    );
    canvas.drawLine(
      Offset(w * 0.72, h * 0.50),
      Offset(w * 0.50, h * 0.46),
      _stroke(AppColors.outline, 1.5),
    );

    // Person peeking over box
    // Body
    _roundRect(
      canvas,
      Rect.fromLTWH(w * 0.38, h * 0.44, w * 0.24, h * 0.18),
      8,
      _fill(_orange),
    );
    // Arms up (shrugging)
    canvas.drawLine(
      Offset(w * 0.38, h * 0.50),
      Offset(w * 0.26, h * 0.43),
      _stroke(_orange, 8),
    );
    canvas.drawLine(
      Offset(w * 0.62, h * 0.50),
      Offset(w * 0.74, h * 0.43),
      _stroke(_orange, 8),
    );
    // Hands
    canvas.drawCircle(Offset(w * 0.25, h * 0.42), w * 0.04, _fill(_skin));
    canvas.drawCircle(Offset(w * 0.75, h * 0.42), w * 0.04, _fill(_skin));
    // Neck
    _roundRect(
      canvas,
      Rect.fromLTWH(w * 0.46, h * 0.28, w * 0.08, h * 0.10),
      4,
      _fill(_skin),
    );
    // Head
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.22),
        width: w * 0.22,
        height: h * 0.20,
      ),
      _fill(_skin),
    );
    // Hair
    final Path hair3 = Path()
      ..moveTo(w * 0.38, h * 0.19)
      ..quadraticBezierTo(w * 0.40, h * 0.10, w * 0.5, h * 0.11)
      ..quadraticBezierTo(w * 0.60, h * 0.10, w * 0.62, h * 0.19)
      ..quadraticBezierTo(w * 0.58, h * 0.14, w * 0.5, h * 0.14)
      ..quadraticBezierTo(w * 0.42, h * 0.14, w * 0.38, h * 0.19)
      ..close();
    canvas.drawPath(hair3, _fill(_near));
    // Eyes (question-mark look)
    canvas.drawCircle(Offset(w * 0.46, h * 0.22), w * 0.018, _fill(_near));
    canvas.drawCircle(Offset(w * 0.54, h * 0.22), w * 0.018, _fill(_near));
    // Slightly open mouth
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.27),
        width: w * 0.06,
        height: h * 0.03,
      ),
      _fill(const Color(0xFFCC5A44)),
    );

    // Ground line
    canvas.drawLine(
      Offset(0, h * 0.91),
      Offset(w, h * 0.91),
      _stroke(AppColors.outline, 1),
    );
  }

  // ── SCENE: Promo Relax (lounging with laptop) ─────────────────────────────
  void _paintPromoRelax(Canvas canvas, Size s) {
    final double w = s.width, h = s.height;

    // Vibrant Yellow Background
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, w, h),
        const Radius.circular(16),
      ),
      _fill(const Color(0xFFFFD54F)),
    );

    // Floor line
    canvas.drawLine(
      Offset(w * 0.1, h * 0.85),
      Offset(w * 0.9, h * 0.85),
      _stroke(const Color(0xFFF57C00), 3),
    );

    // Abstract plant in background
    _drawLeaf(
      canvas,
      Offset(w * 0.2, h * 0.7),
      w * 0.1,
      h * 0.15,
      -1.2,
      const Color(0xFFF57C00),
    );
    _drawLeaf(
      canvas,
      Offset(w * 0.2, h * 0.7),
      w * 0.08,
      h * 0.12,
      -1.8,
      const Color(0xFFF57C00),
    );

    // Person Lounge Pants (Purple)
    final Path legs = Path()
      ..moveTo(w * 0.4, h * 0.82) // hip
      ..lineTo(w * 0.2, h * 0.82) // foot 1
      ..lineTo(w * 0.35, h * 0.65) // knee
      ..lineTo(w * 0.55, h * 0.65) // hip 2
      ..lineTo(w * 0.45, h * 0.82) // foot 2
      ..close();
    canvas.drawPath(legs, _fill(const Color(0xFF7E57C2)));

    // Torso (White/Pink)
    final Path torso = Path()
      ..moveTo(w * 0.55, h * 0.65)
      ..lineTo(w * 0.75, h * 0.82)
      ..lineTo(w * 0.65, h * 0.82)
      ..lineTo(w * 0.45, h * 0.65)
      ..close();
    canvas.drawPath(torso, _fill(Colors.white));

    // Head/Hair
    canvas.drawCircle(
      Offset(w * 0.72, h * 0.65),
      w * 0.06,
      _fill(const Color(0xFFE91E63)),
    ); // Face
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(w * 0.72, h * 0.62),
        width: w * 0.14,
        height: h * 0.1,
      ),
      math.pi,
      math.pi,
      true,
      _fill(const Color(0xFF102033)), // Dark Hair
    );

    // Laptop/Tablet (Dark Blue/Teal)
    final Path laptop = Path()
      ..moveTo(w * 0.45, h * 0.55)
      ..lineTo(w * 0.6, h * 0.55)
      ..lineTo(w * 0.55, h * 0.7)
      ..lineTo(w * 0.4, h * 0.7)
      ..close();
    canvas.drawPath(laptop, _fill(const Color(0xFF0F4C3A)));

    // Laptop screen
    canvas.drawRect(
      Rect.fromLTWH(w * 0.42, h * 0.57, w * 0.16, h * 0.1),
      _fill(const Color(0xFF19B37D)),
    );

    // Sparkles around the person
    _drawSparkle(canvas, Offset(w * 0.85, h * 0.25), w * 0.03, Colors.white);
    _drawSparkle(
      canvas,
      Offset(w * 0.12, h * 0.35),
      w * 0.025,
      const Color(0xFFE91E63),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  void _roundRect(Canvas c, Rect r, double radius, Paint p) {
    c.drawRRect(RRect.fromRectAndRadius(r, Radius.circular(radius)), p);
  }

  void _drawLeaf(
    Canvas c,
    Offset tip,
    double lw,
    double lh,
    double angle,
    Color color,
  ) {
    final Path leaf = Path()
      ..moveTo(tip.dx, tip.dy)
      ..quadraticBezierTo(
        tip.dx + lw * math.cos(angle + 0.4),
        tip.dy + lh * math.sin(angle + 0.4),
        tip.dx + lw * math.cos(angle + 0.8),
        tip.dy + lh * math.sin(angle + 0.8),
      )
      ..quadraticBezierTo(
        tip.dx + lw * math.cos(angle + 0.4),
        tip.dy + lh * math.sin(angle + 0.4) + lh * 0.3,
        tip.dx,
        tip.dy,
      )
      ..close();
    c.drawPath(
      leaf,
      Paint()
        ..color = color
        ..style = PaintingStyle.fill,
    );
  }

  void _drawSparkle(Canvas c, Offset center, double size, Color color) {
    final Paint p = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    for (int i = 0; i < 4; i++) {
      final double angle = i * math.pi / 2;
      c.drawOval(
        Rect.fromCenter(
          center: Offset(
            center.dx + size * 0.5 * math.cos(angle),
            center.dy + size * 0.5 * math.sin(angle),
          ),
          width: size * 0.4,
          height: size * 1.2,
        ).shift(
          Offset(-size * 0.2 * math.cos(angle), -size * 0.6 * math.sin(angle)),
        ),
        p,
      );
    }
    c.drawCircle(center, size * 0.22, p);
  }
}
