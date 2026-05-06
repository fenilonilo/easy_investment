// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'asset_quote_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AssetQuoteModelImpl _$$AssetQuoteModelImplFromJson(
  Map<String, dynamic> json,
) => _$AssetQuoteModelImpl(
  ticker: json['ticker'] as String,
  name: json['name'] as String,
  iconUrl: json['icon_url'] as String,
  priceUsd: (json['price_usd'] as num).toDouble(),
  direction: json['direction'] as String,
);

Map<String, dynamic> _$$AssetQuoteModelImplToJson(
  _$AssetQuoteModelImpl instance,
) => <String, dynamic>{
  'ticker': instance.ticker,
  'name': instance.name,
  'icon_url': instance.iconUrl,
  'price_usd': instance.priceUsd,
  'direction': instance.direction,
};
