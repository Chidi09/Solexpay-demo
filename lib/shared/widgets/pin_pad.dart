import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class PinPad extends StatelessWidget {
  const PinPad({
    super.key,
    required this.onDigitPressed,
    required this.onBackspace,
    this.onBiometric,
  });

  final ValueChanged<int> onDigitPressed;
  final VoidCallback onBackspace;
  final VoidCallback? onBiometric;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        for (final List<int> row in _rows)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: row
                  .map(
                    (int value) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: _PinKey(
                          label: '$value',
                          onTap: () => onDigitPressed(value),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        Row(
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: _PinKey(
                  icon: onBiometric == null ? null : Icons.fingerprint_rounded,
                  onTap: onBiometric,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: _PinKey(
                  label: '0',
                  onTap: () => onDigitPressed(0),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: _PinKey(
                  icon: Icons.backspace_outlined,
                  onTap: onBackspace,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

const List<List<int>> _rows = <List<int>>[
  <int>[1, 2, 3],
  <int>[4, 5, 6],
  <int>[7, 8, 9],
];

class _PinKey extends StatelessWidget {
  const _PinKey({this.label, this.icon, this.onTap});

  final String? label;
  final IconData? icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        height: 58,
        decoration: BoxDecoration(
          color: AppColors.shell,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.outline),
        ),
        child: Center(
          child: label != null
              ? Text(
                  label!,
                  style: Theme.of(context).textTheme.titleLarge,
                )
              : Icon(icon, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}
