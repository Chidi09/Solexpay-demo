import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../mock/demo_app_state.dart';
import '../../../../mock/mock_transfer_service.dart';
import '../../../../shared/models/transfer_draft.dart';
import '../../../../shared/utils/currency_formatter.dart';
import '../../../../shared/widgets/demo_device_shell.dart';
import '../../../../shared/widgets/page_header.dart';
import 'transfer_result_screen.dart';

class TransferAnimationScreen extends StatefulWidget {
  const TransferAnimationScreen({
    super.key,
    this.draft,
    this.service = const MockTransferService(),
  });

  final TransferDraft? draft;
  final MockTransferService service;

  @override
  State<TransferAnimationScreen> createState() =>
      _TransferAnimationScreenState();
}

class _TransferAnimationScreenState extends State<TransferAnimationScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _travelController;
  bool _hasStarted = false;

  @override
  void initState() {
    super.initState();
    _travelController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat(reverse: true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _runTransferFlow();
    });
  }

  Future<void> _runTransferFlow() async {
    if (_hasStarted || !mounted) {
      return;
    }
    _hasStarted = true;

    final DemoAppState? appState = Provider.of<DemoAppState?>(
      context,
      listen: false,
    );
    final TransferDraft? resolvedDraft =
        widget.draft ?? appState?.activeTransferDraft;
    if (resolvedDraft == null) {
      return;
    }
    if (appState == null) {
      return;
    }

    final TransferOutcome outcome = await widget.service.submitTransfer(
      resolvedDraft,
    );
    if (!mounted) {
      return;
    }

    await appState.completeTransfer(resolvedDraft, outcome: outcome);
    if (!mounted) {
      return;
    }

    context.go(
      '/transfer/result',
      extra: TransferResultArguments(draft: resolvedDraft, outcome: outcome),
    );
  }

  @override
  void dispose() {
    _travelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final DemoAppState? appState = context.watch<DemoAppState?>();
    final bool hasStateProvider = appState != null;
    final TransferDraft? resolvedDraft =
        widget.draft ?? appState?.activeTransferDraft;

    return Scaffold(
      body: DemoDeviceShell(
        child: Scaffold(
          backgroundColor: AppColors.shell,
          resizeToAvoidBottomInset: false,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: resolvedDraft == null
                  ? const Center(child: Text('No transfer in progress.'))
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const PageHeader(
                          title: 'Processing money transfer',
                          subtitle:
                              'We are processing this transfer securely now.',
                        ),
                        const SizedBox(height: 36),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.outline),
                          ),
                          child: Column(
                            children: <Widget>[
                              hasStateProvider
                                  ? Text(
                                      CurrencyFormatter.format(
                                        resolvedDraft.amount,
                                      ),
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ).animate().fadeIn().slideY(begin: 0.25)
                                  : Text(
                                      CurrencyFormatter.format(
                                        resolvedDraft.amount,
                                      ),
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                              const SizedBox(height: 12),
                              AnimatedBuilder(
                                animation: _travelController,
                                builder: (BuildContext context, Widget? child) {
                                  final double glow =
                                      0.4 + (_travelController.value * 0.6);
                                  return Container(
                                    width: 72,
                                    height: 72,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.accent.withValues(
                                        alpha: glow,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.arrow_forward_rounded,
                                      color: Colors.white,
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 12),
                              hasStateProvider
                                  ? Text(
                                      'To ${resolvedDraft.recipientName}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            color: AppColors.textPrimary,
                                          ),
                                    ).animate().shimmer(
                                      duration: const Duration(
                                        milliseconds: 1200,
                                      ),
                                      color: AppColors.accentSoft,
                                    )
                                  : Text(
                                      'To ${resolvedDraft.recipientName}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            color: AppColors.textPrimary,
                                          ),
                                    ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        const LinearProgressIndicator(minHeight: 6),
                        const SizedBox(height: 12),
                        Text(
                          'Sending...',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.textSecondary),
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
