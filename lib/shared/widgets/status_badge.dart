import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

enum StatusBadgeTone { neutral, success, warning, danger }

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    this.tone = StatusBadgeTone.neutral,
  });

  final String label;
  final StatusBadgeTone tone;

  @override
  Widget build(BuildContext context) {
    final _BadgeColors colors = _resolveColors(tone);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: colors.foreground,
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
    );
  }

  _BadgeColors _resolveColors(StatusBadgeTone value) {
    switch (value) {
      case StatusBadgeTone.success:
        return const _BadgeColors(
          background: Color(0xFFE2F7EC),
          foreground: Color(0xFF0F7A50),
        );
      case StatusBadgeTone.warning:
        return const _BadgeColors(
          background: Color(0xFFFFF1D9),
          foreground: Color(0xFF8A5A00),
        );
      case StatusBadgeTone.danger:
        return const _BadgeColors(
          background: Color(0xFFFCE2E5),
          foreground: Color(0xFF9A1D2D),
        );
      case StatusBadgeTone.neutral:
        return const _BadgeColors(
          background: AppColors.accentSoft,
          foreground: AppColors.textPrimary,
        );
    }
  }
}

class _BadgeColors {
  const _BadgeColors({required this.background, required this.foreground});

  final Color background;
  final Color foreground;
}
