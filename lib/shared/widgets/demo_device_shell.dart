import 'dart:math' as math;
import 'package:flutter/material.dart';

class DemoDeviceShell extends StatelessWidget {
  const DemoDeviceShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        // On narrow layouts (actual phone / narrow browser) render directly
        if (constraints.maxWidth < 500) {
          return child;
        }

        return _DeskSurface(child: _PhoneFrame(child: child));
      },
    );
  }
}

// ── Desktop presentation surface ─────────────────────────────────────────────

class _DeskSurface extends StatelessWidget {
  const _DeskSurface({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        // Base gradient — warm-neutral, dark at edges
        Positioned.fill(
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.2,
                colors: <Color>[
                  Color(0xFFEEF0F5), // centre: almost white
                  Color(0xFFD8DCE6), // mid: cool grey
                  Color(0xFFC4C8D4), // edge: slightly darker
                ],
                stops: <double>[0.0, 0.55, 1.0],
              ),
            ),
          ),
        ),

        // Subtle dot-grid texture (CustomPaint — zero cost, no image asset)
        Positioned.fill(child: CustomPaint(painter: _DotGridPainter())),

        // Soft vignette overlay (darkens corners)
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.0,
                colors: <Color>[
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.08),
                ],
                stops: const <double>[0.55, 1.0],
              ),
            ),
          ),
        ),

        // Phone centred with breathing room
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
            child: child,
          ),
        ),
      ],
    );
  }
}

class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const double spacing = 24;
    const double radius = 1.1;
    final Paint p = Paint()
      ..color = const Color(0xFF9BA3B4).withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;

    for (double x = spacing / 2; x < size.width; x += spacing) {
      for (double y = spacing / 2; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, p);
      }
    }
  }

  @override
  bool shouldRepaint(_DotGridPainter old) => false;
}

// ── Phone frame ───────────────────────────────────────────────────────────────

class _PhoneFrame extends StatelessWidget {
  const _PhoneFrame({required this.child});

  final Widget child;

  // iPhone 15 Pro reference - exact logical pixels (393x852)
  static const double _logicalWidth = 393;
  static const double _logicalHeight = 852;
  static const double _bezel = 14;
  static const double _cornerR = 50;

  // Safe area
  static const double _statusH = 54;
  static const double _homeH = 34;

  @override
  Widget build(BuildContext context) {
    // The exact physical size of the device including bezels
    final double deviceWidth = _logicalWidth + (_bezel * 2);
    final double deviceHeight = _logicalHeight + (_bezel * 2);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate how much we need to scale the device to fit the screen
        final double scale = math
            .min(
              constraints.maxWidth / deviceWidth,
              constraints.maxHeight / deviceHeight,
            )
            .clamp(0.0, 1.0); // Never scale larger than 1.0 (actual size)

        return Transform.scale(
          scale: scale,
          alignment: Alignment.center,
          child: SizedBox(
            width: deviceWidth,
            height: deviceHeight,
            child: Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                // ── Drop shadow (separate layer so it doesn't interact
                //    with the specular gradient on the body) ─────────────
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(_cornerR),
                      boxShadow: const <BoxShadow>[
                        // Deep lift shadow
                        BoxShadow(
                          color: Color(0x8C000000),
                          blurRadius: 64,
                          spreadRadius: -4,
                          offset: Offset(0, 28),
                        ),
                        // Mid ambient shadow
                        BoxShadow(
                          color: Color(0x38000000),
                          blurRadius: 24,
                          offset: Offset(0, 10),
                        ),
                        // Contact shadow (tight, very dark)
                        BoxShadow(
                          color: Color(0x2E000000),
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                        // Left-side rim light (simulates studio key light
                        // from upper-left — makes it feel 3-dimensional)
                        BoxShadow(
                          color: Color(0x0FFFFFFF),
                          blurRadius: 1,
                          offset: Offset(-1, -1),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Phone body ─────────────────────────────────────────
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(_cornerR),
                      // Titanium-like gradient: lighter top-left (catching
                      // the key light), darker bottom-right
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        stops: <double>[0.0, 0.3, 0.7, 1.0],
                        colors: <Color>[
                          Color(0xFF2E2E30), // highlight
                          Color(0xFF1E1E20), // body
                          Color(0xFF161618), // body shadow
                          Color(0xFF0E0E10), // deep shadow
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Specular rim — top + left edge highlight ───────────
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(_cornerR),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: <Color>[
                          Colors.white.withValues(alpha: 0.07),
                          Colors.transparent,
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.1),
                        ],
                        stops: const <double>[0.0, 0.25, 0.75, 1.0],
                      ),
                    ),
                  ),
                ),

                // ── Outer frame border ─────────────────────────────────
                // Two-tone: brighter on top-left, darker on bottom-right
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(_cornerR),
                      border: Border.all(
                        color: const Color(0xFF48484A),
                        width: 1,
                      ),
                    ),
                  ),
                ),

                // ── Screen area ────────────────────────────────────────
                Positioned(
                  top: _bezel,
                  left: _bezel,
                  width: _logicalWidth,
                  height: _logicalHeight,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(_cornerR - _bezel),
                    child: Stack(
                      children: <Widget>[
                        // The actual app child with a forced MediaQuery
                        MediaQuery(
                          data: const MediaQueryData(
                            size: Size(_logicalWidth, _logicalHeight),
                            padding: EdgeInsets.only(
                              top: _statusH,
                              bottom: _homeH,
                            ),
                            viewPadding: EdgeInsets.only(
                              top: _statusH,
                              bottom: _homeH,
                            ),
                            devicePixelRatio: 3.0, // iPhone 15 Pro
                          ),
                          child: child,
                        ),

                        // Status bar overlay
                        const Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          height: _statusH,
                          child: _StatusBar(),
                        ),

                        // Home indicator
                        const Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          height: _homeH,
                          child: _HomeIndicator(),
                        ),

                        // Screen glare
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          height: _logicalHeight * 0.38,
                          child: IgnorePointer(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(_cornerR - _bezel),
                                  topRight: Radius.circular(_cornerR - _bezel),
                                ),
                                gradient: LinearGradient(
                                  begin: Alignment.topRight,
                                  end: Alignment.bottomLeft,
                                  colors: <Color>[
                                    Colors.white.withValues(alpha: 0.055),
                                    Colors.white.withValues(alpha: 0.018),
                                    Colors.transparent,
                                  ],
                                  stops: const <double>[0.0, 0.4, 1.0],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Side buttons ───────────────────────────────────────
                // Silent switch
                const Positioned(
                  left: -3.5,
                  top: 108,
                  child: _SideButton(w: 3.5, h: 30),
                ),
                // Volume up
                const Positioned(
                  left: -3.5,
                  top: 152,
                  child: _SideButton(w: 3.5, h: 56),
                ),
                // Volume down
                const Positioned(
                  left: -3.5,
                  top: 218,
                  child: _SideButton(w: 3.5, h: 56),
                ),
                // Power / side button
                const Positioned(
                  right: -3.5,
                  top: 168,
                  child: _SideButton(w: 3.5, h: 76),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
// ── Status bar ────────────────────────────────────────────────────────────────

class _StatusBar extends StatelessWidget {
  const _StatusBar();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: const <Widget>[
        // Dynamic Island
        Positioned(
          top: 12,
          left: 0,
          right: 0,
          child: Center(child: _DynamicIsland()),
        ),

        // Time — left side
        Positioned(
          top: 0,
          left: 24,
          bottom: 0,
          child: Center(
            child: Text(
              '9:41',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.3,
                height: 1,
              ),
            ),
          ),
        ),

        // Status icons — right side
        Positioned(
          top: 0,
          right: 24,
          bottom: 0,
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                _SignalBars(),
                SizedBox(width: 5),
                _WifiIcon(),
                SizedBox(width: 6),
                _BatteryIcon(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DynamicIsland extends StatelessWidget {
  const _DynamicIsland();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 34,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(17),
        boxShadow: const <BoxShadow>[
          BoxShadow(color: Color(0x99000000), blurRadius: 3, spreadRadius: 1),
          BoxShadow(
            color: Color(0x0AFFFFFF),
            blurRadius: 1,
            offset: Offset(0, -1),
          ),
        ],
      ),
    );
  }
}

// ── Signal bars ───────────────────────────────────────────────────────────────

class _SignalBars extends StatelessWidget {
  const _SignalBars();

  @override
  Widget build(BuildContext context) {
    // 4 bars, 3 filled, 1 dim — standard full-signal look
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List<Widget>.generate(4, (int i) {
        final bool filled = i < 3;
        return Container(
          width: 3,
          height: 5 + i * 2.8,
          margin: const EdgeInsets.only(right: 1.5),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: filled ? 1.0 : 0.3),
            borderRadius: BorderRadius.circular(1),
          ),
        );
      }),
    );
  }
}

// ── Wi-Fi icon (custom painted, more faithful than the Material icon) ─────────

class _WifiIcon extends StatelessWidget {
  const _WifiIcon();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 16,
      height: 12,
      child: CustomPaint(painter: _WifiPainter()),
    );
  }
}

class _WifiPainter extends CustomPainter {
  const _WifiPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final Paint p = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final double cx = size.width / 2;
    final double by = size.height;

    // 3 arcs — outer, mid, inner
    for (int i = 0; i < 3; i++) {
      final double r = (size.width / 2) * (1 - i * 0.3);
      const double startAngle = math.pi + math.pi * 0.18;
      const double sweepAngle = math.pi * 0.64;
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, by), radius: r),
        startAngle,
        sweepAngle,
        false,
        p
          ..color = Colors.white.withValues(
            alpha: i == 0
                ? 1.0
                : i == 1
                ? 0.85
                : 0.7,
          ),
      );
    }

    // Dot
    canvas.drawCircle(Offset(cx, by - 1.5), 1.5, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(_WifiPainter old) => false;
}

// ── Battery icon ──────────────────────────────────────────────────────────────

class _BatteryIcon extends StatelessWidget {
  const _BatteryIcon();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 27,
      height: 13,
      child: CustomPaint(painter: _BatteryPainter(level: 0.78)),
    );
  }
}

class _BatteryPainter extends CustomPainter {
  const _BatteryPainter({required this.level});
  final double level;

  @override
  void paint(Canvas canvas, Size size) {
    const double tipW = 2.5;
    const double tipH = 5;
    final double bodyW = size.width - tipW - 1;
    final double bodyH = size.height;
    const double r = 2.5;

    // Body outline
    final RRect body = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, bodyW, bodyH),
      const Radius.circular(r),
    );
    canvas.drawRRect(
      body,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    // Fill
    final double fillW = (bodyW - 3) * level;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(1.5, 1.5, fillW, bodyH - 3),
        const Radius.circular(r * 0.5),
      ),
      Paint()..color = Colors.white,
    );

    // Tip
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(bodyW + 1.5, (bodyH - tipH) / 2, tipW, tipH),
        const Radius.circular(1),
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.5),
    );
  }

  @override
  bool shouldRepaint(_BatteryPainter old) => old.level != level;
}

// ── Home indicator ────────────────────────────────────────────────────────────

class _HomeIndicator extends StatelessWidget {
  const _HomeIndicator();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Container(
          width: 134,
          height: 5,
          decoration: BoxDecoration(
            // Frosted pill — lighter than original, matches real iOS
            color: Colors.white.withValues(alpha: 0.28),
            borderRadius: BorderRadius.circular(3),
            boxShadow: const <BoxShadow>[
              BoxShadow(color: Color(0x0FFFFFFF), blurRadius: 4),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Side button ───────────────────────────────────────────────────────────────

class _SideButton extends StatelessWidget {
  const _SideButton({required this.w, required this.h});
  final double w;
  final double h;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        // Gradient simulates a chamfered machined button edge:
        // lighter on the left (catching light), darker on the right
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: <Color>[
            Color(0xFF3A3A3C), // highlight edge
            Color(0xFF2A2A2C), // face
            Color(0xFF1C1C1E), // shadow edge
          ],
        ),
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: const Color(0xFF444446), width: 0.5),
      ),
    );
  }
}
