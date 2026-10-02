import 'package:finder/features/onboarding/welcome_sheet.dart';
import 'package:finder/l10n/l10n.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:finder/l10n/kurdish_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _host({required Locale locale, required Future<void> Function(BuildContext) onReady}) {
  return MaterialApp(
    key: ValueKey('${locale}_${DateTime.now().microsecondsSinceEpoch}'),
    locale: locale,
    localizationsDelegates: const [
      ...AppLocalizations.localizationsDelegates,
      ...KurdishLocalizations.delegates,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: Builder(
      builder: (context) {
        WidgetsBinding.instance.addPostFrameCallback((_) => onReady(context));
        return const Scaffold(body: SizedBox.expand());
      },
    ),
  );
}

void main() {
  testWidgets('welcome sheet shows once per install and remembers it', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(_host(locale: const Locale('en'), onReady: showWelcomeIfNeeded));
    await tester.pumpAndSettle();
    expect(find.text('Welcome to Finder'), findsOneWidget);
    expect(find.text('Open Help & Support'), findsOneWidget);

    await tester.tap(find.text('Got it'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome to Finder'), findsNothing);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('welcome_seen_v1'), isTrue);

    // Second launch: nothing.
    await tester.pumpWidget(_host(locale: const Locale('en'), onReady: showWelcomeIfNeeded));
    await tester.pumpAndSettle();
    expect(find.text('Welcome to Finder'), findsNothing);
  });

  testWidgets('welcome sheet is localised (Arabic, Kurdish)', (tester) async {
    for (final (locale, title) in [(const Locale('ar'), 'أهلًا بك في Finder'), (const Locale('ckb'), 'بەخێربێیت بۆ Finder')]) {
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(_host(locale: locale, onReady: showWelcomeIfNeeded));
      await tester.pumpAndSettle();
      expect(find.text(title), findsOneWidget, reason: locale.toString());
      expect(Directionality.of(tester.element(find.text(title))), TextDirection.rtl);
    }
  });
}
