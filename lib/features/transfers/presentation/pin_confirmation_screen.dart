import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../mock/demo_app_state.dart';
import '../../../../shared/models/transfer_draft.dart';
import '../../../../shared/widgets/app_header.dart';
import '../../../../shared/widgets/demo_device_shell.dart';
import '../../../../shared/widgets/pin_pad.dart';

class PinConfirmationScreen extends StatefulWidget {
  const PinConfirmationScreen({super.key, this.nextRoute = '/home'});

  final String nextRoute;

  @override
  State<PinConfirmationScreen> createState() => _PinConfirmationScreenState();
}

class _PinConfirmationScreenState extends State<PinConfirmationScreen> {
  final List<int> _pinDigits = <int>[];

  void _onDigitPressed(int digit) {
    if (_pinDigits.length >= 4) {
      return;
    }
    setState(() {
      _pinDigits.add(digit);
    });
    if (_pinDigits.length == 4) {
      _submitPin();
    }
  }

  void _onBackspace() {
    if (_pinDigits.isEmpty) {
      return;
    }
    setState(() {
      _pinDigits.removeLast();
    });
  }

  void _submitPin() {
    final String pinStr = _pinDigits.join();
    final Uri parsedUri = Uri.parse(widget.nextRoute);
    final String nextWithPin = parsedUri.replace(
      queryParameters: {
        ...parsedUri.queryParameters,
        'pin': pinStr,
      },
    ).toString();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('PIN confirmed.')));
    context.go(nextWithPin);
  }

  @override
  Widget build(BuildContext context) {
    final TransferDraft? draft = context
        .watch<DemoAppState>()
        .activeTransferDraft;

    return Scaffold(
      body: DemoDeviceShell(
        child: Scaffold(
          backgroundColor: AppColors.shell,
          resizeToAvoidBottomInset: false,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: draft == null
                  ? const Center(child: Text('No transfer in progress.'))
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        AppHeader.withBack(
                          title: 'Confirm PIN',
                          subtitle: 'Authorize transaction',
                          onBack: () {
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go('/transfer');
                            }
                          },
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List<Widget>.generate(4, (int index) {
                            return Container(
                              width: 14,
                              height: 14,
                              margin: const EdgeInsets.symmetric(horizontal: 7),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: index < _pinDigits.length
                                    ? AppColors.accent
                                    : AppColors.outline,
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 32),
                        PinPad(
                          onDigitPressed: _onDigitPressed,
                          onBackspace: _onBackspace,
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
