import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solexpay_demo_app/app/app.dart';
import 'package:solexpay_demo_app/shared/widgets/demo_device_shell.dart';

void main() {
  testWidgets('app renders SolexPay shell', (tester) async {
    await tester.pumpWidget(const SolexPayApp());

    expect(find.text('SolexPay'), findsOneWidget);
  });

  testWidgets('device shell does not frame narrow layouts', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(
        home: DemoDeviceShell(
          child: Scaffold(body: Text('Narrow layout')),
        ),
      ),
    );

    expect(find.text('Narrow layout'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('demo-framed-shell')), findsNothing);
  });
}
