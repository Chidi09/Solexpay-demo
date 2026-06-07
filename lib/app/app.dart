import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/router/app_router.dart';
import '../core/theme/app_theme.dart';
import '../core/services/token_service.dart';
import '../core/network/api_client.dart';
import '../core/services/api_service.dart';
import '../core/state/registration_state.dart';
import '../mock/demo_app_state.dart';
import '../core/services/biometric_service.dart';

class SolexPayApp extends StatelessWidget {
  const SolexPayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<TokenService>(create: (_) => TokenService()),
        ProxyProvider<TokenService, ApiClient>(
          update: (_, tokenService, _) => ApiClient(tokenService: tokenService),
        ),
        ProxyProvider<ApiClient, ApiService>(
          update: (_, apiClient, _) => ApiService(apiClient: apiClient),
        ),
        Provider<BiometricService>(
          create: (_) => BiometricService(),
        ),
        ChangeNotifierProvider<RegistrationState>(
          create: (_) => RegistrationState(),
        ),
        ChangeNotifierProvider<DemoAppState>(
          create: (_) => DemoAppState.seeded(),
        ),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routerConfig: appRouter,
      ),
    );
  }
}
