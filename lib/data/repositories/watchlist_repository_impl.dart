import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/api_endpoints.dart';
import '../../data/datasources/dio_client.dart';
import '../../data/models/asset_model.dart';
import '../../domain/repositories/watchlist_repository.dart';

class WatchlistRepositoryImpl implements WatchlistRepository {
  final Dio _dio;
  WatchlistRepositoryImpl(this._dio);

  @override
  Future<List<AssetModel>> getWatchlist() async {
    final r = await _dio.get(ApiEndpoints.watchlist);
    return (r.data as List)
        .map((e) => AssetModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> addAssets(List<AssetModel> assets) async {
    await _dio.post(
      ApiEndpoints.watchlistAdd,
      data: assets
          .map((a) => {'ticker': a.ticker, 'name': a.name, 'icon_url': a.iconUrl})
          .toList(),
    );
  }

  @override
  Future<void> removeAssets(List<String> tickers) async {
    await _dio.post(
      ApiEndpoints.watchlistRemove,
      data: tickers.map((t) => {'ticker': t}).toList(),
    );
  }
}

final watchlistRepositoryProvider = Provider<WatchlistRepository>((ref) =>
    WatchlistRepositoryImpl(ref.read(dioClientProvider)));
