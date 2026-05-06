import 'package:freezed_annotation/freezed_annotation.dart';

part 'asset_quote_model.freezed.dart';
part 'asset_quote_model.g.dart';

@freezed
class AssetQuoteModel with _$AssetQuoteModel {
  const factory AssetQuoteModel({
    required String ticker,
    required String name,
    @JsonKey(name: 'icon_url') required String iconUrl,
    @JsonKey(name: 'price_usd') required double priceUsd,
    required String direction,
  }) = _AssetQuoteModel;

  factory AssetQuoteModel.fromJson(Map<String, dynamic> json) =>
      _$AssetQuoteModelFromJson(json);
}
