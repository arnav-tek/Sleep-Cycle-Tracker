// Smoke test for the LunaSleep application.
//
// Verifies the app can boot and render the main scaffold
// with bottom navigation without crashing.

import 'package:flutter_test/flutter_test.dart';
import 'package:sleep_cycle_alarm/main.dart';

void main() {
  testWidgets('App boots and renders bottom navigation',
      (WidgetTester tester) async {
    await tester.pumpWidget(const SleepCycleApp());
    await tester.pumpAndSettle();

    // Verify the five bottom-nav items render
    expect(find.text('Dash'), findsOneWidget);
    expect(find.text('Sleep'), findsOneWidget);
    expect(find.text('History'), findsOneWidget);
    expect(find.text('Wake'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });
}
