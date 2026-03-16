import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Branded stylized icons for SolexPay - Network providers, banks, etc.
// ---------------------------------------------------------------------------

class NetworkIcon extends StatelessWidget {
  const NetworkIcon({super.key, required this.network, this.size = 36});

  final String network; // 'MTN', 'Airtel', 'Glo', '9mobile'
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _NetworkIconPainter(network: network)),
    );
  }
}

class _NetworkIconPainter extends CustomPainter {
  const _NetworkIconPainter({required this.network});
  final String network;

  @override
  void paint(Canvas canvas, Size size) {
    switch (network.toUpperCase()) {
      case 'MTN':
        _paintMTN(canvas, size);
      case 'AIRTEL':
        _paintAirtel(canvas, size);
      case 'GLO':
      case 'GLO MOBILE':
        _paintGlo(canvas, size);
      case '9MOBILE':
      case '9MOBILE (ETISALAT)':
        _paint9mobile(canvas, size);
      default:
        _paintGeneric(canvas, size);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;

  Paint _fill(Color c) => Paint()
    ..color = c
    ..style = PaintingStyle.fill;

  Paint _stroke(Color c, double w) => Paint()
    ..color = c
    ..style = PaintingStyle.stroke
    ..strokeWidth = w
    ..strokeCap = StrokeCap.round;

  // ── MTN ────────────────────────────────────────────────────────────────────
  void _paintMTN(Canvas canvas, Size s) {
    final double w = s.width, h = s.height;

    // Yellow background circle
    canvas.drawCircle(
      Offset(w * 0.5, h * 0.5),
      w * 0.5,
      _fill(const Color(0xFFFFCC00)),
    );

    // M shape in black
    final Path mPath = Path()
      ..moveTo(w * 0.2, h * 0.75)
      ..lineTo(w * 0.2, h * 0.35)
      ..lineTo(w * 0.35, h * 0.25)
      ..lineTo(w * 0.5, h * 0.4)
      ..lineTo(w * 0.65, h * 0.25)
      ..lineTo(w * 0.8, h * 0.35)
      ..lineTo(w * 0.8, h * 0.75);

    canvas.drawPath(mPath, _stroke(const Color(0xFF000000), w * 0.08));

    // Decorative signal waves
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.55),
        width: w * 0.5,
        height: h * 0.35,
      ),
      3.14 * 1.1,
      3.14 * 0.8,
      false,
      _stroke(const Color(0xFF000000).withValues(alpha: 0.3), w * 0.02),
    );
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.55),
        width: w * 0.35,
        height: h * 0.25,
      ),
      3.14 * 1.1,
      3.14 * 0.8,
      false,
      _stroke(const Color(0xFF000000).withValues(alpha: 0.3), w * 0.02),
    );
  }

  // ── Airtel ─────────────────────────────────────────────────────────────────
  void _paintAirtel(Canvas canvas, Size s) {
    final double w = s.width, h = s.height;

    // Red background circle
    canvas.drawCircle(
      Offset(w * 0.5, h * 0.5),
      w * 0.5,
      _fill(const Color(0xFFE8001A)),
    );

    // White curved wave (stylized "A" shape)
    final Path wavePath = Path()
      ..moveTo(w * 0.25, h * 0.55)
      ..quadraticBezierTo(w * 0.4, h * 0.35, w * 0.5, h * 0.55)
      ..quadraticBezierTo(w * 0.6, h * 0.75, w * 0.75, h * 0.55);

    canvas.drawPath(wavePath, _stroke(const Color(0xFFFFFFFF), w * 0.06));

    // Dot above
    canvas.drawCircle(
      Offset(w * 0.5, h * 0.3),
      w * 0.06,
      _fill(const Color(0xFFFFFFFF)),
    );
  }

  // ── Glo ────────────────────────────────────────────────────────────────────
  void _paintGlo(Canvas canvas, Size s) {
    final double w = s.width, h = s.height;

    // Green background circle
    canvas.drawCircle(
      Offset(w * 0.5, h * 0.5),
      w * 0.5,
      _fill(const Color(0xFF006633)),
    );

    // "G" in lighter green
    final double strokeW = w * 0.07;
    final Path gPath = Path()
      ..moveTo(w * 0.65, h * 0.35)
      ..quadraticBezierTo(w * 0.35, h * 0.25, w * 0.35, h * 0.5)
      ..quadraticBezierTo(w * 0.35, h * 0.75, w * 0.5, h * 0.75)
      ..lineTo(w * 0.65, h * 0.75)
      ..lineTo(w * 0.65, h * 0.58)
      ..lineTo(w * 0.52, h * 0.58);

    canvas.drawPath(gPath, _stroke(const Color(0xFF7ED321), strokeW));
  }

  // ── 9mobile ────────────────────────────────────────────────────────────────
  void _paint9mobile(Canvas canvas, Size s) {
    final double w = s.width, h = s.height;

    // Light green background circle
    canvas.drawCircle(
      Offset(w * 0.5, h * 0.5),
      w * 0.5,
      _fill(const Color(0xFF006E34)),
    );

    // "9" in lime green
    final double strokeW = w * 0.07;
    final Path ninePath = Path()
      ..moveTo(w * 0.35, h * 0.35)
      ..lineTo(w * 0.65, h * 0.35)
      ..lineTo(w * 0.45, h * 0.7)
      ..moveTo(w * 0.42, h * 0.55)
      ..quadraticBezierTo(w * 0.65, h * 0.55, w * 0.65, h * 0.68)
      ..quadraticBezierTo(w * 0.65, h * 0.8, w * 0.5, h * 0.8);

    canvas.drawPath(ninePath, _stroke(const Color(0xFF7ED321), strokeW));
  }

  // ── Generic fallback ───────────────────────────────────────────────────────
  void _paintGeneric(Canvas canvas, Size s) {
    final double w = s.width, h = s.height;

    canvas.drawCircle(
      Offset(w * 0.5, h * 0.5),
      w * 0.5,
      _fill(const Color(0xFF6B7280)),
    );

    // Generic signal icon
    canvas.drawLine(
      Offset(w * 0.3, h * 0.65),
      Offset(w * 0.3, h * 0.55),
      _stroke(const Color(0xFFFFFFFF), w * 0.04),
    );
    canvas.drawLine(
      Offset(w * 0.45, h * 0.65),
      Offset(w * 0.45, h * 0.45),
      _stroke(const Color(0xFFFFFFFF), w * 0.04),
    );
    canvas.drawLine(
      Offset(w * 0.6, h * 0.65),
      Offset(w * 0.6, h * 0.35),
      _stroke(const Color(0xFFFFFFFF), w * 0.04),
    );
    canvas.drawLine(
      Offset(w * 0.75, h * 0.65),
      Offset(w * 0.75, h * 0.25),
      _stroke(const Color(0xFFFFFFFF), w * 0.04),
    );
  }
}

// ---------------------------------------------------------------------------
// Bank/Transfer stylized icons
// ---------------------------------------------------------------------------

class TransferIcon extends StatelessWidget {
  const TransferIcon({super.key, required this.type, this.size = 40});

  final TransferType type;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _TransferIconPainter(type: type)),
    );
  }
}

enum TransferType { p2p, bank, airtime, data, card, savings }

class _TransferIconPainter extends CustomPainter {
  const _TransferIconPainter({required this.type});
  final TransferType type;

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width, h = size.height;

    Paint fill(Color c) => Paint()
      ..color = c
      ..style = PaintingStyle.fill;

    Paint stroke(Color c, double w) => Paint()
      ..color = c
      ..style = PaintingStyle.stroke
      ..strokeWidth = w
      ..strokeCap = StrokeCap.round;

    switch (type) {
      case TransferType.p2p:
        // Two people facing each other
        _drawPerson(
          canvas,
          Offset(w * 0.25, h * 0.6),
          w * 0.15,
          h * 0.25,
          const Color(0xFF8B6FD4),
        );
        _drawPerson(
          canvas,
          Offset(w * 0.75, h * 0.6),
          w * 0.15,
          h * 0.25,
          const Color(0xFFE8845C),
        );
        // Arrow between them
        canvas.drawLine(
          Offset(w * 0.4, h * 0.5),
          Offset(w * 0.6, h * 0.5),
          stroke(const Color(0xFF19B37D), w * 0.04),
        );
        canvas.drawLine(
          Offset(w * 0.55, h * 0.45),
          Offset(w * 0.6, h * 0.5),
          stroke(const Color(0xFF19B37D), w * 0.04),
        );
        canvas.drawLine(
          Offset(w * 0.55, h * 0.55),
          Offset(w * 0.6, h * 0.5),
          stroke(const Color(0xFF19B37D), w * 0.04),
        );

      case TransferType.bank:
        // Bank building columns
        canvas.drawRect(
          Rect.fromLTWH(w * 0.1, h * 0.55, w * 0.08, h * 0.35),
          fill(const Color(0xFF6B7280)),
        );
        canvas.drawRect(
          Rect.fromLTWH(w * 0.25, h * 0.45, w * 0.08, h * 0.45),
          fill(const Color(0xFF6B7280)),
        );
        canvas.drawRect(
          Rect.fromLTWH(w * 0.4, h * 0.35, w * 0.08, h * 0.55),
          fill(const Color(0xFF6B7280)),
        );
        canvas.drawRect(
          Rect.fromLTWH(w * 0.55, h * 0.35, w * 0.08, h * 0.55),
          fill(const Color(0xFF6B7280)),
        );
        canvas.drawRect(
          Rect.fromLTWH(w * 0.7, h * 0.45, w * 0.08, h * 0.45),
          fill(const Color(0xFF6B7280)),
        );
        canvas.drawRect(
          Rect.fromLTWH(w * 0.85, h * 0.55, w * 0.08, h * 0.35),
          fill(const Color(0xFF6B7280)),
        );
        // Triangle roof
        final Path roof = Path()
          ..moveTo(w * 0.02, h * 0.35)
          ..lineTo(w * 0.5, h * 0.12)
          ..lineTo(w * 0.98, h * 0.35)
          ..close();
        canvas.drawPath(roof, fill(const Color(0xFF374151)));
        // Dollar/Naira circle
        canvas.drawCircle(
          Offset(w * 0.5, h * 0.72),
          w * 0.12,
          fill(const Color(0xFF19B37D)),
        );
        canvas.drawLine(
          Offset(w * 0.5, h * 0.65),
          Offset(w * 0.5, h * 0.79),
          stroke(const Color(0xFFFFFFFF), w * 0.04),
        );
        canvas.drawLine(
          Offset(w * 0.43, h * 0.69),
          Offset(w * 0.57, h * 0.75),
          stroke(const Color(0xFFFFFFFF), w * 0.03),
        );

      case TransferType.airtime:
        // Phone with signal
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset(w * 0.5, h * 0.55),
              width: w * 0.45,
              height: h * 0.55,
            ),
            Radius.circular(w * 0.06),
          ),
          fill(const Color(0xFF374151)),
        );
        // Screen
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset(w * 0.5, h * 0.55),
              width: w * 0.35,
              height: h * 0.4,
            ),
            Radius.circular(w * 0.03),
          ),
          fill(const Color(0xFF19B37D)),
        );
        // Signal bars above
        canvas.drawLine(
          Offset(w * 0.2, h * 0.2),
          Offset(w * 0.2, h * 0.08),
          stroke(const Color(0xFFFFCC00), w * 0.04),
        );
        canvas.drawLine(
          Offset(w * 0.35, h * 0.2),
          Offset(w * 0.35, h * 0.05),
          stroke(const Color(0xFFFFCC00), w * 0.04),
        );
        canvas.drawLine(
          Offset(w * 0.5, h * 0.2),
          Offset(w * 0.5, h * 0.02),
          stroke(const Color(0xFFFFCC00), w * 0.04),
        );
        canvas.drawLine(
          Offset(w * 0.65, h * 0.2),
          Offset(w * 0.65, h * 0.05),
          stroke(const Color(0xFFFFCC00), w * 0.04),
        );
        canvas.drawLine(
          Offset(w * 0.8, h * 0.2),
          Offset(w * 0.8, h * 0.08),
          stroke(const Color(0xFFFFCC00), w * 0.04),
        );

      case TransferType.data:
        // WiFi symbol
        for (int i = 3; i >= 0; i--) {
          canvas.drawArc(
            Rect.fromCenter(
              center: Offset(w * 0.5, h * 0.75),
              width: w * (0.3 + i * 0.18),
              height: h * (0.25 + i * 0.15),
            ),
            3.14,
            3.14,
            false,
            stroke(const Color(0xFF6B7280), w * 0.04),
          );
        }
        canvas.drawCircle(
          Offset(w * 0.5, h * 0.78),
          w * 0.06,
          fill(const Color(0xFF19B37D)),
        );
        // Data packets floating
        canvas.drawRect(
          Rect.fromLTWH(w * 0.75, h * 0.25, w * 0.08, h * 0.08),
          fill(const Color(0xFFE8845C)),
        );
        canvas.drawRect(
          Rect.fromLTWH(w * 0.85, h * 0.35, w * 0.08, h * 0.08),
          fill(const Color(0xFF8B6FD4)),
        );
        canvas.drawRect(
          Rect.fromLTWH(w * 0.7, h * 0.4, w * 0.08, h * 0.08),
          fill(const Color(0xFFF5C842)),
        );

      case TransferType.card:
        // Credit card shape
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset(w * 0.5, h * 0.55),
              width: w * 0.7,
              height: h * 0.45,
            ),
            Radius.circular(w * 0.05),
          ),
          fill(const Color(0xFF374151)),
        );
        // Magnetic strip
        canvas.drawRect(
          Rect.fromLTWH(w * 0.15, h * 0.45, w * 0.7, h * 0.08),
          fill(const Color(0xFF1F2937)),
        );
        // Chip
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(w * 0.2, h * 0.58, w * 0.12, h * 0.1),
            Radius.circular(w * 0.02),
          ),
          fill(const Color(0xFFF5C842)),
        );
        // Card lines
        canvas.drawLine(
          Offset(w * 0.2, h * 0.75),
          Offset(w * 0.5, h * 0.75),
          stroke(const Color(0xFF9CA3AF), w * 0.02),
        );
        canvas.drawLine(
          Offset(w * 0.2, h * 0.82),
          Offset(w * 0.4, h * 0.82),
          stroke(const Color(0xFF9CA3AF), w * 0.02),
        );

      case TransferType.savings:
        // Piggy bank
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(w * 0.5, h * 0.6),
            width: w * 0.6,
            height: h * 0.4,
          ),
          fill(const Color(0xFFF5C842)),
        );
        // Snout
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(w * 0.75, h * 0.58),
            width: w * 0.15,
            height: h * 0.12,
          ),
          fill(const Color(0xFFE8845C)),
        );
        // Eye
        canvas.drawCircle(
          Offset(w * 0.35, h * 0.52),
          w * 0.04,
          fill(const Color(0xFF1F2937)),
        );
        // Ear
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(w * 0.25, h * 0.45),
            width: w * 0.1,
            height: h * 0.15,
          ),
          fill(const Color(0xFFE8845C)),
        );
        // Leg
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(w * 0.35, h * 0.8),
            width: w * 0.1,
            height: h * 0.1,
          ),
          fill(const Color(0xFFE8845C)),
        );
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(w * 0.65, h * 0.8),
            width: w * 0.1,
            height: h * 0.1,
          ),
          fill(const Color(0xFFE8845C)),
        );
        // Coin slot
        canvas.drawRect(
          Rect.fromLTWH(w * 0.42, h * 0.38, w * 0.16, h * 0.04),
          fill(const Color(0xFF1F2937)),
        );
    }
  }

  void _drawPerson(Canvas c, Offset center, double w, double h, Color color) {
    Paint fill(Color c) => Paint()
      ..color = c
      ..style = PaintingStyle.fill;

    // Body
    c.drawOval(
      Rect.fromCenter(center: center, width: w, height: h * 0.7),
      fill(color),
    );
    // Head
    c.drawCircle(
      Offset(center.dx, center.dy - h * 0.4),
      w * 0.35,
      fill(const Color(0xFFBE8A6A)),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ---------------------------------------------------------------------------
// Service category icons (stylized for the home grid)
// ---------------------------------------------------------------------------

class ServiceIcon extends StatelessWidget {
  const ServiceIcon({
    super.key,
    required this.service,
    this.size = 32,
    this.color,
  });

  final String
  service; // 'transfer', 'airtime', 'data', 'savings', 'loans', 'card'
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ServiceIconPainter(service: service, overrideColor: color),
      ),
    );
  }
}

class _ServiceIconPainter extends CustomPainter {
  const _ServiceIconPainter({required this.service, this.overrideColor});
  final String service;
  final Color? overrideColor;

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width, h = size.height;
    final Color c = overrideColor ?? const Color(0xFF19B37D);

    Paint fill(Color color) => Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    Paint stroke(Color color, double width) => Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round;

    switch (service.toLowerCase()) {
      case 'transfer':
        // Arrow with person
        canvas.drawCircle(Offset(w * 0.35, h * 0.35), w * 0.12, fill(c));
        canvas.drawLine(
          Offset(w * 0.5, h * 0.5),
          Offset(w * 0.75, h * 0.75),
          stroke(c, w * 0.06),
        );
        canvas.drawLine(
          Offset(w * 0.65, h * 0.65),
          Offset(w * 0.75, h * 0.75),
          stroke(c, w * 0.06),
        );
        canvas.drawLine(
          Offset(w * 0.75, h * 0.65),
          Offset(w * 0.75, h * 0.75),
          stroke(c, w * 0.06),
        );
        canvas.drawCircle(
          Offset(w * 0.85, h * 0.85),
          w * 0.08,
          fill(const Color(0xFFE8845C)),
        );

      case 'airtime':
        // Phone with plus
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset(w * 0.45, h * 0.55),
              width: w * 0.4,
              height: h * 0.5,
            ),
            Radius.circular(w * 0.04),
          ),
          stroke(c, w * 0.05),
        );
        canvas.drawLine(
          Offset(w * 0.75, h * 0.35),
          Offset(w * 0.75, h * 0.55),
          stroke(c, w * 0.05),
        );
        canvas.drawLine(
          Offset(w * 0.65, h * 0.45),
          Offset(w * 0.85, h * 0.45),
          stroke(c, w * 0.05),
        );

      case 'data':
        // WiFi symbol
        for (int i = 0; i < 3; i++) {
          canvas.drawArc(
            Rect.fromCenter(
              center: Offset(w * 0.5, h * 0.7),
              width: w * (0.2 + i * 0.15),
              height: h * (0.2 + i * 0.12),
            ),
            3.14,
            3.14,
            false,
            stroke(c, w * 0.05),
          );
        }
        canvas.drawCircle(Offset(w * 0.5, h * 0.75), w * 0.05, fill(c));

      case 'savings':
        // Plant/growth
        canvas.drawLine(
          Offset(w * 0.5, h * 0.85),
          Offset(w * 0.5, h * 0.5),
          stroke(const Color(0xFF8B5E3C), w * 0.06),
        );
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(w * 0.35, h * 0.45),
            width: w * 0.15,
            height: h * 0.1,
          ),
          fill(c),
        );
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(w * 0.65, h * 0.55),
            width: w * 0.15,
            height: h * 0.1,
          ),
          fill(c),
        );
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(w * 0.5, h * 0.35),
            width: w * 0.12,
            height: h * 0.08,
          ),
          fill(const Color(0xFFB8EDD9)),
        );

      case 'loans':
        // Money/cash
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset(w * 0.5, h * 0.55),
              width: w * 0.6,
              height: h * 0.35,
            ),
            Radius.circular(w * 0.02),
          ),
          stroke(c, w * 0.04),
        );
        canvas.drawCircle(
          Offset(w * 0.5, h * 0.55),
          w * 0.08,
          stroke(c, w * 0.03),
        );
        canvas.drawLine(
          Offset(w * 0.25, h * 0.45),
          Offset(w * 0.25, h * 0.65),
          stroke(c, w * 0.03),
        );
        canvas.drawLine(
          Offset(w * 0.75, h * 0.45),
          Offset(w * 0.75, h * 0.65),
          stroke(c, w * 0.03),
        );

      case 'card':
      case 'virtual card':
        // Card with chip
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset(w * 0.5, h * 0.55),
              width: w * 0.6,
              height: h * 0.4,
            ),
            Radius.circular(w * 0.04),
          ),
          stroke(c, w * 0.04),
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(w * 0.25, h * 0.5, w * 0.15, h * 0.12),
            Radius.circular(w * 0.02),
          ),
          fill(const Color(0xFFF5C842)),
        );

      default:
        // Generic circle
        canvas.drawCircle(
          Offset(w * 0.5, h * 0.5),
          w * 0.35,
          stroke(c, w * 0.05),
        );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
