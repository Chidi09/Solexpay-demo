import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/api_service.dart';
import '../../../../mock/demo_app_state.dart';
import '../../../../shared/models/transfer_draft.dart';
import '../../../../shared/widgets/app_header.dart';
import '../../../../shared/widgets/demo_device_shell.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/primary_button.dart';

class BankTransferScreen extends StatefulWidget {
  const BankTransferScreen({super.key});

  @override
  State<BankTransferScreen> createState() => _BankTransferScreenState();
}

class _BankTransferScreenState extends State<BankTransferScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  String? _selectedBank;
  String? _selectedBankCode;
  List<Map<String, dynamic>> _fetchedBanks = [];
  bool _isLoadingBanks = false;
  bool _isLookingUpName = false;
  String? _resolvedName;
  String? _nameEnquirySessionId;
  bool _isEstimatingFee = false;

  final List<double> _quickAmounts = [
    500,
    1000,
    2000,
    5000,
    9999,
    10000,
    20000,
  ];

  final List<Map<String, dynamic>> _banks = [];

  @override
  void initState() {
    super.initState();
    _accountController.addListener(_onAccountChanged);
    _loadBanks();
  }

  @override
  void dispose() {
    _accountController.removeListener(_onAccountChanged);
    _accountController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _onAccountChanged() {
    final String acc = _accountController.text.trim();
    if (acc.length == 10 && _selectedBankCode != null) {
      _performNameEnquiry(acc, _selectedBankCode!);
    } else {
      if (_resolvedName != null) {
        setState(() {
          _resolvedName = null;
          _nameEnquirySessionId = null;
        });
      }
    }
  }

  Future<void> _loadBanks() async {
    setState(() => _isLoadingBanks = true);
    try {
      final apiService = context.read<ApiService>();
      final res = await apiService.getBankList();
      final data = res['data'] as Map<String, dynamic>? ?? {};
      final list = data['banks'] as List<dynamic>? ?? [];
      
      setState(() {
        _fetchedBanks = list.map((item) {
          final Map<String, dynamic> map = item as Map<String, dynamic>;
          return {
            'name': map['bankName'] as String? ?? '',
            'code': map['bankCode'] as String? ?? '',
            'color': _getBankColor(map['bankName'] as String? ?? ''),
          };
        }).toList();
      });
    } catch (e) {
      debugPrint('Error loading bank list: $e');
    } finally {
      setState(() => _isLoadingBanks = false);
    }
  }

  Color _getBankColor(String bankName) {
    if (bankName.contains('Access')) return const Color(0xFFE55A4E);
    if (bankName.contains('Guaranty') || bankName.contains('GTB')) return const Color(0xFFE8845C);
    if (bankName.contains('Zenith')) return const Color(0xFFD32F2F);
    if (bankName.contains('First')) return const Color(0xFF19B37D);
    if (bankName.contains('UBA')) return const Color(0xFFD32F2F);
    if (bankName.contains('Opay')) return const Color(0xFF19B37D);
    if (bankName.contains('Moniepoint')) return const Color(0xFF005FAF);
    if (bankName.contains('Kuda')) return const Color(0xFF8B6FD4);
    return AppColors.accent;
  }

  Future<void> _performNameEnquiry(String accountNumber, String bankCode) async {
    setState(() {
      _isLookingUpName = true;
      _resolvedName = null;
    });

    try {
      final apiService = context.read<ApiService>();
      final res = await apiService.nameEnquiry(
        bankCode: bankCode,
        accountNumber: accountNumber,
      );
      final data = res['data'] as Map<String, dynamic>?;
      if (data != null && data['success'] == true) {
        setState(() {
          _resolvedName = data['accountName'] as String?;
          _nameEnquirySessionId = data['sessionId'] as String?;
        });
      } else {
        setState(() {
          _resolvedName = 'Name lookup failed';
        });
      }
    } catch (e) {
      setState(() {
        _resolvedName = 'Error resolving name';
      });
    } finally {
      setState(() => _isLookingUpName = false);
    }
  }

  Future<void> _continueToReview() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedBank == null || _selectedBankCode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a bank'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isEstimatingFee = true);

    double fee = 26.0;
    try {
      final apiService = context.read<ApiService>();
      final double amount = double.tryParse(
            _amountController.text.replaceAll(',', '').replaceAll(' ', ''),
          ) ?? 0;
      final res = await apiService.estimateFee(amount);
      final data = res['data'] as Map<String, dynamic>?;
      if (data != null && data['success'] == true) {
        fee = (data['fee'] as num?)?.toDouble() ?? 26.0;
      }
    } catch (e) {
      debugPrint('Error estimating fee: $e');
    } finally {
      setState(() => _isEstimatingFee = false);
    }

    final double amount =
        double.tryParse(
          _amountController.text.replaceAll(',', '').replaceAll(' ', ''),
        ) ??
        0;
    final TransferDraft draft = TransferDraft.bank(
      recipientName: _resolvedName ?? 'Resolved Recipient',
      bankName: _selectedBank!,
      accountNumber: _accountController.text.trim(),
      amount: amount,
      fee: fee,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
      bankCode: _selectedBankCode,
      sessionId: _nameEnquirySessionId,
    );

    if (mounted) {
      context.read<DemoAppState>().setTransferDraft(draft);
      context.go('/transfer/review');
    }
  }

  void _selectQuickAmount(double amount) {
    HapticFeedback.selectionClick();
    setState(() {
      _amountController.text = amount.toInt().toString();
    });
  }

  void _showBankPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Select Bank',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const TextField(
                      decoration: InputDecoration(
                        hintText: 'Search for a bank...',
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: AppColors.textSecondary,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: _isLoadingBanks && _fetchedBanks.isEmpty
                      ? const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
                          ),
                        )
                      : ListView.builder(
                          controller: scrollController,
                          itemCount: (_fetchedBanks.isNotEmpty ? _fetchedBanks : _banks).length,
                          itemBuilder: (context, index) {
                      final bank = (_fetchedBanks.isNotEmpty ? _fetchedBanks : _banks)[index];
                      return ListTile(
                        leading: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: (bank['color'] as Color).withValues(
                              alpha: 0.15,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              (bank['name'] as String).isEmpty ? '' : (bank['name'] as String).substring(0, 1),
                              style: TextStyle(
                                color: bank['color'],
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          bank['name'],
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            _selectedBank = bank['name'];
                            _selectedBankCode = bank['code'] ?? '058';
                          });
                          Navigator.pop(context);
                          if (_accountController.text.trim().length == 10) {
                            _performNameEnquiry(_accountController.text.trim(), _selectedBankCode!);
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DemoDeviceShell(
        child: Scaffold(
          backgroundColor: AppColors.shell,
          resizeToAvoidBottomInset: false,
          body: SafeArea(
            child: GestureDetector(
              onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
              behavior: HitTestBehavior.translucent,
              child: CustomScrollView(
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            AppHeader.withBack(
                              title: 'Bank Transfer',
                              subtitle: 'Send to any bank',
                              onBack: () {
                                if (context.canPop()) {
                                  context.pop();
                                } else {
                                  context.go('/home');
                                }
                              },
                            ),
                            const SizedBox(height: 24),

                            GlassCard(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Recipient Details',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  // Bank Picker Field
                                  GestureDetector(
                                    onTap: _showBankPicker,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8,
                                      ),
                                      decoration: const BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            color: AppColors.outlineVariant,
                                            width: 0.5,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.account_balance_rounded,
                                            color: AppColors.accent,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              _selectedBank ?? 'Select Bank',
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight:
                                                    _selectedBank == null
                                                    ? FontWeight.w400
                                                    : FontWeight.w600,
                                                color: _selectedBank == null
                                                    ? AppColors.textSecondary
                                                    : AppColors.textPrimary,
                                              ),
                                            ),
                                          ),
                                          const Icon(
                                            Icons.keyboard_arrow_down_rounded,
                                            color: AppColors.textSecondary,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  TextFormField(
                                    controller: _accountController,
                                    keyboardType: TextInputType.number,
                                    textInputAction: TextInputAction.next,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(10),
                                    ],
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      hintText: '10-digit Account Number',
                                      prefixIcon: Icon(
                                        Icons.numbers_rounded,
                                        color: AppColors.accent,
                                        size: 20,
                                      ),
                                      prefixIconConstraints: BoxConstraints(
                                        minWidth: 36,
                                      ),
                                    ),
                                    validator: (String? value) {
                                      if (value == null ||
                                          value.trim().length < 10) {
                                        return 'Enter a valid 10-digit account number';
                                      }
                                      return null;
                                    },
                                  ),
                                  if (_isLookingUpName)
                                    const Padding(
                                      padding: EdgeInsets.only(top: 8, left: 12),
                                      child: SizedBox(
                                        width: 14,
                                        height: 14,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 1.5,
                                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
                                        ),
                                      ),
                                    ),
                                  if (_resolvedName != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8, left: 12),
                                      child: Text(
                                        _resolvedName!,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: _resolvedName!.contains('failed') || _resolvedName!.contains('Error')
                                              ? AppColors.error
                                              : const Color(0xFF0F7A50),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 12),

                            GlassCard(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Amount',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: _amountController,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                    textInputAction: TextInputAction.next,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textPrimary,
                                    ),
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      hintText: '0.00',
                                      prefixText: '₦ ',
                                      prefixStyle: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    validator: (String? value) {
                                      final cleanValue = (value ?? '')
                                          .replaceAll(',', '')
                                          .replaceAll(' ', '');
                                      final double? parsed = double.tryParse(
                                        cleanValue,
                                      );
                                      if (parsed == null || parsed <= 0) {
                                        return 'Enter a valid amount';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  // Quick Amount Chips
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: _quickAmounts.map((amt) {
                                      return GestureDetector(
                                        onTap: () => _selectQuickAmount(amt),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.accentSoft
                                                .withValues(alpha: 0.5),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: AppColors.accentSoft,
                                            ),
                                          ),
                                          child: Text(
                                            '₦${amt.toInt()}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.accent,
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 12),

                            GlassCard(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 4,
                              ),
                              child: TextFormField(
                                controller: _noteController,
                                textInputAction: TextInputAction.done,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'What is this for? (Optional)',
                                  prefixIcon: Icon(
                                    Icons.edit_note_rounded,
                                    color: AppColors.textSecondary,
                                    size: 20,
                                  ),
                                  prefixIconConstraints: BoxConstraints(
                                    minWidth: 36,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 32),

                            PrimaryButton(
                              label: 'Review transfer',
                              isLoading: _isEstimatingFee,
                              onPressed: _continueToReview,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
