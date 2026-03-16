# SolexPay Flutter Demo Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build a polished SolexPay Flutter design demo from a blank workspace using mock data, realistic fintech flows, and a premium transfer animation that can be demoed in Chrome or on a phone.

**Architecture:** Start from a fresh Flutter app scaffold, then add a feature-first `lib/` structure with a shared theme, router, mock repositories, and reusable widgets. Keep state lightweight with `provider`, drive all feature screens from seeded mock data, and implement the transfer animation as a dedicated presentation flow that feeds directly into the transfer result screen.

**Tech Stack:** Flutter, Dart, provider, go_router, google_fonts, flutter_animate, Flutter widget tests, mock data only

---

### Task 1: Scaffold the Flutter project

**Files:**
- Create: `pubspec.yaml`
- Create: `lib/main.dart`
- Create: `android/`
- Create: `web/`
- Create: `test/widget_test.dart`

**Step 1: Generate the Flutter project scaffold**

Run:

```bash
flutter create .
```

Expected: Flutter creates the standard app structure in `C:\Users\IFEANYI PC\Solexpay-demo-app`.

**Step 2: Verify the generated baseline app runs**

Run:

```bash
flutter test
```

Expected: the default counter test passes.

**Step 3: Commit the generated baseline**

```bash
git add pubspec.yaml lib/main.dart test/widget_test.dart android web
git commit -m "chore: scaffold Flutter demo app"
```

### Task 2: Add dependencies and app shell

**Files:**
- Modify: `pubspec.yaml`
- Create: `lib/app/app.dart`
- Create: `lib/core/router/app_router.dart`
- Create: `lib/core/theme/app_theme.dart`
- Create: `lib/core/theme/app_colors.dart`
- Create: `lib/core/theme/app_text_styles.dart`
- Create: `lib/shared/widgets/demo_device_shell.dart`
- Modify: `lib/main.dart`
- Test: `test/app/app_shell_test.dart`

**Step 1: Write the failing app shell test**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:solexpay_demo_app/app/app.dart';

void main() {
  testWidgets('app renders SolexPay shell', (tester) async {
    await tester.pumpWidget(const SolexPayApp());

    expect(find.text('SolexPay'), findsOneWidget);
  });
}
```

**Step 2: Run the test and verify it fails**

Run:

```bash
flutter test test/app/app_shell_test.dart
```

Expected: FAIL because `SolexPayApp` does not exist yet.

**Step 3: Add dependencies to `pubspec.yaml`**

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  go_router: ^14.8.1
  provider: ^6.1.2
  google_fonts: ^6.2.1
  flutter_animate: ^4.5.2
  intl: ^0.19.0
```

**Step 4: Create the app shell and theme wiring**

Create a minimal `SolexPayApp` that wraps `MaterialApp.router`, registers the router, and shows a centered mobile shell on large screens.

```dart
class SolexPayApp extends StatelessWidget {
  const SolexPayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: appRouter,
    );
  }
}
```

**Step 5: Re-run the test and verify it passes**

Run:

```bash
flutter test test/app/app_shell_test.dart
```

Expected: PASS.

**Step 6: Commit**

```bash
git add pubspec.yaml lib/main.dart lib/app/app.dart lib/core/router/app_router.dart lib/core/theme/app_theme.dart lib/core/theme/app_colors.dart lib/core/theme/app_text_styles.dart lib/shared/widgets/demo_device_shell.dart test/app/app_shell_test.dart
git commit -m "feat: add app shell and theme foundation"
```

### Task 3: Create shared models, formatters, and mock app state

**Files:**
- Create: `lib/shared/models/user_profile.dart`
- Create: `lib/shared/models/transaction_item.dart`
- Create: `lib/shared/models/notification_item.dart`
- Create: `lib/shared/models/loan_state.dart`
- Create: `lib/shared/models/transfer_draft.dart`
- Create: `lib/core/constants/demo_data.dart`
- Create: `lib/core/constants/app_copy.dart`
- Create: `lib/mock/demo_app_state.dart`
- Create: `lib/mock/mock_transfer_service.dart`
- Create: `lib/mock/mock_auth_service.dart`
- Create: `lib/shared/utils/currency_formatter.dart`
- Test: `test/mock/demo_app_state_test.dart`

**Step 1: Write the failing state test**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:solexpay_demo_app/mock/demo_app_state.dart';

void main() {
  test('seeded state starts with transactions and positive balance', () {
    final state = DemoAppState.seeded();

    expect(state.balance, greaterThan(0));
    expect(state.transactions, isNotEmpty);
  });
}
```

**Step 2: Run the test and verify it fails**

Run:

```bash
flutter test test/mock/demo_app_state_test.dart
```

Expected: FAIL because `DemoAppState` does not exist yet.

**Step 3: Implement minimal seeded demo state**

Create `DemoAppState.seeded()` with mock profile, balance, savings, notifications, and at least 5 transactions.

```dart
factory DemoAppState.seeded() {
  return DemoAppState(
    balance: 47500,
    savingsBalance: 12500,
    transactions: demoTransactions,
    notifications: demoNotifications,
  );
}
```

**Step 4: Re-run the test and verify it passes**

Run:

```bash
flutter test test/mock/demo_app_state_test.dart
```

Expected: PASS.

**Step 5: Commit**

```bash
git add lib/shared/models lib/core/constants lib/mock lib/shared/utils test/mock/demo_app_state_test.dart
git commit -m "feat: add seeded demo state and mock models"
```

### Task 4: Build shared UI primitives

**Files:**
- Create: `lib/shared/widgets/primary_button.dart`
- Create: `lib/shared/widgets/glass_card.dart`
- Create: `lib/shared/widgets/page_header.dart`
- Create: `lib/shared/widgets/action_tile.dart`
- Create: `lib/shared/widgets/balance_card.dart`
- Create: `lib/shared/widgets/transaction_tile.dart`
- Create: `lib/shared/widgets/pin_pad.dart`
- Create: `lib/shared/widgets/status_badge.dart`
- Test: `test/shared/widgets/balance_card_test.dart`

**Step 1: Write the failing balance card test**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solexpay_demo_app/shared/widgets/balance_card.dart';

void main() {
  testWidgets('balance card renders account balance', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: BalanceCard(balance: 47500, accountNumber: '0123 456 789'),
        ),
      ),
    );

    expect(find.textContaining('47,500'), findsOneWidget);
  });
}
```

**Step 2: Run the test and verify it fails**

Run:

```bash
flutter test test/shared/widgets/balance_card_test.dart
```

Expected: FAIL because `BalanceCard` does not exist.

**Step 3: Implement the shared widgets minimally**

Start with `BalanceCard` and supporting button/card primitives. Keep the styling consistent with the navy/green SolexPay palette.

**Step 4: Re-run the test and verify it passes**

Run:

```bash
flutter test test/shared/widgets/balance_card_test.dart
```

Expected: PASS.

**Step 5: Commit**

```bash
git add lib/shared/widgets test/shared/widgets/balance_card_test.dart
git commit -m "feat: add shared fintech UI primitives"
```

### Task 5: Build onboarding and auth demo screens

**Files:**
- Create: `lib/features/onboarding/presentation/splash_screen.dart`
- Create: `lib/features/onboarding/presentation/welcome_screen.dart`
- Create: `lib/features/onboarding/presentation/phone_entry_screen.dart`
- Create: `lib/features/onboarding/presentation/otp_screen.dart`
- Create: `lib/features/onboarding/presentation/bvn_screen.dart`
- Create: `lib/features/onboarding/presentation/selfie_screen.dart`
- Create: `lib/features/onboarding/presentation/account_created_screen.dart`
- Create: `lib/features/onboarding/presentation/pin_setup_screen.dart`
- Modify: `lib/core/router/app_router.dart`
- Test: `test/features/onboarding/welcome_screen_test.dart`

**Step 1: Write the failing welcome screen test**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solexpay_demo_app/features/onboarding/presentation/welcome_screen.dart';

void main() {
  testWidgets('welcome screen shows get started CTA', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: WelcomeScreen()));

    expect(find.text('Get Started'), findsOneWidget);
  });
}
```

**Step 2: Run the test and verify it fails**

Run:

```bash
flutter test test/features/onboarding/welcome_screen_test.dart
```

Expected: FAIL because the onboarding screens do not exist.

**Step 3: Implement the onboarding screens and route wiring**

Keep state local for form inputs. Use mock delays for OTP and selfie progress so the sequence feels real.

**Step 4: Re-run the test and verify it passes**

Run:

```bash
flutter test test/features/onboarding/welcome_screen_test.dart
```

Expected: PASS.

**Step 5: Commit**

```bash
git add lib/features/onboarding lib/core/router/app_router.dart test/features/onboarding/welcome_screen_test.dart
git commit -m "feat: add onboarding and KYC demo screens"
```

### Task 6: Build the home dashboard and core browse screens

**Files:**
- Create: `lib/features/home/presentation/home_screen.dart`
- Create: `lib/features/home/presentation/notifications_screen.dart`
- Create: `lib/features/home/presentation/receive_money_screen.dart`
- Create: `lib/features/home/presentation/fund_account_screen.dart`
- Create: `lib/features/history/presentation/history_screen.dart`
- Create: `lib/features/history/presentation/transaction_detail_screen.dart`
- Modify: `lib/core/router/app_router.dart`
- Test: `test/features/home/home_screen_test.dart`

**Step 1: Write the failing home screen test**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:solexpay_demo_app/features/home/presentation/home_screen.dart';
import 'package:solexpay_demo_app/mock/demo_app_state.dart';

void main() {
  testWidgets('home screen shows recent activity and balance', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => DemoAppState.seeded(),
        child: const MaterialApp(home: HomeScreen()),
      ),
    );

    expect(find.text('Recent activity'), findsOneWidget);
  });
}
```

**Step 2: Run the test and verify it fails**

Run:

```bash
flutter test test/features/home/home_screen_test.dart
```

Expected: FAIL because `HomeScreen` does not exist.

**Step 3: Implement home, notifications, receive, fund account, history, and transaction detail**

Use the seeded provider state to populate lists and balances. Make the home dashboard the visual centerpiece of the demo.

**Step 4: Re-run the test and verify it passes**

Run:

```bash
flutter test test/features/home/home_screen_test.dart
```

Expected: PASS.

**Step 5: Commit**

```bash
git add lib/features/home lib/features/history lib/core/router/app_router.dart test/features/home/home_screen_test.dart
git commit -m "feat: add dashboard and transaction browsing flows"
```

### Task 7: Build transfer forms and review flow

**Files:**
- Create: `lib/features/transfers/presentation/send_choice_screen.dart`
- Create: `lib/features/transfers/presentation/p2p_transfer_screen.dart`
- Create: `lib/features/transfers/presentation/bank_transfer_screen.dart`
- Create: `lib/features/transfers/presentation/transfer_review_screen.dart`
- Create: `lib/features/transfers/presentation/pin_confirmation_screen.dart`
- Modify: `lib/mock/demo_app_state.dart`
- Modify: `lib/core/router/app_router.dart`
- Test: `test/features/transfers/transfer_review_screen_test.dart`

**Step 1: Write the failing transfer review test**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solexpay_demo_app/features/transfers/presentation/transfer_review_screen.dart';
import 'package:solexpay_demo_app/shared/models/transfer_draft.dart';

void main() {
  testWidgets('transfer review shows total deducted', (tester) async {
    final draft = TransferDraft.p2p(
      recipientName: 'John Doe',
      amount: 2000,
    );

    await tester.pumpWidget(
      MaterialApp(home: TransferReviewScreen(draft: draft)),
    );

    expect(find.textContaining('Total deducted'), findsOneWidget);
  });
}
```

**Step 2: Run the test and verify it fails**

Run:

```bash
flutter test test/features/transfers/transfer_review_screen_test.dart
```

Expected: FAIL because transfer review UI does not exist.

**Step 3: Implement the transfer forms, draft model flow, and PIN confirmation**

Ensure P2P uses `fee = 0` and bank transfer applies a mock fee, for example `26`.

**Step 4: Re-run the test and verify it passes**

Run:

```bash
flutter test test/features/transfers/transfer_review_screen_test.dart
```

Expected: PASS.

**Step 5: Commit**

```bash
git add lib/features/transfers lib/mock/demo_app_state.dart lib/core/router/app_router.dart test/features/transfers/transfer_review_screen_test.dart
git commit -m "feat: add transfer entry and review flow"
```

### Task 8: Implement the transfer animation and result states

**Files:**
- Create: `lib/features/transfers/presentation/transfer_animation_screen.dart`
- Create: `lib/features/transfers/presentation/transfer_result_screen.dart`
- Modify: `lib/mock/mock_transfer_service.dart`
- Modify: `lib/mock/demo_app_state.dart`
- Modify: `lib/core/router/app_router.dart`
- Test: `test/features/transfers/transfer_animation_screen_test.dart`

**Step 1: Write the failing animation test**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solexpay_demo_app/features/transfers/presentation/transfer_animation_screen.dart';
import 'package:solexpay_demo_app/shared/models/transfer_draft.dart';

void main() {
  testWidgets('transfer animation shows sending state', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: TransferAnimationScreen(
          draft: TransferDraft.p2p(recipientName: 'John Doe', amount: 2000),
        ),
      ),
    );

    expect(find.textContaining('Sending'), findsOneWidget);
  });
}
```

**Step 2: Run the test and verify it fails**

Run:

```bash
flutter test test/features/transfers/transfer_animation_screen_test.dart
```

Expected: FAIL because the animation screen does not exist.

**Step 3: Implement the transfer animation and post-animation routing**

Use `flutter_animate` plus one custom `AnimationController` to stage sender compression, amount travel, recipient glow, and result transition. Support `success`, `pending`, and `failed` outcomes.

**Step 4: Re-run the test and verify it passes**

Run:

```bash
flutter test test/features/transfers/transfer_animation_screen_test.dart
```

Expected: PASS.

**Step 5: Add an app-state test for transfer completion**

```dart
test('successful transfer updates balance and prepends transaction', () async {
  final state = DemoAppState.seeded();
  final before = state.balance;

  await state.completeTransfer(
    TransferDraft.p2p(recipientName: 'John Doe', amount: 2000),
  );

  expect(state.balance, before - 2000);
  expect(state.transactions.first.title, contains('John Doe'));
});
```

Run:

```bash
flutter test test/mock/demo_app_state_test.dart
```

Expected: PASS after implementation.

**Step 6: Commit**

```bash
git add lib/features/transfers/presentation/transfer_animation_screen.dart lib/features/transfers/presentation/transfer_result_screen.dart lib/mock/mock_transfer_service.dart lib/mock/demo_app_state.dart lib/core/router/app_router.dart test/features/transfers/transfer_animation_screen_test.dart test/mock/demo_app_state_test.dart
git commit -m "feat: add animated transfer completion flow"
```

### Task 9: Build savings and loans screens

**Files:**
- Create: `lib/features/savings/presentation/savings_screen.dart`
- Create: `lib/features/loans/presentation/loans_screen.dart`
- Create: `lib/features/loans/presentation/loan_preview_screen.dart`
- Create: `lib/features/loans/presentation/loan_status_screen.dart`
- Modify: `lib/mock/demo_app_state.dart`
- Modify: `lib/core/router/app_router.dart`
- Test: `test/features/savings/savings_screen_test.dart`

**Step 1: Write the failing savings screen test**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:solexpay_demo_app/features/savings/presentation/savings_screen.dart';
import 'package:solexpay_demo_app/mock/demo_app_state.dart';

void main() {
  testWidgets('savings screen shows total saved', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => DemoAppState.seeded(),
        child: const MaterialApp(home: SavingsScreen()),
      ),
    );

    expect(find.textContaining('Total Saved'), findsOneWidget);
  });
}
```

**Step 2: Run the test and verify it fails**

Run:

```bash
flutter test test/features/savings/savings_screen_test.dart
```

Expected: FAIL because `SavingsScreen` does not exist.

**Step 3: Implement savings and loan demo screens**

The savings screen should support mock top-up and withdraw actions. The loan screens should show either eligibility or an active repayment state from seeded data.

**Step 4: Re-run the test and verify it passes**

Run:

```bash
flutter test test/features/savings/savings_screen_test.dart
```

Expected: PASS.

**Step 5: Commit**

```bash
git add lib/features/savings lib/features/loans lib/mock/demo_app_state.dart lib/core/router/app_router.dart test/features/savings/savings_screen_test.dart
git commit -m "feat: add savings and loan showcase screens"
```

### Task 10: Build bills, promos, virtual card, and profile screens

**Files:**
- Create: `lib/features/bills/presentation/airtime_screen.dart`
- Create: `lib/features/bills/presentation/data_screen.dart`
- Create: `lib/features/promos/presentation/promos_screen.dart`
- Create: `lib/features/card/presentation/virtual_card_screen.dart`
- Create: `lib/features/profile/presentation/profile_screen.dart`
- Modify: `lib/core/router/app_router.dart`
- Test: `test/features/bills/airtime_screen_test.dart`

**Step 1: Write the failing airtime screen test**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solexpay_demo_app/features/bills/presentation/airtime_screen.dart';

void main() {
  testWidgets('airtime screen shows cashback offer', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AirtimeScreen()));

    expect(find.textContaining('Cashback'), findsOneWidget);
  });
}
```

**Step 2: Run the test and verify it fails**

Run:

```bash
flutter test test/features/bills/airtime_screen_test.dart
```

Expected: FAIL because `AirtimeScreen` does not exist.

**Step 3: Implement the bills, promos, virtual card, and profile screens**

Keep these screens polished but secondary to the core transfer demo. The virtual card remains a showcase extra rather than the product centerpiece.

**Step 4: Re-run the test and verify it passes**

Run:

```bash
flutter test test/features/bills/airtime_screen_test.dart
```

Expected: PASS.

**Step 5: Commit**

```bash
git add lib/features/bills lib/features/promos lib/features/card lib/features/profile lib/core/router/app_router.dart test/features/bills/airtime_screen_test.dart
git commit -m "feat: add supporting product showcase screens"
```

### Task 11: Add polish, web-demo verification, and final test pass

**Files:**
- Modify: `lib/**`
- Modify: `test/**`
- Create: `README.md`

**Step 1: Run the full test suite**

Run:

```bash
flutter test
```

Expected: all widget and state tests pass.

**Step 2: Run the app in Chrome demo mode**

Run:

```bash
flutter run -d chrome
```

Expected: the app launches in a centered mobile shell and all major routes are clickable.

**Step 3: Fix any visual or navigation gaps discovered during the run**

Focus on:

- broken routes
- overflow on narrow layout
- animation timing issues
- inconsistent spacing
- dead-end CTA buttons

**Step 4: Add a short project README**

Document:

- what this demo is
- how to run it in Chrome
- how to run tests
- where mock data lives

**Step 5: Re-run verification**

Run:

```bash
flutter test && flutter run -d chrome
```

Expected: tests pass and the app launches successfully.

**Step 6: Commit**

```bash
git add lib test README.md
git commit -m "feat: finish SolexPay Flutter design demo"
```

## Notes for Execution

- This environment currently does not have `flutter` or `dart` installed, so execution should start only after the Flutter SDK is installed and available on `PATH`.
- If Android Studio is still unavailable, use Chrome for the first demo pass.
- Keep generated Flutter files generated; avoid manually recreating large generated folders.
- Preserve the strong visual identity from the React concept, but favor clarity on financial screens over decorative noise.
