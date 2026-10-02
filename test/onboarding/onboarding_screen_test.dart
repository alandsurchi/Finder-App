import 'package:finder/l10n/l10n.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:finder/l10n/kurdish_localizations.dart';
import 'package:finder/screens/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(Locale locale) => ProviderScope(
      child: MaterialApp(
        key: ValueKey(locale),
        locale: locale,
        localizationsDelegates: const [
          ...AppLocalizations.localizationsDelegates,
          ...KurdishLocalizations.delegates,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: const OnboardingScreen(),
        routes: {'/login': (_) => const Scaffold(body: Text('LOGIN'))},
      ),
    );

void main() {
  testWidgets('three steps, Next walks through them, last step starts the app', (tester) async {
    tester.view.physicalSize = const Size(1080, 2280);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(_app(const Locale('en')));
    await tester.pumpAndSettle();
    expect(find.text('Lost something? Post it in a minute'), findsOneWidget);
    expect(find.text('Step 1 · Report'), findsOneWidget);
    expect(find.text('I already have an account'), findsOneWidget);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Found something? Help it get home'), findsOneWidget);
    expect(find.text('92% match'), findsOneWidget);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Chat, verify, hand it back safely'), findsOneWidget);
    expect(find.text('Get started'), findsOneWidget);

    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();
    expect(find.text('LOGIN'), findsOneWidget);
  });

  testWidgets('renders right-to-left in Arabic and Kurdish without overflow', (tester) async {
    tester.view.physicalSize = const Size(1080, 2280);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);

    for (final (locale, title) in [
      (const Locale('ar'), 'فقدت شيئًا؟ انشره في دقيقة'),
      (const Locale('ckb'), 'شتێکت ون کردووە؟ لە یەک خولەکدا بڵاوی بکەرەوە'),
    ]) {
      await tester.pumpWidget(_app(locale));
      await tester.pumpAndSettle();
      expect(find.text(title), findsOneWidget, reason: locale.toString());
      expect(Directionality.of(tester.element(find.text(title))), TextDirection.rtl);
      expect(tester.takeException(), isNull);
    }
  });
}
