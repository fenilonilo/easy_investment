import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/api_endpoints.dart';
import '../../data/datasources/dio_client.dart';
import '../../data/models/asset_model.dart';
import '../../data/models/asset_quote_model.dart';
import '../../data/models/history_point_model.dart';
import '../../data/models/news_item_model.dart';
import '../../data/models/dividend_model.dart';
import '../../data/models/financials_model.dart';
import '../../domain/repositories/asset_repository.dart';

class AssetRepositoryImpl implements AssetRepository {
  final Dio _dio;
  AssetRepositoryImpl(this._dio);

  @override
  Future<List<AssetModel>> search(String query) async {
    final r = await _dio.get(ApiEndpoints.assets,
        queryParameters: query.isNotEmpty ? {'search': query} : null);
    return (r.data as List)
        .map((e) => AssetModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<AssetQuoteModel> getQuote(String ticker) async {
    final r = await _dio.get(ApiEndpoints.assetQuote(ticker));
    return AssetQuoteModel.fromJson(r.data as Map<String, dynamic>);
  }

  @override
  Future<List<HistoryPointModel>> getHistory(String ticker, String period) async {
    final r = await _dio.get(
      ApiEndpoints.assetHistory(ticker),
      queryParameters: {'period': period},
    );
    return (r.data as List)
        .map((e) => HistoryPointModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<NewsItemModel>> getNews(String ticker) async {
    final r = await _dio.get(ApiEndpoints.assetNews(ticker));
    return (r.data as List)
        .map((e) => NewsItemModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<DividendModel>> getDividends(String ticker) async {
    final r = await _dio.get(ApiEndpoints.assetDividends(ticker));
    return (r.data as List)
        .map((e) => DividendModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<FinancialsModel> getFinancials(String ticker) async {
    final r = await _dio.get(ApiEndpoints.assetFinancials(ticker));
    return FinancialsModel.fromJson(r.data as Map<String, dynamic>);
  }
}

final assetRepositoryProvider = Provider<AssetRepository>((ref) =>
    AssetRepositoryImpl(ref.read(dioClientProvider)));
