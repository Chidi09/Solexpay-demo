import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:solexpay_demo_app/core/network/api_client.dart';
import 'package:solexpay_demo_app/core/services/api_service.dart';
import 'package:solexpay_demo_app/core/services/token_service.dart';
import 'package:solexpay_demo_app/features/savings/presentation/savings_screen.dart';
import 'package:solexpay_demo_app/mock/demo_app_state.dart';

void main() {
  testWidgets('savings screen shows total saved', (WidgetTester tester) async {
    final tokenService = TokenService();
    final apiClient = ApiClient(tokenService: tokenService);
    final apiService = ApiService(apiClient: apiClient);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<TokenService>.value(value: tokenService),
          Provider<ApiClient>.value(value: apiClient),
          Provider<ApiService>.value(value: apiService),
          ChangeNotifierProvider<DemoAppState>(
            create: (_) => DemoAppState.seeded(),
          ),
        ],
        child: const MaterialApp(home: SavingsScreen()),
      ),
    );

    // Pump once to build, then pump a frame to flush animation timers
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.textContaining('Total Saved'), findsOneWidget);
  });
}
