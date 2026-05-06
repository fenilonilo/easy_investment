import '../../data/models/asset_model.dart';
import '../../data/models/asset_quote_model.dart';
import '../../data/models/history_point_model.dart';
import '../../data/models/news_item_model.dart';
import '../../data/models/dividend_model.dart';
import '../../data/models/financials_model.dart';

abstract class AssetRepository {
  Future<List<AssetModel>> search(String query);
  Future<AssetQuoteModel> getQuote(String ticker);
  Future<List<HistoryPointModel>> getHistory(String ticker, String period);
  Future<List<NewsItemModel>> getNews(String ticker);
  Future<List<DividendModel>> getDividends(String ticker);
  Future<FinancialsModel> getFinancials(String ticker);
}
