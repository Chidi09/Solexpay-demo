import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/api_service.dart';
import '../../../../mock/demo_app_state.dart';
import '../../../../shared/widgets/app_header.dart';
import '../../../../shared/widgets/branded_icons.dart';
import '../../../../shared/widgets/demo_device_shell.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/primary_button.dart';

class AirtimeScreen extends StatefulWidget {
  const AirtimeScreen({super.key});

  @override
  State<AirtimeScreen> createState() => _AirtimeScreenState();
}

class _AirtimeScreenState extends State<AirtimeScreen> {
  String _selectedNetwork = 'MTN';
  String _phoneNumber = '';
  String _amount = '';
  bool _isLoading = false;

  final List<_NetworkOption> _networks = const <_NetworkOption>[
    _NetworkOption(name: 'MTN', color: Color(0xFFFFCC00)),
    _NetworkOption(name: 'Airtel', color: Color(0xFFE8001A)),
    _NetworkOption(name: 'Glo', color: Color(0xFF006633)),
    _NetworkOption(name: '9mobile', color: Color(0xFF006E34)),
  ];

  Future<void> _handlePurchase(DemoAppState appState) async {
    final double? amt = double.tryParse(_amount);
    if (amt == null || amt <= 0 || _isLoading) return;
    setState(() => _isLoading = true);

    try {
      final apiService = context.read<ApiService>();
      final String providerCode = _selectedNetwork.toLowerCase();
      final String walletId = appState.userProfile.walletId;

      await apiService.purchaseAirtime(
        walletId: walletId.isNotEmpty ? walletId : appState.userProfile.id,
        providerCode: providerCode,
        phoneNumber: _phoneNumber,
        amount: amt,
      );

      appState.updateWalletBalance(appState.balance - amt);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('₦${amt.round()} airtime sent to $_phoneNumber'),
            backgroundColor: const Color(0xFF0F7A50),
          ),
        );
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
        setState(() => _isLoading = false);
      }
    }
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
                  title: 'Buy Airtime',
                  subtitle: 'Instant top-up with 5% cashback',
                  onBack: () => context.go('/home'),
                ),
                const SizedBox(height: 8),

                // Cashback promo banner
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accentSoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: <Widget>[
                      Icon(
                        Icons.local_offer_rounded,
                        color: AppColors.accent,
                        size: 14,
                      ),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Cashback: Get 3% back on airtime purchases this week!',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 300.ms),

                const SizedBox(height: 14),

                // Network selector
                GlassCard(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        'Select network',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: _networks.map((_NetworkOption net) {
                          final bool selected = _selectedNetwork == net.name;
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 2,
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  setState(() => _selectedNetwork = net.name);
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? net.color.withValues(alpha: 0.12)
                                        : AppColors.outline.withValues(
                                            alpha: 0.3,
                                          ),
                                    borderRadius: BorderRadius.circular(10),
                                    border: selected
                                        ? Border.all(
                                            color: net.color,
                                            width: 1.2,
                                          )
                                        : null,
                                  ),
                                  child: Column(
                                    children: <Widget>[
                                      NetworkIcon(
                                        network: net.name,
                                        size: selected ? 28 : 24,
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        net.name,
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w600,
                                          color: selected
                                              ? net.color
                                              : AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 100.ms, duration: 350.ms),

                const SizedBox(height: 10),

                // Phone input
                GlassCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        'Phone number',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      TextField(
                        keyboardType: TextInputType.phone,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(11),
                        ],
                        decoration: const InputDecoration(
                          hintText: '080 0000 0000',
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 8),
                          hintStyle: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
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
                        onChanged: (String v) =>
                            setState(() => _phoneNumber = v),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          setState(
                            () => _phoneNumber = appState
                                .userProfile
                                .phoneNumber
                                .replaceAll(RegExp(r'[^0-9]'), ''),
                          );
                        },
                        icon: const Icon(Icons.person_rounded, size: 14),
                        label: const Text(
                          'Use my number',
                          style: TextStyle(fontSize: 11),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.accent,
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 28),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 150.ms, duration: 350.ms),

                const SizedBox(height: 10),

                // Quick amount buttons
                GlassCard(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        'Amount',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children:
                            <String>[
                              '100',
                              '200',
                              '500',
                              '1000',
                              '2000',
                              '5000',
                            ].map((String amt) {
                              final bool selected = _amount == amt;
                              return GestureDetector(
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  setState(() => _amount = amt);
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? AppColors.accent
                                        : AppColors.outline.withValues(
                                            alpha: 0.4,
                                          ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '\u20A6$amt',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 11,
                                      color: selected
                                          ? AppColors.ink
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 200.ms, duration: 350.ms),

                const SizedBox(height: 16),

                PrimaryButton(
                  label: _amount.isEmpty
                      ? 'Buy Airtime'
                      : 'Buy \u20A6$_amount Airtime',
                  isLoading: _isLoading,
                  onPressed: _amount.isEmpty || _phoneNumber.isEmpty
                      ? null
                      : () => _handlePurchase(appState),
                ).animate().fadeIn(delay: 250.ms, duration: 300.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NetworkOption {
  const _NetworkOption({required this.name, required this.color});
  final String name;
  final Color color;
}
