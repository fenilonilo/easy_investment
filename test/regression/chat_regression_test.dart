import 'package:easy_finance/l10n/app_localizations.dart';
// Regressão T3 (IA Chat): B05, B07, B08, B09, B11, B12.
// Comportamento esperado vem de docs/qa/QA-SINTESE.md.
import 'dart:async';

import 'package:easy_finance/data/datasources/ai_agent_remote_datasource.dart';
import 'package:easy_finance/data/models/agent_event.dart';
import 'package:easy_finance/data/models/ai_chat_models.dart';
import 'package:easy_finance/data/repositories/ai_chat_repository_impl.dart';
import 'package:easy_finance/presentation/viewmodels/chat_viewmodel.dart';
import 'package:easy_finance/presentation/views/chat/chat_view.dart';
import 'package:easy_finance/presentation/views/chat/widgets/session_history_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/t3_chat_helpers.dart';

const _start = StartEvent(sessionId: 'sess-1', provider: 'gemini', model: 'm');
const _doneVazio = DoneEvent(
  sessionId: 'sess-1',
  provider: 'gemini',
  model: 'm',
  content: '',
);
const _doneOk = DoneEvent(
  sessionId: 'sess-1',
  provider: 'gemini',
  model: 'm',
  content: 'Olá!',
);
const _rawGoogleJson =
    '{\n  "error": {\n    "code": 503,\n    "message": "This model is currently '
    'experiencing high demand.",\n    "status": "UNAVAILABLE"\n  }\n}\n';

/// Deixa o stream/prefs (async real) terminarem e redesenha.
Future<void> _assentar(WidgetTester t) async {
  await t.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 100)),
  );
  await t.pump(const Duration(milliseconds: 500));
}

ProviderContainer _container(T3FakeChatRepository fake) {
  final c = ProviderContainer(
    overrides: [chatRepositoryProvider.overrideWithValue(fake)],
  );
  addTearDown(c.dispose);
  return c;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final seguro = <String, String>{};
  // A persistência pode usar shared_preferences OU secure storage: mocka os dois.
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    seguro.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
          (call) async {
            final a = Map<String, dynamic>.from(call.arguments as Map);
            switch (call.method) {
              case 'write':
                seguro[a['key'] as String] = a['value'] as String;
                return null;
              case 'read':
                return seguro[a['key']];
              case 'delete':
                seguro.remove(a['key']);
                return null;
              case 'containsKey':
                return seguro.containsKey(a['key']);
              case 'readAll':
                return Map<String, String>.from(seguro);
            }
            return null;
          },
        );
  });

  // ---------------------------------------------------------------- B05
  group('B05 erro seguido de done vazio', () {
    T3FakeChatRepository erroDepoisDoneVazio() => T3FakeChatRepository(
      eventos: [
        _start,
        const ErrorEvent(detail: _rawGoogleJson),
        _doneVazio,
      ],
    );

    test(
      'B05: error -> done(content vazio) não cria bolha vazia do assistente',
      () async {
        final c = _container(erroDepoisDoneVazio());

        await c.read(chatNotifierProvider.notifier).send('ok');

        final s = c.read(chatNotifierProvider);
        expect(
          s.messages.where((m) => !m.isUser && m.text.trim().isEmpty),
          isEmpty,
          reason: 'bolha vazia do assistente',
        );
        expect(s.messages.length, 2); // saudação + mensagem do usuário
        expect(s.typing, false);
      },
    );

    test(
      'B05: expõe erro amigável (sem JSON cru do provedor) para retry',
      () async {
        final c = _container(erroDepoisDoneVazio());

        await c.read(chatNotifierProvider.notifier).send('ok');

        final erro = c.read(chatNotifierProvider).error;
        expect(erro, isNotNull);
        expect(erro, isNot(contains('{')));
        expect(erro, isNot(contains('UNAVAILABLE')));
      },
    );

    test(
      'B05: done vazio SEM error anterior também vira erro, não bolha',
      () async {
        final c = _container(
          T3FakeChatRepository(eventos: [_start, _doneVazio]),
        );

        await c.read(chatNotifierProvider.notifier).send('ok');

        final s = c.read(chatNotifierProvider);
        expect(s.messages.length, 2);
        expect(s.error, isNotNull);
      },
    );

    test(
      'B05: após o erro é possível reenviar (retry) e receber resposta',
      () async {
        final fake = erroDepoisDoneVazio();
        final c = _container(fake);
        final n = c.read(chatNotifierProvider.notifier);
        await n.send('ok');

        fake.eventos = [_start, _doneOk];
        await n.send('ok');

        final s = c.read(chatNotifierProvider);
        expect(s.messages.last.text, 'Olá!');
        expect(s.error, isNull);
      },
    );
  });

  // ---------------------------------------------------------------- B07
  group('B07 timeout de requisição pendurada', () {
    // Roda o cenário no relógio fake e devolve (estado final, erros vazados).
    Future<(ChatState, List<Object>)> pendurar(WidgetTester tester) async {
      final vazados = <Object>[];
      final repo = AiChatRepositoryImpl(
        AiAgentRemoteDataSource(t3Dio(T3ScriptedAdapter.hanging())),
      );
      final c = ProviderContainer(
        overrides: [chatRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(c.dispose);
      final sub = c.listen(chatNotifierProvider, (_, __) {});
      addTearDown(sub.close);

      // Erros assíncronos sem handler caem aqui em vez de falhar o framework.
      await runZonedGuarded(() async {
        unawaited(c.read(chatNotifierProvider.notifier).send('oi'));
        await tester.pump();
        expect(c.read(chatNotifierProvider).typing, true);

        await tester.pump(const Duration(seconds: 60));
        expect(
          c.read(chatNotifierProvider).typing,
          true,
          reason: 'ainda dentro do limite',
        );

        await tester.pump(const Duration(seconds: 45)); // 105 s no relógio fake
        await tester.pump(const Duration(seconds: 5));
      }, (e, _) => vazados.add(e));
      return (c.read(chatNotifierProvider), vazados);
    }

    testWidgets(
      'B07: POST do stream que nunca responde vira erro após ~90 s (relógio fake)',
      (tester) async {
        final (s, _) = await pendurar(tester);
        expect(s.typing, false, reason: 'timeout deveria ter encerrado');
        expect(s.error, isNotNull);
        expect(s.messages.last.isUser, true); // sem bolha vazia
      },
    );

    testWidgets('B07: o timeout não vaza exceção assíncrona não tratada', (
      tester,
    ) async {
      final (_, vazados) = await pendurar(tester);
      expect(vazados, isEmpty);
    });
  });

  // ---------------------------------------------------------------- B08
  group('B08 histórico sem <additional context>', () {
    const ctx =
        '<additional context>{"nome_do_usuario":"Fenil",'
        '"perfil_de_investidor":"Conservador","watchlist":["AAPL"]}'
        '</additional context>';

    Future<ChatState> abrir(String conteudoUser) async {
      final adapter = T3ScriptedAdapter(
        (o) async => T3ScriptedAdapter.json({
          'messages': [
            {'role': 'user', 'content': conteudoUser, 'created_at': 1700000000},
            {
              'role': 'assistant',
              'content': 'ROE é...',
              'created_at': 1700000001,
            },
          ],
        }),
      );
      final repo = AiChatRepositoryImpl(
        AiAgentRemoteDataSource(t3Dio(adapter)),
      );
      final c = ProviderContainer(
        overrides: [chatRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(c.dispose);
      await c.read(chatNotifierProvider.notifier).abrirConversa('s-9');
      return c.read(chatNotifierProvider);
    }

    test(
      'B08: bloco antes da pergunta é removido da bolha do usuário',
      () async {
        final s = await abrir('$ctx\n\nO que é ROE?');
        final user = s.messages.firstWhere((m) => m.isUser);
        expect(user.text, 'O que é ROE?');
        expect(user.text, isNot(contains('additional context')));
        expect(user.text, isNot(contains('nome_do_usuario')));
      },
    );

    test(
      'B08: bloco depois da pergunta e multilinha também é removido',
      () async {
        final s = await abrir(
          'O que é ROE?\n<additional context>\n'
          '{"watchlist":\n["AAPL"]}\n</additional context>',
        );
        expect(s.messages.firstWhere((m) => m.isUser).text, 'O que é ROE?');
      },
    );

    test('B08: resposta do assistente não é alterada', () async {
      final s = await abrir('$ctx\n\nO que é ROE?');
      expect(s.messages.firstWhere((m) => !m.isUser).text, 'ROE é...');
    });
  });

  // ---------------------------------------------------------------- B09
  // "Recarregar a página" = desmontar tudo e montar um ProviderScope novo
  // sobre o mesmo armazenamento (prefs/secure storage mockados no setUp).
  group('B09 sessionId persistido', () {
    Future<ProviderContainer> abrirApp(
      WidgetTester t,
      T3FakeChatRepository fake,
    ) async {
      await t.pumpWidget(
        ProviderScope(
          key: UniqueKey(),
          overrides: [chatRepositoryProvider.overrideWithValue(fake)],
          child: MaterialApp(localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, locale: const Locale('pt'), theme: ThemeData.dark(), home: const ChatView()),
        ),
      );
      await t.pump(const Duration(milliseconds: 500));
      return ProviderScope.containerOf(t.element(find.byType(ChatView)));
    }

    Future<void> conversar(WidgetTester t, String texto) async {
      await t.enterText(find.byType(TextField), texto);
      await t.tap(find.byIcon(Icons.send_rounded));
      await _assentar(t);
    }

    testWidgets('B09: sessionId do start sobrevive a recarregar o app', (
      t,
    ) async {
      await abrirApp(t, T3FakeChatRepository(eventos: [_start, _doneOk]));
      await conversar(t, 'oi');

      final fake2 = T3FakeChatRepository(
        historico: [
          AiHistoryMessage(role: 'user', content: 'oi', createdAt: null),
          AiHistoryMessage(role: 'assistant', content: 'Olá!', createdAt: null),
        ],
      );
      final c2 = await abrirApp(t, fake2);

      expect(c2.read(chatNotifierProvider).sessionId, 'sess-1');
      expect(find.text('Olá!'), findsOneWidget, reason: 'histórico reaberto');
    });

    testWidgets(
      'B09: restaurada, a próxima mensagem reenvia o mesmo session_id',
      (t) async {
        await abrirApp(t, T3FakeChatRepository(eventos: [_start, _doneOk]));
        await conversar(t, 'oi');

        final fake2 = T3FakeChatRepository(eventos: [_start, _doneOk]);
        await abrirApp(t, fake2);
        await conversar(t, 'de novo');

        expect(fake2.ultimaSessionIdEnviada, 'sess-1');
      },
    );

    testWidgets('B09: "nova conversa" esquece a sessão persistida', (t) async {
      await abrirApp(t, T3FakeChatRepository(eventos: [_start, _doneOk]));
      await conversar(t, 'oi');
      await t.tap(find.byIcon(Icons.add_comment_outlined));
      await t.pump(const Duration(milliseconds: 500));

      final c2 = await abrirApp(t, T3FakeChatRepository());
      expect(c2.read(chatNotifierProvider).sessionId, isNull);
    });
  });

  // ---------------------------------------------------------------- UI
  Future<void> montar(
    WidgetTester t,
    T3FakeChatRepository fake,
    Widget home,
  ) async {
    await t.pumpWidget(
      ProviderScope(
        overrides: [chatRepositoryProvider.overrideWithValue(fake)],
        child: MaterialApp(localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, locale: const Locale('pt'), theme: ThemeData.dark(), home: home),
      ),
    );
  }

  Future<void> abrirComHistorico(
    WidgetTester t,
    List<AiHistoryMessage> hist,
  ) async {
    await montar(t, T3FakeChatRepository(historico: hist), const ChatView());
    final container = ProviderScope.containerOf(
      t.element(find.byType(ChatView)),
    );
    await container.read(chatNotifierProvider.notifier).abrirConversa('s');
    await t.pumpAndSettle();
  }

  group('B11 markdown', () {
    const md =
        '> citação em blockquote\n\n---\n\n'
        'Texto `inline` e bloco:\n\n```dart\nfinal x = 1;\n```\n\n'
        r'Fórmula: $$\frac{a}{b}$$ e $P/L = \frac{P}{E}$'
        '\n\n| A | B |\n|---|---|\n| 1 | 2 |\n';

    testWidgets('B11: blockquote, hr, code e LaTeX renderizam sem exceção', (
      t,
    ) async {
      await abrirComHistorico(t, [
        AiHistoryMessage(role: 'user', content: 'explique', createdAt: null),
        AiHistoryMessage(role: 'assistant', content: md, createdAt: null),
      ]);

      expect(t.takeException(), isNull);
      expect(find.textContaining('citação em blockquote'), findsOneWidget);
      expect(find.textContaining('final x = 1;'), findsOneWidget);
    });

    testWidgets('B11: markdown mal-formado/aninhado não derruba a bolha', (
      t,
    ) async {
      await abrirComHistorico(t, [
        AiHistoryMessage(
          role: 'assistant',
          content: '> > aninhado\n> ---\n```\nsem fechar\n\$\$ aberto',
          createdAt: null,
        ),
      ]);
      expect(t.takeException(), isNull);
    });
  });

  group('B12 banner, limite e confirmação', () {
    testWidgets('B12: banner não mostra JSON cru do provedor', (t) async {
      final fake = T3FakeChatRepository(
        eventos: [
          _start,
          const ErrorEvent(detail: _rawGoogleJson),
        ],
      );
      await montar(t, fake, const ChatView());
      await t.enterText(find.byType(TextField), 'ok');
      await t.tap(find.byIcon(Icons.send_rounded));
      await _assentar(t);

      expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
      expect(find.textContaining('"error"'), findsNothing);
      expect(find.textContaining('UNAVAILABLE'), findsNothing);
      expect(find.textContaining('{'), findsNothing);
    });

    testWidgets('B12: ao atingir 4000 caracteres o usuário é avisado', (
      t,
    ) async {
      await montar(t, T3FakeChatRepository(), const ChatView());
      await t.enterText(find.byType(TextField), 'a' * 4500);
      await t.pump(const Duration(milliseconds: 500));

      // O campo trunca em 4000; esperado: algum aviso/contador citando o limite.
      expect(find.textContaining('4000'), findsWidgets);
    });

    T3FakeChatRepository comUmaSessao() => T3FakeChatRepository(
      sessoes: [
        const AiSessionInfo(
          sessionId: 's-1',
          createdAt: null,
          updatedAt: null,
          runsCount: 1,
          summary: 'Conversa AAPL',
          topics: [],
        ),
      ],
    );

    testWidgets('B12: apagar sessão pede confirmação antes de chamar a API', (
      t,
    ) async {
      final fake = comUmaSessao();
      await montar(t, fake, const Scaffold(body: SessionHistorySheet()));
      await t.pumpAndSettle();

      await t.tap(find.byIcon(Icons.delete_outline_rounded));
      await t.pumpAndSettle();

      expect(fake.apagadas, isEmpty, reason: 'apagou sem confirmar');
      expect(
        find.byType(AlertDialog),
        findsOneWidget,
        reason: 'sem diálogo de confirmação',
      );
    });

    testWidgets('B12: cancelar a confirmação não apaga; confirmar apaga', (
      t,
    ) async {
      final fake = comUmaSessao();
      await montar(t, fake, const Scaffold(body: SessionHistorySheet()));
      await t.pumpAndSettle();

      final botoes = find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byWidgetPredicate(
          (w) => w is TextButton || w is ElevatedButton || w is FilledButton,
        ),
      );

      await t.tap(find.byIcon(Icons.delete_outline_rounded));
      await t.pumpAndSettle();
      expect(botoes, findsWidgets, reason: 'sem diálogo de confirmação');
      await t.tap(botoes.first); // cancelar
      await t.pumpAndSettle();
      expect(fake.apagadas, isEmpty);

      await t.tap(find.byIcon(Icons.delete_outline_rounded));
      await t.pumpAndSettle();
      await t.tap(botoes.last); // confirmar
      await t.pumpAndSettle();
      expect(fake.apagadas, ['s-1']);
    });
  });
}
