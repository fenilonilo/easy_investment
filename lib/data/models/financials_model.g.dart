// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'financials_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FinancialsModelImpl _$$FinancialsModelImplFromJson(
  Map<String, dynamic> json,
) => _$FinancialsModelImpl(
  marketCap: (json['market_cap'] as num?)?.toInt(),
  peRatio: (json['pe_ratio'] as num?)?.toDouble(),
  dividendYield: (json['dividend_yield'] as num?)?.toDouble(),
  targetPrice: (json['target_price'] as num?)?.toDouble(),
  recommendation: json['recommendation'] as String?,
);

Map<String, dynamic> _$$FinancialsModelImplToJson(
  _$FinancialsModelImpl instance,
) => <String, dynamic>{
  'market_cap': instance.marketCap,
  'pe_ratio': instance.peRatio,
  'dividend_yield': instance.dividendYield,
  'target_price': instance.targetPrice,
  'recommendation': instance.recommendation,
};
