import 'package:easy_finance/l10n/app_localizations.dart';
// Regressao T4 (Inicio): B16, B17, B18, B20, B28. Ver docs/qa/QA-SINTESE.md.
import 'package:easy_finance/core/constants/app_colors.dart';
import 'package:easy_finance/core/utils/formatters.dart';
import 'package:easy_finance/core/widgets/error_view.dart';
import 'package:easy_finance/data/models/asset_model.dart';
import 'package:easy_finance/data/models/asset_quote_model.dart';
import 'package:easy_finance/data/models/history_point_model.dart';
import 'package:easy_finance/data/models/news_item_model.dart';
import 'package:easy_finance/data/repositories/asset_repository_impl.dart';
import 'package:easy_finance/data/repositories/watchlist_repository_impl.dart';
import 'package:easy_finance/presentation/viewmodels/home_viewmodel.dart';
import 'package:easy_finance/presentation/views/home/home_view.dart';
import 'package:easy_finance/presentation/views/home/widgets/asset_card_widget.dart';
import 'package:easy_finance/presentation/views/home/widgets/historical_chart_card.dart';
import 'package:easy_finance/presentation/views/home/widgets/horizontal_news_card.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher_platform_interface/link.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

import '../helpers/fake_repositories.dart';

const _aapl = AssetModel(ticker: 'AAPL', name: 'Apple', iconUrl: '');
const _petr = AssetModel(ticker: 'PETR4.SA', name: 'Petrobras', iconUrl: '');

AssetQuoteModel _q(String t, String dir) => AssetQuoteModel(
  ticker: t,
  name: t,
  iconUrl: '',
  priceUsd: 10,
  direction: dir,
);

const _pts = [
  HistoryPointModel(date: '2026-09-01', close: 10),
  HistoryPointModel(date: '2026-09-02', close: 11),
  HistoryPointModel(date: '2026-09-03', close: 12),
];

NewsItemModel _news(String t) => NewsItemModel(
  title: t,
  link: 'http://x/$t',
  publisher: 'pub',
  providerPublishTime: '2026-09-01T10:00:00',
);

Widget _wrap(Widget w) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, locale: const Locale('pt'), 
  home: Scaffold(body: SingleChildScrollView(child: w)),
);

/// Cor do icone de direcao (seta/neutro) dentro de [card].
Color? _dirIconColor(WidgetTester t, Finder card) {
  final icon = t.widget<Icon>(
    find
        .descendant(
          of: card,
          matching: find.byWidgetPredicate(
            (w) =>
                w is Icon &&
                (w.icon == Icons.arrow_upward_rounded ||
                    w.icon == Icons.arrow_downward_rounded ||
                    w.icon == Icons.remove_rounded ||
                    w.icon == Icons.arrow_forward_rounded ||
                    w.icon == Icons.trending_flat_rounded),
          ),
        )
        .first,
  );
  return icon.color;
}

void main() {
  late MockWatchlistRepository wl;
  late MockAssetRepository assets;

  setUp(() {
    wl = MockWatchlistRepository();
    assets = MockAssetRepository();
    SharedPreferences.setMockInitialValues({});
    when(() => assets.getNews(any())).thenAnswer((_) async => []);
    when(() => assets.getHistory(any(), any())).thenAnswer((_) async => _pts);
  });

  ProviderContainer container() {
    final c = ProviderContainer(
      overrides: [
        watchlistRepositoryProvider.overrideWithValue(wl),
        assetRepositoryProvider.overrideWithValue(assets),
      ],
    );
    addTearDown(() async {
      await Future.delayed(const Duration(milliseconds: 50));
      c.dispose();
    });
    return c;
  }

  Future<void> pumpHome(WidgetTester tester) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container(),
        child: MaterialApp(localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, locale: const Locale('pt'), home: const HomeView()),
      ),
    );
    // sem pumpAndSettle: NewsTicker tem Timer periodico
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  void quotesOk() {
    when(() => wl.getWatchlist()).thenAnswer((_) async => [_aapl]);
    when(() => assets.getQuote(any())).thenAnswer(
      (i) async => _q(i.positionalArguments[0] as String, 'subindo'),
    );
  }

  group('B16 direction estavel', () {
    test('B16 formatter: estavel nao e down nem up', () {
      expect(Formatters.directionLabel('estável'), isNot('down'));
      expect(Formatters.directionLabel('estável'), isNot('up'));
    });

    test('B16 formatter: subindo=up, descendo=down', () {
      expect(Formatters.directionLabel('subindo'), 'up');
      expect(Formatters.directionLabel('descendo'), 'down');
    });

    testWidgets(
      'B16 AssetCard estavel: neutro (sem Baixa, sem vermelho, sem seta p/ baixo)',
      (tester) async {
        await tester.pumpWidget(
          _wrap(AssetCardWidget(quote: _q('PETR4.SA', 'estável'))),
        );
        expect(find.text('Baixa'), findsNothing);
        expect(find.byIcon(Icons.arrow_downward_rounded), findsNothing);
        final c = _dirIconColor(tester, find.byType(AssetCardWidget));
        expect(c, isNot(AppColors.loss));
        expect(c, isNot(AppColors.gain));
      },
    );

    testWidgets('B16 AssetCard subindo: Alta verde seta para cima', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(AssetCardWidget(quote: _q('AAPL', 'subindo'))),
      );
      expect(find.text('Alta'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_upward_rounded), findsOneWidget);
      expect(
        _dirIconColor(tester, find.byType(AssetCardWidget)),
        AppColors.gain,
      );
    });

    testWidgets('B16 AssetCard descendo: Baixa vermelho seta para baixo', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(AssetCardWidget(quote: _q('AAPL', 'descendo'))),
      );
      expect(find.text('Baixa'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_downward_rounded), findsOneWidget);
      expect(
        _dirIconColor(tester, find.byType(AssetCardWidget)),
        AppColors.loss,
      );
    });

    testWidgets('B16 HistoricalChartCard estavel: neutro', (tester) async {
      await tester.pumpWidget(
        _wrap(
          HistoricalChartCard(
            quote: _q('PETR4.SA', 'estável'),
            history: _pts,
            selectedPeriod: '1M',
            periods: const ['1M'],
            onPeriodChanged: (_) {},
          ),
        ),
      );
      expect(find.text('Baixa'), findsNothing);
      expect(find.byIcon(Icons.arrow_downward_rounded), findsNothing);
      expect(
        _dirIconColor(tester, find.byType(HistoricalChartCard)),
        isNot(AppColors.loss),
      );
    });
  });

  group('B17 falha parcial', () {
    test(
      'B17 uma cotacao 404 nao derruba a lista: demais ativos aparecem',
      () async {
        when(() => wl.getWatchlist()).thenAnswer((_) async => [_aapl, _petr]);
        when(
          () => assets.getQuote('AAPL'),
        ).thenAnswer((_) async => _q('AAPL', 'subindo'));
        when(() => assets.getQuote('PETR4.SA')).thenThrow(Exception('404'));

        final c = container();
        await c.read(homeNotifierProvider.notifier).load();
        final s = c.read(homeNotifierProvider);
        expect(s.error, isNull, reason: 'erro global nao deve ocorrer');
        expect(s.quotes.map((q) => q.ticker), contains('AAPL'));
      },
    );

    test(
      'B17 um historico 500 nao derruba a lista: todos os ativos aparecem',
      () async {
        when(() => wl.getWatchlist()).thenAnswer((_) async => [_aapl, _petr]);
        when(() => assets.getQuote(any())).thenAnswer(
          (i) async => _q(i.positionalArguments[0] as String, 'subindo'),
        );
        when(
          () => assets.getHistory('AAPL', any()),
        ).thenThrow(Exception('500'));
        when(
          () => assets.getHistory('PETR4.SA', any()),
        ).thenAnswer((_) async => _pts);

        final c = container();
        await c.read(homeNotifierProvider.notifier).load();
        final s = c.read(homeNotifierProvider);
        expect(s.error, isNull);
        expect(
          s.quotes.map((q) => q.ticker),
          containsAll(['AAPL', 'PETR4.SA']),
        );
        expect(s.history['PETR4.SA'], _pts);
      },
    );

    testWidgets(
      'B17 HomeView: cotacao 404 mostra o ativo saudavel, sem erro global',
      (tester) async {
        when(() => wl.getWatchlist()).thenAnswer((_) async => [_aapl, _petr]);
        when(
          () => assets.getQuote('AAPL'),
        ).thenAnswer((_) async => _q('AAPL', 'subindo'));
        when(() => assets.getQuote('PETR4.SA')).thenThrow(Exception('404'));
        await pumpHome(tester);
        expect(find.text('Erro ao carregar dados.'), findsNothing);
        expect(find.text('AAPL'), findsWidgets);
      },
    );

    testWidgets(
      'B17 HomeView: ativo falho mostra estado de erro proprio (SUPOSICAO: texto erro/falha/indisponivel)',
      (tester) async {
        when(() => wl.getWatchlist()).thenAnswer((_) async => [_aapl, _petr]);
        when(
          () => assets.getQuote('AAPL'),
        ).thenAnswer((_) async => _q('AAPL', 'subindo'));
        when(() => assets.getQuote('PETR4.SA')).thenThrow(Exception('404'));
        await pumpHome(tester);
        expect(
          find.text('PETR4.SA'),
          findsWidgets,
          reason: 'ticker falho continua visivel',
        );
        expect(
          find.textContaining(
            RegExp(
              r'erro|falha|indispon|não foi possível',
              caseSensitive: false,
            ),
          ),
          findsWidgets,
        );
      },
    );
  });

  group('B18 historico com <2 pontos', () {
    for (final n in [0, 1]) {
      testWidgets('B18 $n ponto(s) mostra "Sem dados" e nao desenha grafico', (
        tester,
      ) async {
        await tester.pumpWidget(
          _wrap(
            HistoricalChartCard(
              quote: _q('AAPL', 'subindo'),
              history: _pts.take(n).toList(),
              selectedPeriod: '1D',
              periods: const ['1D', '1M'],
              onPeriodChanged: (_) {},
            ),
          ),
        );
        expect(find.text('Sem dados'), findsOneWidget);
        expect(find.byType(LineChart), findsNothing);
      });
    }

    testWidgets('B18 controle: 2+ pontos desenha grafico', (tester) async {
      await tester.pumpWidget(
        _wrap(
          HistoricalChartCard(
            quote: _q('AAPL', 'subindo'),
            history: _pts,
            selectedPeriod: '1M',
            periods: const ['1M'],
            onPeriodChanged: (_) {},
          ),
        ),
      );
      expect(find.text('Sem dados'), findsNothing);
      expect(find.byType(LineChart), findsOneWidget);
    });
  });

  group('B20 noticias', () {
    testWidgets(
      'B20 noticias vazias mostram mensagem (SUPOSICAO: /sem|nenhuma|nao ha ... noticia/)',
      (tester) async {
        quotesOk();
        await pumpHome(tester);
        expect(find.text('Notícias'), findsOneWidget);
        expect(
          find.textContaining(
            RegExp(r'(sem|nenhuma|não há).*not[ií]cia', caseSensitive: false),
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'B20 falha em todas as noticias nao e silenciosa (mensagem de erro)',
      (tester) async {
        quotesOk();
        when(() => assets.getNews(any())).thenThrow(Exception('500'));
        await pumpHome(tester);
        expect(
          find.textContaining(
            RegExp(
              r'not[ií]cias.*(erro|falha|indispon|carregar)|(erro|falha|não foi possível).*not[ií]cias',
              caseSensitive: false,
            ),
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets('B20 noticias com dados: sem mensagem de vazio', (
      tester,
    ) async {
      quotesOk();
      when(
        () => assets.getNews(any()),
      ).thenAnswer((_) async => [_news('Manchete A')]);
      await pumpHome(tester);
      expect(
        find.textContaining(
          RegExp(r'(sem|nenhuma).*not[ií]cia', caseSensitive: false),
        ),
        findsNothing,
      );
    });

    test(
      'B20 setPeriod com falha: erro por card (history[ticker]==null), quotes preservados',
      () async {
        quotesOk();
        final c = container();
        await c.read(homeNotifierProvider.notifier).load();
        when(() => assets.getHistory(any(), '1d')).thenThrow(Exception('500'));
        await c.read(homeNotifierProvider.notifier).setPeriod('1D');
        final s = c.read(homeNotifierProvider);
        expect(s.history['AAPL'], isNull);
        expect(s.quotes.map((q) => q.ticker), ['AAPL']);
      },
    );

    testWidgets(
      'B20 card com historico nulo mostra "Erro ao carregar o gráfico"',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            HistoricalChartCard(
              quote: _q('AAPL', 'subindo'),
              history: null,
              selectedPeriod: '1D',
              periods: const ['1D'],
              onPeriodChanged: (_) {},
            ),
          ),
        );
        expect(find.text('Erro ao carregar o gráfico'), findsOneWidget);
      },
    );

    Future<List<String>> tapNews(WidgetTester tester, String link) async {
      final launcher = _FakeLauncher();
      final prev = UrlLauncherPlatform.instance;
      UrlLauncherPlatform.instance = launcher;
      addTearDown(() => UrlLauncherPlatform.instance = prev);
      await tester.pumpWidget(
        _wrap(
          SizedBox(
            height: 120,
            child: HorizontalNewsCard(
              news: NewsItemModel(
                title: 'Titulo da noticia',
                link: link,
                publisher: 'Pub',
                providerPublishTime: '2026-10-01T10:00:00Z',
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Titulo da noticia'));
      await tester.pump();
      return launcher.opened;
    }

    testWidgets('B20 noticia clicavel abre o link', (tester) async {
      expect(await tapNews(tester, 'https://example.com/n/1'), [
        'https://example.com/n/1',
      ]);
    });

    testWidgets('B20 link com esquema nao http(s) nao abre', (tester) async {
      expect(await tapNews(tester, 'javascript:alert(1)'), isEmpty);
    });
  });

  group('B28 refresh com falha', () {
    test(
      'B28 VM: refresh falho mantem quotes e historico anteriores',
      () async {
        quotesOk();
        final c = container();
        final n = c.read(homeNotifierProvider.notifier);
        await n.load();
        expect(c.read(homeNotifierProvider).quotes, hasLength(1));

        when(() => wl.getWatchlist()).thenThrow(Exception('offline'));
        await n.load(refresh: true);
        final s = c.read(homeNotifierProvider);
        expect(s.quotes.map((q) => q.ticker), ['AAPL']);
        expect(s.history['AAPL'], _pts);
        expect(s.refreshing, false);
      },
    );

    testWidgets('B28 HomeView: refresh falho continua exibindo dados antigos', (
      tester,
    ) async {
      quotesOk();
      await pumpHome(tester);
      expect(find.text('AAPL'), findsWidgets);

      when(() => wl.getWatchlist()).thenThrow(Exception('offline'));
      await tester.tap(find.byIcon(Icons.refresh_rounded));
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(find.text('AAPL'), findsWidgets);
      // mensagem inline permitida; tela cheia (ErrorView) nao
      expect(find.byType(ErrorView), findsNothing);
      expect(find.byType(AssetCardWidget), findsOneWidget);
    });
  });
}

class _FakeLauncher extends UrlLauncherPlatform
    with MockPlatformInterfaceMixin {
  @override
  Widget Function(LinkInfo)? get linkDelegate => null;

  final opened = <String>[];

  @override
  Future<bool> canLaunch(String url) async => true;

  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async {
    opened.add(url);
    return true;
  }
}
