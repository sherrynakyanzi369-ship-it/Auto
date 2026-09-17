// Basic widget smoke test for the AutoAssist application.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:automotive1/main.dart';

void main() {
  testWidgets('AutoAssist boots guests to the dashboard', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    await tester.pumpWidget(const AutoAssistApp());

    // Let the splash animation play out and the session check resolve.
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(seconds: 3));
    // One more frame so the guest dashboard actually builds.
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Welcome,'), findsOneWidget);
  });
}