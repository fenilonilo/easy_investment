import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:easy_finance/presentation/viewmodels/profile_viewmodel.dart';
import 'package:easy_finance/data/repositories/watchlist_repository_impl.dart';
import 'package:easy_finance/data/repositories/asset_repository_impl.dart';
import 'package:easy_finance/data/datasources/user_storage_service.dart';
import 'package:easy_finance/domain/repositories/watchlist_repository.dart';
import 'package:easy_finance/domain/repositories/asset_repository.dart';
import 'package:easy_finance/data/models/asset_model.dart';
import 'package:easy_finance/data/models/user_model.dart';

class MockWatchlistRepository extends Mock implements WatchlistRepository {}

class MockAssetRepository extends Mock implements AssetRepository {}

class MockUserStorageService extends Mock implements UserStorageService {}

void main() {
  late MockWatchlistRepository mockWatchlist;
  late MockAssetRepository mockAssets;
  late MockUserStorageService mockUserStorage;

  setUpAll(() {
    registerFallbackValue(const AssetModel(ticker: '', name: '', iconUrl: ''));
    registerFallbackValue(<AssetModel>[]);
    registerFallbackValue(<String>[]);
  });

  setUp(() {
    mockWatchlist = MockWatchlistRepository();
    mockAssets = MockAssetRepository();
    mockUserStorage = MockUserStorageService();
  });

  ProviderContainer buildContainer({
    List<AssetModel> watchlist = const [],
    UserModel? user,
  }) {
    when(() => mockUserStorage.readUser()).thenAnswer((_) async => user);
    when(() => mockWatchlist.getWatchlist()).thenAnswer((_) async => watchlist);

    final container = ProviderContainer(
      overrides: [
        watchlistRepositoryProvider.overrideWithValue(mockWatchlist),
        assetRepositoryProvider.overrideWithValue(mockAssets),
        userStorageServiceProvider.overrideWithValue(mockUserStorage),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('ProfileNotifier', () {
    test('after init with empty watchlist: loading=false, selectedAssets=[], originalWatchlist=[]', () async {
      final container = buildContainer();
      container.read(profileNotifierProvider);
      await Future.delayed(Duration.zero);

      final state = container.read(profileNotifierProvider);
      expect(state.loading, false);
      expect(state.selectedAssets, isEmpty);
      expect(state.originalWatchlist, isEmpty);
    });

    test('addAsset adds asset to selectedAssets', () async {
      final container = buildContainer();
      container.read(profileNotifierProvider);
      await Future.delayed(Duration.zero);

      const asset = AssetModel(ticker: 'AAPL', name: 'Apple', iconUrl: '');
      container.read(profileNotifierProvider.notifier).addAsset(asset);

      final state = container.read(profileNotifierProvider);
      expect(state.selectedAssets.length, 1);
      expect(state.selectedAssets.first.ticker, 'AAPL');
    });

    test('addAsset with duplicate ticker does not add twice', () async {
      final container = buildContainer();
      container.read(profileNotifierProvider);
      await Future.delayed(Duration.zero);

      const asset = AssetModel(ticker: 'AAPL', name: 'Apple', iconUrl: '');
      container.read(profileNotifierProvider.notifier).addAsset(asset);
      container.read(profileNotifierProvider.notifier).addAsset(asset);

      final state = container.read(profileNotifierProvider);
      expect(state.selectedAssets.length, 1);
    });

    test('removeAsset removes asset from selectedAssets', () async {
      const asset = AssetModel(ticker: 'AAPL', name: 'Apple', iconUrl: '');
      final container = buildContainer(watchlist: [asset]);
      container.read(profileNotifierProvider);
      await Future.delayed(Duration.zero);

      container.read(profileNotifierProvider.notifier).removeAsset('AAPL');

      final state = container.read(profileNotifierProvider);
      expect(state.selectedAssets, isEmpty);
    });

    test('search with empty query sets searchResults=[] and searching=false', () async {
      final container = buildContainer();
      container.read(profileNotifierProvider);
      await Future.delayed(Duration.zero);

      container.read(profileNotifierProvider.notifier).search('');

      final state = container.read(profileNotifierProvider);
      expect(state.searchResults, isEmpty);
      expect(state.searching, false);
    });

    test('search with query fires after debounce and sets results', () async {
      const results = [AssetModel(ticker: 'AAPL', name: 'Apple', iconUrl: '')];
      when(() => mockAssets.search(any())).thenAnswer((_) async => results);

      final container = buildContainer();
      container.read(profileNotifierProvider);
      await Future.delayed(Duration.zero);

      container.read(profileNotifierProvider.notifier).search('AAPL');
      await Future.delayed(const Duration(milliseconds: 500));

      final state = container.read(profileNotifierProvider);
      expect(state.searchResults.length, 1);
      expect(state.searchResults.first.ticker, 'AAPL');
      expect(state.searching, false);
    });

    test('saveChanges with toAdd items calls addAssets and sets successMessage', () async {
      when(() => mockWatchlist.addAssets(any())).thenAnswer((_) async {});

      final container = buildContainer();
      container.read(profileNotifierProvider);
      await Future.delayed(Duration.zero);

      const asset = AssetModel(ticker: 'AAPL', name: 'Apple', iconUrl: '');
      container.read(profileNotifierProvider.notifier).addAsset(asset);

      await container.read(profileNotifierProvider.notifier).saveChanges();

      final state = container.read(profileNotifierProvider);
      expect(state.successMessage, 'Watchlist atualizada!');
      expect(state.saving, false);
      verify(() => mockWatchlist.addAssets(any())).called(1);
    });

    test('saveChanges with toRemove items calls removeAssets', () async {
      const asset = AssetModel(ticker: 'AAPL', name: 'Apple', iconUrl: '');
      when(() => mockWatchlist.removeAssets(any())).thenAnswer((_) async {});

      final container = buildContainer(watchlist: [asset]);
      container.read(profileNotifierProvider);
      await Future.delayed(Duration.zero);

      container.read(profileNotifierProvider.notifier).removeAsset('AAPL');
      await container.read(profileNotifierProvider.notifier).saveChanges();

      final state = container.read(profileNotifierProvider);
      expect(state.successMessage, 'Watchlist atualizada!');
      verify(() => mockWatchlist.removeAssets(any())).called(1);
    });

    test('saveChanges when repo throws sets error', () async {
      when(() => mockWatchlist.addAssets(any())).thenThrow(Exception('network error'));

      final container = buildContainer();
      container.read(profileNotifierProvider);
      await Future.delayed(Duration.zero);

      const asset = AssetModel(ticker: 'AAPL', name: 'Apple', iconUrl: '');
      container.read(profileNotifierProvider.notifier).addAsset(asset);
      await container.read(profileNotifierProvider.notifier).saveChanges();

      final state = container.read(profileNotifierProvider);
      expect(state.error, 'Erro ao salvar.');
      expect(state.saving, false);
    });

    test('saveChanges with no changes calls neither addAssets nor removeAssets', () async {
      const asset = AssetModel(ticker: 'AAPL', name: 'Apple', iconUrl: '');

      final container = buildContainer(watchlist: [asset]);
      container.read(profileNotifierProvider);
      await Future.delayed(Duration.zero);

      await container.read(profileNotifierProvider.notifier).saveChanges();

      final state = container.read(profileNotifierProvider);
      expect(state.successMessage, 'Watchlist atualizada!');
      verifyNever(() => mockWatchlist.addAssets(any()));
      verifyNever(() => mockWatchlist.removeAssets(any()));
    });
  });
}
