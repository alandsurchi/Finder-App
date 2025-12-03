// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:finder/main.dart';

void main() {
  testWidgets('Onboarding screen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that our onboarding screen starts with the first page.
    expect(find.text('Lost Something?'), findsOneWidget);
    expect(find.text('Found Something?'), findsNothing);

    // Tap the 'Next' button and trigger a frame.
    // Note: Finding the button might require a key or finding by text/icon.
    // Since we have a complex button, finding by text "Next" is good.
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle(); // Wait for animation

    // Verify that we are on the second page.
    expect(find.text('Found Something?'), findsOneWidget);
  });
}
