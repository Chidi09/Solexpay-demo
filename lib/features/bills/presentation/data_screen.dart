import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../mock/demo_app_state.dart';
import '../../../../shared/widgets/app_header.dart';
import '../../../../shared/widgets/branded_icons.dart';
import '../../../../shared/widgets/demo_device_shell.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/primary_button.dart';

class DataScreen extends StatefulWidget {
  const DataScreen({super.key});

  @override
  State<DataScreen> createState() => _DataScreenState();
}

class _DataScreenState extends State<DataScreen> {
  String _selectedNetwork = 'MTN';
  String _phoneNumber = '';
  _DataBundle? _selectedBundle;
  bool _isLoading = false;

  final Map<String, List<_DataBundle>> _bundles = <String, List<_DataBundle>>{
    'MTN': <_DataBundle>[
      _DataBundle(label: '1GB', duration: '1 day', price: 300, tag: 'Daily'),
      _DataBundle(label: '3GB', duration: '7 days', price: 1000, tag: 'Weekly'),
      _DataBundle(
        label: '15GB',
        duration: '30 days',
        price: 3500,
        tag: 'Student',
      ),
      _DataBundle(
        label: '30GB',
        duration: '30 days',
        price: 6000,
        tag: 'Monthly',
      ),
    ],
    'Airtel': <_DataBundle>[
      _DataBundle(label: '1.5GB', duration: '1 day', price: 350, tag: 'Daily'),
      _DataBundle(label: '4GB', duration: '7 days', price: 1200, tag: 'Weekly'),
      _DataBundle(
        label: '12GB',
        duration: '30 days',
        price: 3200,
        tag: 'Monthly',
      ),
    ],
    'Glo': <_DataBundle>[
      _DataBundle(label: '2GB', duration: '1 day', price: 400, tag: 'Daily'),
      _DataBundle(
        label: '5.8GB',
        duration: '7 days',
        price: 1500,
        tag: 'Weekly',
      ),
      _DataBundle(
        label: '18GB',
        duration: '30 days',
        price: 4000,
        tag: 'Monthly',
      ),
    ],
    '9mobile': <_DataBundle>[
      _DataBundle(
        label: '1GB',
        duration: '30 days',
        price: 1000,
        tag: 'Monthly',
      ),
      _DataBundle(
        label: '5GB',
        duration: '30 days',
        price: 2000,
        tag: 'Monthly',
      ),
    ],
  };

  List<_DataBundle> get _currentBundles =>
      _bundles[_selectedNetwork] ?? <_DataBundle>[];

  Future<void> _handlePurchase(DemoAppState appState) async {
    if (_selectedBundle == null) return;
    setState(() => _isLoading = true);
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    appState.updateWalletBalance(appState.balance - _selectedBundle!.price);
    setState(() => _isLoading = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${_selectedBundle!.label} data activated on $_phoneNumber',
        ),
        backgroundColor: AppColors.accent,
      ),
    );
    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final DemoAppState appState = context.watch<DemoAppState>();

    return Scaffold(
      body: DemoDeviceShell(
        child: Scaffold(
          backgroundColor: AppColors.shell,
          resizeToAvoidBottomInset: false,
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: <Widget>[
                AppHeader.withBack(
                  title: 'Data Bundles',
                  subtitle: 'Select your network plan',
                  onBack: () => context.go('/home'),
                ),
                const SizedBox(height: 14),

                // Network tabs
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: <String>['MTN', 'Airtel', 'Glo', '9mobile'].map((
                      String net,
                    ) {
                      final bool selected = _selectedNetwork == net;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() {
                              _selectedNetwork = net;
                              _selectedBundle = null;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.accent
                                  : AppColors.outline.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                NetworkIcon(
                                  network: net,
                                  size: selected ? 24 : 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  net,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                    color: selected
                                        ? AppColors.ink
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ).animate().fadeIn(duration: 300.ms),

                const SizedBox(height: 12),

                // Bundle list
                ..._currentBundles.map((_DataBundle bundle) {
                  final bool selected = _selectedBundle == bundle;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: GlassCard(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _selectedBundle = bundle);
                      },
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: <Widget>[
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.accentSoft
                                  : AppColors.outline.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(11),
                            ),
                            child: TransferIcon(
                              type: TransferType.data,
                              size: selected ? 24 : 20,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Text(
                                      bundle.label,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 1,
                                      ),
                                      decoration: BoxDecoration(
                                        color: bundle.tag == 'Student'
                                            ? AppColors.accentSoft
                                            : AppColors.outline.withValues(
                                                alpha: 0.4,
                                              ),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        bundle.tag,
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w600,
                                          color: bundle.tag == 'Student'
                                              ? AppColors.accent
                                              : AppColors.textSecondary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  bundle.duration,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              Text(
                                '\u20A6${bundle.price.round()}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: selected
                                      ? AppColors.accent
                                      : AppColors.textPrimary,
                                ),
                              ),
                              if (selected)
                                const Icon(
                                  Icons.check_circle_rounded,
                                  color: AppColors.accent,
                                  size: 16,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 6),

                // Phone input
                GlassCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  child: TextField(
                    keyboardType: TextInputType.phone,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(11),
                    ],
                    decoration: const InputDecoration(
                      hintText: 'Phone number',
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                      hintStyle: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                      prefixIcon: Icon(
                        Icons.phone_rounded,
                        color: AppColors.accent,
                        size: 18,
                      ),
                      prefixIconConstraints: BoxConstraints(minWidth: 32),
                    ),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    onChanged: (String v) => setState(() => _phoneNumber = v),
                  ),
                ),

                const SizedBox(height: 16),

                PrimaryButton(
                  label: _selectedBundle == null
                      ? 'Select a bundle'
                      : 'Buy ${_selectedBundle!.label} for \u20A6${_selectedBundle!.price.round()}',
                  isLoading: _isLoading,
                  onPressed: _selectedBundle == null || _phoneNumber.isEmpty
                      ? null
                      : () => _handlePurchase(appState),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DataBundle {
  const _DataBundle({
    required this.label,
    required this.duration,
    required this.price,
    required this.tag,
  });
  final String label;
  final String duration;
  final double price;
  final String tag;

  @override
  bool operator ==(Object other) =>
      other is _DataBundle && other.label == label && other.price == price;

  @override
  int get hashCode => Object.hash(label, price);
}
