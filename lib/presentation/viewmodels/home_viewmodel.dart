import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/api_constants.dart';
import '../../data/models/asset_model.dart';
import '../../data/models/asset_quote_model.dart';
import '../../data/models/history_point_model.dart';
import '../../data/models/news_item_model.dart';
import '../../data/repositories/asset_repository_impl.dart';
import '../../domain/repositories/asset_repository.dart';
import '../../data/repositories/watchlist_repository_impl.dart';

const _orderKey = 'watchlist_order';

class HomeState {
  final bool loading;
  final bool refreshing;
  final String? error;
  final List<AssetQuoteModel> quotes;

  /// Tickers cuja cotação falhou (card de erro, sem derrubar a Home).
  final List<String> failedTickers;
  final String selectedPeriod;

  /// Ticker ausente do mapa = histórico falhou para esse ativo.
  final Map<String, List<HistoryPointModel>> history;
  final List<NewsItemModel> news;
  final bool newsLoading;
  final bool newsError;

  const HomeState({
    this.loading = true,
    this.refreshing = false,
    this.error,
    this.quotes = const [],
    this.failedTickers = const [],
    this.selectedPeriod = '1M',
    this.history = const {},
    this.news = const [],
    this.newsLoading = false,
    this.newsError = false,
  });

  HomeState copyWith({
    bool? loading,
    bool? refreshing,
    String? error,
    List<AssetQuoteModel>? quotes,
    List<String>? failedTickers,
    String? selectedPeriod,
    Map<String, List<HistoryPointModel>>? history,
    List<NewsItemModel>? news,
    bool? newsLoading,
    bool? newsError,
  }) =>
      HomeState(
        loading: loading ?? this.loading,
        refreshing: refreshing ?? this.refreshing,
        error: error,
        quotes: quotes ?? this.quotes,
        failedTickers: failedTickers ?? this.failedTickers,
        selectedPeriod: selectedPeriod ?? this.selectedPeriod,
        history: history ?? this.history,
        news: news ?? this.news,
        newsLoading: newsLoading ?? this.newsLoading,
        newsError: newsError ?? this.newsError,
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
        state = state.copyWith(
            loading: false, refreshing: false, quotes: [], failedTickers: []);
        return;
      }

      final period = PeriodMap.uiToApi[state.selectedPeriod] ?? '1mo';

      // Falha isolada por ativo: um 404/500 não derruba os demais.
      final quoteResults = await Future.wait(ordered.map((a) async {
        try {
          return await assetRepo.getQuote(a.ticker);
        } catch (_) {
          return null;
        }
      }));
      final histResults = await _fetchHistories(
          assetRepo, ordered.map((a) => a.ticker).toList(), period);

      final results = quoteResults.whereType<AssetQuoteModel>().toList();
      final failed = [
        for (int i = 0; i < ordered.length; i++)
          if (quoteResults[i] == null) ordered[i].ticker
      ];

      state = state.copyWith(
        loading: false,
        refreshing: false,
        quotes: results,
        failedTickers: failed,
        history: histResults,
        error: results.isEmpty ? 'Erro ao carregar dados.' : null,
      );

      _loadNews(ordered.map((a) => a.ticker).toList());
    } catch (e) {
      // Refresh falho (ex.: back offline) mantém os dados já exibidos;
      // a view mostra o erro como banner.
      state = state.copyWith(
        loading: false,
        refreshing: false,
        error: 'Erro ao carregar dados.',
      );
    }
  }

  Future<Map<String, List<HistoryPointModel>>> _fetchHistories(
      AssetRepository assetRepo, List<String> tickers, String period) async {
    final res = await Future.wait(tickers.map((t) async {
      try {
        return await assetRepo.getHistory(t, period);
      } catch (_) {
        return null;
      }
    }));
    return {
      for (int i = 0; i < tickers.length; i++)
        if (res[i] != null) tickers[i]: res[i]!
    };
  }

  Future<void> _loadNews(List<String> tickers) async {
    state = state.copyWith(newsLoading: true, newsError: false, error: state.error);
    try {
      final assetRepo = _ref.read(assetRepositoryProvider);
      var failures = 0;
      final allNews = await Future.wait(
        tickers.map((t) => assetRepo.getNews(t).catchError((_) {
              failures++;
              return <NewsItemModel>[];
            })),
      );
      final flat = allNews.expand((n) => n).toList()
        ..sort((a, b) =>
            b.providerPublishTime.compareTo(a.providerPublishTime));
      state = state.copyWith(
          news: flat,
          newsLoading: false,
          newsError: failures == tickers.length && flat.isEmpty,
          error: state.error);
    } catch (_) {
      state = state.copyWith(
          newsLoading: false, newsError: true, error: state.error);
    }
  }

  Future<void> setPeriod(String period) async {
    state = state.copyWith(selectedPeriod: period);
    final apiPeriod = PeriodMap.uiToApi[period] ?? '1mo';
    final assetRepo = _ref.read(assetRepositoryProvider);
    // Falha por ativo vira ausência no mapa (card de gráfico com erro).
    final histMap = await _fetchHistories(
        assetRepo, state.quotes.map((q) => q.ticker).toList(), apiPeriod);
    state = state.copyWith(history: histMap);
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
