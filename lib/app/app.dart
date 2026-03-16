import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/router/app_router.dart';
import '../core/theme/app_theme.dart';
import '../mock/demo_app_state.dart';

class SolexPayApp extends StatelessWidget {
  const SolexPayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<DemoAppState>(
      create: (_) => DemoAppState.seeded(),
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routerConfig: appRouter,
      ),
    );
  }
}
