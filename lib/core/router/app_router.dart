import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/bills/presentation/airtime_screen.dart';
import '../../features/bills/presentation/data_screen.dart';
import '../../features/card/presentation/virtual_card_screen.dart';
import '../../features/history/presentation/history_screen.dart';
import '../../features/loans/presentation/loan_preview_screen.dart';
import '../../features/loans/presentation/loan_status_screen.dart';
import '../../features/loans/presentation/loans_screen.dart';
import '../../features/profile/presentation/kyc_tiers_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/promos/presentation/promos_screen.dart';
import '../../features/savings/presentation/savings_screen.dart';
import '../../features/history/presentation/transaction_detail_screen.dart';
import '../../features/home/presentation/fund_account_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/home/presentation/notifications_screen.dart';
import '../../features/home/presentation/receive_money_screen.dart';
import '../../features/onboarding/presentation/account_created_screen.dart';
import '../../features/onboarding/presentation/bvn_screen.dart';
import '../../features/onboarding/presentation/otp_screen.dart';
import '../../features/onboarding/presentation/phone_entry_screen.dart';
import '../../features/onboarding/presentation/pin_setup_screen.dart';
import '../../features/onboarding/presentation/selfie_screen.dart';
import '../../features/onboarding/presentation/splash_screen.dart';
import '../../features/onboarding/presentation/welcome_screen.dart';
import '../../features/transfers/presentation/bank_transfer_screen.dart';
import '../../features/transfers/presentation/p2p_transfer_screen.dart';
import '../../features/transfers/presentation/pin_confirmation_screen.dart';
import '../../features/transfers/presentation/send_choice_screen.dart';
import '../../features/transfers/presentation/transfer_animation_screen.dart';
import '../../features/transfers/presentation/transfer_result_screen.dart';
import '../../features/transfers/presentation/transfer_review_screen.dart';
import '../../shared/widgets/demo_device_shell.dart';
import '../theme/app_colors.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) =>
          const SplashScreen(),
    ),
    GoRoute(
      path: '/welcome',
      builder: (BuildContext context, GoRouterState state) =>
          const WelcomeScreen(),
    ),
    GoRoute(
      path: '/phone-entry',
      builder: (BuildContext context, GoRouterState state) =>
          const PhoneEntryScreen(),
    ),
    GoRoute(
      path: '/otp',
      builder: (BuildContext context, GoRouterState state) => const OtpScreen(),
    ),
    GoRoute(
      path: '/bvn',
      builder: (BuildContext context, GoRouterState state) => const BvnScreen(),
    ),
    GoRoute(
      path: '/selfie',
      builder: (BuildContext context, GoRouterState state) =>
          const SelfieScreen(),
    ),
    GoRoute(
      path: '/account-created',
      builder: (BuildContext context, GoRouterState state) =>
          const AccountCreatedScreen(),
    ),
    GoRoute(
      path: '/pin-setup',
      builder: (BuildContext context, GoRouterState state) =>
          const PinSetupScreen(),
    ),
    GoRoute(
      path: '/shell',
      builder: (BuildContext context, GoRouterState state) {
        return const _AppShellScreen();
      },
    ),
    GoRoute(
      path: '/home',
      builder: (BuildContext context, GoRouterState state) =>
          const HomeScreen(),
    ),
    GoRoute(
      path: '/notifications',
      builder: (BuildContext context, GoRouterState state) =>
          const NotificationsScreen(),
    ),
    GoRoute(
      path: '/receive-money',
      builder: (BuildContext context, GoRouterState state) =>
          const ReceiveMoneyScreen(),
    ),
    GoRoute(
      path: '/fund-account',
      builder: (BuildContext context, GoRouterState state) =>
          const FundAccountScreen(),
    ),
    GoRoute(
      path: '/history',
      builder: (BuildContext context, GoRouterState state) =>
          const HistoryScreen(),
    ),
    GoRoute(
      path: '/history/tx/:transactionId',
      builder: (BuildContext context, GoRouterState state) {
        final String transactionId = state.pathParameters['transactionId']!;
        return TransactionDetailScreen(transactionId: transactionId);
      },
    ),
    GoRoute(
      path: '/savings',
      builder: (BuildContext context, GoRouterState state) =>
          const SavingsScreen(),
    ),
    GoRoute(
      path: '/loans',
      builder: (BuildContext context, GoRouterState state) =>
          const LoansScreen(),
    ),
    GoRoute(
      path: '/loans/preview',
      builder: (BuildContext context, GoRouterState state) =>
          const LoanPreviewScreen(),
    ),
    GoRoute(
      path: '/loans/status',
      builder: (BuildContext context, GoRouterState state) =>
          const LoanStatusScreen(),
    ),
    GoRoute(
      path: '/airtime',
      builder: (BuildContext context, GoRouterState state) =>
          const AirtimeScreen(),
    ),
    GoRoute(
      path: '/data',
      builder: (BuildContext context, GoRouterState state) =>
          const DataScreen(),
    ),
    GoRoute(
      path: '/promos',
      builder: (BuildContext context, GoRouterState state) =>
          const PromosScreen(),
    ),
    GoRoute(
      path: '/virtual-card',
      builder: (BuildContext context, GoRouterState state) =>
          const VirtualCardScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (BuildContext context, GoRouterState state) =>
          const ProfileScreen(),
    ),
    GoRoute(
      path: '/kyc-tiers',
      builder: (BuildContext context, GoRouterState state) =>
          const KycTiersScreen(),
    ),
    GoRoute(
      path: '/transfer',
      builder: (BuildContext context, GoRouterState state) =>
          const SendChoiceScreen(),
    ),
    GoRoute(
      path: '/transfer/p2p',
      builder: (BuildContext context, GoRouterState state) =>
          const P2pTransferScreen(),
    ),
    GoRoute(
      path: '/transfer/bank',
      builder: (BuildContext context, GoRouterState state) =>
          const BankTransferScreen(),
    ),
    GoRoute(
      path: '/transfer/review',
      builder: (BuildContext context, GoRouterState state) =>
          const TransferReviewScreen(),
    ),
    GoRoute(
      path: '/transfer/pin-confirm',
      builder: (BuildContext context, GoRouterState state) {
        final String nextRoute =
            state.uri.queryParameters['next'] ?? '/transfer/animation';
        return PinConfirmationScreen(nextRoute: nextRoute);
      },
    ),
    GoRoute(
      path: '/transfer/animation',
      builder: (BuildContext context, GoRouterState state) =>
          const TransferAnimationScreen(),
    ),
    GoRoute(
      path: '/transfer/result',
      builder: (BuildContext context, GoRouterState state) {
        final Object? extra = state.extra;
        if (extra is TransferResultArguments) {
          return TransferResultScreen(
            draft: extra.draft,
            outcome: extra.outcome,
          );
        }
        return const TransferResultScreen();
      },
    ),
  ],
);

class _AppShellScreen extends StatelessWidget {
  const _AppShellScreen();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: DemoDeviceShell(
        child: Scaffold(
          backgroundColor: AppColors.shell,
          body: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 12),
                Container(
                  width: 56,
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppColors.outline,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const Spacer(),
                Text('SolexPay', style: theme.textTheme.displaySmall),
                const SizedBox(height: 12),
                Text(
                  'A focused mobile demo shell for polished fintech flows.',
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.accentSoft,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(
                    'Centered on large screens, ready for feature routes.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.ink,
                    ),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
