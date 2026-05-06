import '../../data/models/asset_model.dart';

abstract class WatchlistRepository {
  Future<List<AssetModel>> getWatchlist();
  Future<void> addAssets(List<AssetModel> assets);
  Future<void> removeAssets(List<String> tickers);
}
