import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:finder/l10n/kurdish_localizations.dart';
import 'package:finder/l10n/l10n.dart';
import 'package:finder/screens/onboarding_screen.dart';

Widget _app(Locale locale) {
  return ProviderScope(
    child: MaterialApp(
      locale: locale,
      supportedLocales: kSupportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ...KurdishLocalizations.delegates,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const OnboardingScreen(),
    ),
  );
}

void main() {
  testWidgets('Onboarding screen smoke test', (WidgetTester tester) async {
    // Build onboarding directly to keep this test independent from Firebase init.
    await tester.pumpWidget(_app(const Locale('en')));
    await tester.pumpAndSettle();

    expect(find.text('Lost Something?'), findsOneWidget);
    expect(find.text('Found Something?'), findsNothing);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Found Something?'), findsOneWidget);
  });

  testWidgets('Arabic renders right-to-left with translated copy', (tester) async {
    await tester.pumpWidget(_app(const Locale('ar')));
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(OnboardingScreen));
    expect(Directionality.of(context), TextDirection.rtl);
    expect(find.text('فقدت شيئًا؟'), findsOneWidget);
    expect(find.text('Lost Something?'), findsNothing);
  });

  testWidgets('Kurdish (Sorani) is supported and right-to-left', (tester) async {
    await tester.pumpWidget(_app(const Locale('ckb')));
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(OnboardingScreen));
    expect(Directionality.of(context), TextDirection.rtl);
    expect(find.text('شتێکت ون کردووە؟'), findsOneWidget);
    // Flutter's own widget strings come from the Kurdish delegate.
    expect(MaterialLocalizations.of(context).okButtonLabel, 'باشە');
    expect(MaterialLocalizations.of(context).formatMonthYear(DateTime(2026, 10)),
        'تشرینی یەکەم 2026');
  });
}
