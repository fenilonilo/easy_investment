import 'package:easy_finance/core/theme/locale_service.dart';
import 'package:easy_finance/l10n/app_localizations.dart';
import 'package:easy_finance/presentation/views/config/config_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('trocar idioma em Config traduz a tela PT <-> EN', (t) async {
    await t.pumpWidget(ProviderScope(
      child: Consumer(
        builder: (_, ref, __) => MaterialApp(
          locale: ref.watch(localeProvider),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: const ConfigView(),
        ),
      ),
    ));
    await t.pumpAndSettle();
    expect(find.text('Configurações'), findsOneWidget);
    expect(find.text('Modo Escuro'), findsOneWidget);

    await t.tap(find.text('PT-BR'));
    await t.pumpAndSettle();
    await t.tap(find.text('EN-US').last);
    await t.pumpAndSettle();
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Dark Mode'), findsOneWidget);
    expect(find.text('Configurações'), findsNothing);

    await t.tap(find.text('EN-US'));
    await t.pumpAndSettle();
    await t.tap(find.text('PT-BR').last);
    await t.pumpAndSettle();
    expect(find.text('Configurações'), findsOneWidget);
  });
}
