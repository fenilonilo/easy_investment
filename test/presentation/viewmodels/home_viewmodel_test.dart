import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:easy_finance/presentation/viewmodels/home_viewmodel.dart';
import 'package:easy_finance/data/repositories/watchlist_repository_impl.dart';
import 'package:easy_finance/data/repositories/asset_repository_impl.dart';
import 'package:easy_finance/domain/repositories/watchlist_repository.dart';
import 'package:easy_finance/domain/repositories/asset_repository.dart';
import 'package:easy_finance/data/models/asset_model.dart';
import 'package:easy_finance/data/models/asset_quote_model.dart';
import 'package:easy_finance/data/models/history_point_model.dart';
import 'package:easy_finance/data/models/news_item_model.dart';

class MockWatchlistRepository extends Mock implements WatchlistRepository {}

class MockAssetRepository extends Mock implements AssetRepository {}

void main() {
  late MockWatchlistRepository mockWatchlist;
  late MockAssetRepository mockAssets;

  setUpAll(() {
    registerFallbackValue(const AssetModel(ticker: '', name: '', iconUrl: ''));
    registerFallbackValue(<AssetModel>[]);
    registerFallbackValue(<String>[]);
  });

  setUp(() {
    mockWatchlist = MockWatchlistRepository();
    mockAssets = MockAssetRepository();
    SharedPreferences.setMockInitialValues({});
  });

  ProviderContainer buildContainer() {
    final container = ProviderContainer(
      overrides: [
        watchlistRepositoryProvider.overrideWithValue(mockWatchlist),
        assetRepositoryProvider.overrideWithValue(mockAssets),
      ],
    );
    addTearDown(() async {
      await Future.delayed(const Duration(milliseconds: 50));
      container.dispose();
    });
    return container;
  }

  group('HomeNotifier', () {
    test('load with empty watchlist sets quotes=[] and loading=false', () async {
      when(() => mockWatchlist.getWatchlist()).thenAnswer((_) async => []);

      final container = buildContainer();
      await container.read(homeNotifierProvider.notifier).load();

      final state = container.read(homeNotifierProvider);
      expect(state.quotes, isEmpty);
      expect(state.loading, false);
    });

    test('load with 1 asset sets quotes with 1 item and loading=false', () async {
      const asset = AssetModel(ticker: 'AAPL', name: 'Apple', iconUrl: '');
      const quote = AssetQuoteModel(
        ticker: 'AAPL',
        name: 'Apple',
        iconUrl: '',
        priceUsd: 150.0,
        direction: 'subindo',
      );

      when(() => mockWatchlist.getWatchlist()).thenAnswer((_) async => [asset]);
      when(() => mockAssets.getQuote(any())).thenAnswer((_) async => quote);
      when(() => mockAssets.getHistory(any(), any())).thenAnswer((_) async => []);
      when(() => mockAssets.getNews(any())).thenAnswer((_) async => []);

      final container = buildContainer();
      await container.read(homeNotifierProvider.notifier).load();
      await Future.delayed(Duration.zero);

      final state = container.read(homeNotifierProvider);
      expect(state.quotes.length, 1);
      expect(state.quotes.first.ticker, 'AAPL');
      expect(state.loading, false);
    });

    test('setPeriod updates selectedPeriod and refetches history', () async {
      const asset = AssetModel(ticker: 'AAPL', name: 'Apple', iconUrl: '');
      const quote = AssetQuoteModel(
        ticker: 'AAPL',
        name: 'Apple',
        iconUrl: '',
        priceUsd: 150.0,
        direction: 'subindo',
      );

      when(() => mockWatchlist.getWatchlist()).thenAnswer((_) async => [asset]);
      when(() => mockAssets.getQuote(any())).thenAnswer((_) async => quote);
      when(() => mockAssets.getHistory(any(), any())).thenAnswer((_) async => []);
      when(() => mockAssets.getNews(any())).thenAnswer((_) async => []);

      final container = buildContainer();
      await container.read(homeNotifierProvider.notifier).load();
      await Future.delayed(Duration.zero);
      await container.read(homeNotifierProvider.notifier).setPeriod('1D');

      final state = container.read(homeNotifierProvider);
      expect(state.selectedPeriod, '1D');
    });

    test('reorder(1, 0) on 2 items moves second item to front', () async {
      const asset1 = AssetModel(ticker: 'AAPL', name: 'Apple', iconUrl: '');
      const asset2 = AssetModel(ticker: 'GOOG', name: 'Google', iconUrl: '');
      const quote1 = AssetQuoteModel(
        ticker: 'AAPL',
        name: 'Apple',
        iconUrl: '',
        priceUsd: 150.0,
        direction: 'subindo',
      );
      const quote2 = AssetQuoteModel(
        ticker: 'GOOG',
        name: 'Google',
        iconUrl: '',
        priceUsd: 2800.0,
        direction: 'subindo',
      );

      when(() => mockWatchlist.getWatchlist()).thenAnswer((_) async => [asset1, asset2]);
      when(() => mockAssets.getQuote('AAPL')).thenAnswer((_) async => quote1);
      when(() => mockAssets.getQuote('GOOG')).thenAnswer((_) async => quote2);
      when(() => mockAssets.getHistory(any(), any())).thenAnswer((_) async => []);
      when(() => mockAssets.getNews(any())).thenAnswer((_) async => []);

      final container = buildContainer();
      await container.read(homeNotifierProvider.notifier).load();
      await Future.delayed(Duration.zero);
      await container.read(homeNotifierProvider.notifier).reorder(1, 0);

      final state = container.read(homeNotifierProvider);
      expect(state.quotes[0].ticker, 'GOOG');
      expect(state.quotes[1].ticker, 'AAPL');
    });

    test('reorder(0, 2) on 3 items produces correct ordering', () async {
      const asset1 = AssetModel(ticker: 'AAPL', name: 'Apple', iconUrl: '');
      const asset2 = AssetModel(ticker: 'GOOG', name: 'Google', iconUrl: '');
      const asset3 = AssetModel(ticker: 'MSFT', name: 'Microsoft', iconUrl: '');
      const quote1 = AssetQuoteModel(ticker: 'AAPL', name: 'Apple', iconUrl: '', priceUsd: 150.0, direction: 'subindo');
      const quote2 = AssetQuoteModel(ticker: 'GOOG', name: 'Google', iconUrl: '', priceUsd: 2800.0, direction: 'subindo');
      const quote3 = AssetQuoteModel(ticker: 'MSFT', name: 'Microsoft', iconUrl: '', priceUsd: 300.0, direction: 'subindo');

      when(() => mockWatchlist.getWatchlist()).thenAnswer((_) async => [asset1, asset2, asset3]);
      when(() => mockAssets.getQuote('AAPL')).thenAnswer((_) async => quote1);
      when(() => mockAssets.getQuote('GOOG')).thenAnswer((_) async => quote2);
      when(() => mockAssets.getQuote('MSFT')).thenAnswer((_) async => quote3);
      when(() => mockAssets.getHistory(any(), any())).thenAnswer((_) async => []);
      when(() => mockAssets.getNews(any())).thenAnswer((_) async => []);

      final container = buildContainer();
      await container.read(homeNotifierProvider.notifier).load();
      await Future.delayed(Duration.zero);
      await container.read(homeNotifierProvider.notifier).reorder(0, 2);

      final state = container.read(homeNotifierProvider);
      expect(state.quotes[0].ticker, 'GOOG');
      expect(state.quotes[1].ticker, 'AAPL');
      expect(state.quotes[2].ticker, 'MSFT');
    });

    test('load error sets error message', () async {
      when(() => mockWatchlist.getWatchlist()).thenThrow(Exception('network error'));

      final container = buildContainer();
      await container.read(homeNotifierProvider.notifier).load();

      final state = container.read(homeNotifierProvider);
      expect(state.error, 'Erro ao carregar dados.');
      expect(state.loading, false);
    });
  });
}
