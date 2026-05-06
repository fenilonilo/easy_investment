import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/api_constants.dart';
import '../../data/models/asset_model.dart';
import '../../data/models/asset_quote_model.dart';
import '../../data/models/history_point_model.dart';
import '../../data/models/news_item_model.dart';
import '../../data/repositories/asset_repository_impl.dart';
import '../../data/repositories/watchlist_repository_impl.dart';

const _orderKey = 'watchlist_order';

class HomeState {
  final bool loading;
  final bool refreshing;
  final String? error;
  final List<AssetQuoteModel> quotes;
  final String selectedPeriod;
  final Map<String, List<HistoryPointModel>> history;
  final List<NewsItemModel> news;
  final bool newsLoading;

  const HomeState({
    this.loading = true,
    this.refreshing = false,
    this.error,
    this.quotes = const [],
    this.selectedPeriod = '1M',
    this.history = const {},
    this.news = const [],
    this.newsLoading = false,
  });

  HomeState copyWith({
    bool? loading,
    bool? refreshing,
    String? error,
    List<AssetQuoteModel>? quotes,
    String? selectedPeriod,
    Map<String, List<HistoryPointModel>>? history,
    List<NewsItemModel>? news,
    bool? newsLoading,
  }) =>
      HomeState(
        loading: loading ?? this.loading,
        refreshing: refreshing ?? this.refreshing,
        error: error,
        quotes: quotes ?? this.quotes,
        selectedPeriod: selectedPeriod ?? this.selectedPeriod,
        history: history ?? this.history,
        news: news ?? this.news,
        newsLoading: newsLoading ?? this.newsLoading,
      );
}

class HomeNotifier extends StateNotifier<HomeState> {
  final Ref _ref;
  HomeNotifier(this._ref) : super(const HomeState()) {
    load();
  }

  Future<void> load({bool refresh = false}) async {
    if (refresh) {
      state = state.copyWith(refreshing: true, error: null);
    } else {
      state = const HomeState(loading: true);
    }
    try {
      final watchlistRepo = _ref.read(watchlistRepositoryProvider);
      final assetRepo = _ref.read(assetRepositoryProvider);

      final watchlist = await watchlistRepo.getWatchlist();
      final ordered = await _applyOrder(watchlist);

      if (ordered.isEmpty) {
        state = state.copyWith(loading: false, refreshing: false, quotes: []);
        return;
      }

      final period = PeriodMap.uiToApi[state.selectedPeriod] ?? '1mo';

      final results = await Future.wait(
        ordered.map((a) => assetRepo.getQuote(a.ticker)),
      );

      final histResults = await Future.wait(
        ordered.map((a) => assetRepo.getHistory(a.ticker, period)),
      );

      final histMap = <String, List<HistoryPointModel>>{};
      for (int i = 0; i < ordered.length; i++) {
        histMap[ordered[i].ticker] = histResults[i];
      }

      state = state.copyWith(
        loading: false,
        refreshing: false,
        quotes: results,
        history: histMap,
        error: null,
      );

      _loadNews(ordered.map((a) => a.ticker).toList());
    } catch (e) {
      state = state.copyWith(
        loading: false,
        refreshing: false,
        error: 'Erro ao carregar dados.',
      );
    }
  }

  Future<void> _loadNews(List<String> tickers) async {
    state = state.copyWith(newsLoading: true);
    try {
      final assetRepo = _ref.read(assetRepositoryProvider);
      final allNews = await Future.wait(
        tickers.map((t) => assetRepo.getNews(t).catchError((_) => <NewsItemModel>[])),
      );
      final flat = allNews.expand((n) => n).toList()
        ..sort((a, b) =>
            b.providerPublishTime.compareTo(a.providerPublishTime));
      state = state.copyWith(news: flat, newsLoading: false);
    } catch (_) {
      state = state.copyWith(newsLoading: false);
    }
  }

  Future<void> setPeriod(String period) async {
    state = state.copyWith(selectedPeriod: period);
    final apiPeriod = PeriodMap.uiToApi[period] ?? '1mo';
    final assetRepo = _ref.read(assetRepositoryProvider);
    try {
      final histResults = await Future.wait(
        state.quotes.map((q) => assetRepo.getHistory(q.ticker, apiPeriod)),
      );
      final histMap = <String, List<HistoryPointModel>>{};
      for (int i = 0; i < state.quotes.length; i++) {
        histMap[state.quotes[i].ticker] = histResults[i];
      }
      state = state.copyWith(history: histMap);
    } catch (_) {}
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    final list = List<AssetQuoteModel>.from(state.quotes);
    if (newIndex > oldIndex) newIndex--;
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    state = state.copyWith(quotes: list);
    await _saveOrder(list.map((q) => q.ticker).toList());
  }

  Future<void> _saveOrder(List<String> tickers) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_orderKey, tickers);
  }

  Future<List<AssetModel>> _applyOrder(List<AssetModel> assets) async {
    final prefs = await SharedPreferences.getInstance();
    final order = prefs.getStringList(_orderKey);
    if (order == null || order.isEmpty) return assets;
    final map = {for (final a in assets) a.ticker: a};
    final ordered = order
        .where(map.containsKey)
        .map((t) => map[t]!)
        .toList();
    final remaining = assets.where((a) => !order.contains(a.ticker)).toList();
    return [...ordered, ...remaining];
  }
}

final homeNotifierProvider =
    StateNotifierProvider<HomeNotifier, HomeState>((ref) => HomeNotifier(ref));
