import 'package:freezed_annotation/freezed_annotation.dart';

part 'financials_model.freezed.dart';
part 'financials_model.g.dart';

@freezed
class FinancialsModel with _$FinancialsModel {
  const factory FinancialsModel({
    @JsonKey(name: 'market_cap') int? marketCap,
    @JsonKey(name: 'pe_ratio') double? peRatio,
    @JsonKey(name: 'dividend_yield') double? dividendYield,
    @JsonKey(name: 'target_price') double? targetPrice,
    String? recommendation,
  }) = _FinancialsModel;

  factory FinancialsModel.fromJson(Map<String, dynamic> json) =>
      _$FinancialsModelFromJson(json);
}
