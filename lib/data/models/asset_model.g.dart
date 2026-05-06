// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'asset_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AssetModelImpl _$$AssetModelImplFromJson(Map<String, dynamic> json) =>
    _$AssetModelImpl(
      ticker: json['ticker'] as String,
      name: json['name'] as String,
      iconUrl: json['icon_url'] as String,
    );

Map<String, dynamic> _$$AssetModelImplToJson(_$AssetModelImpl instance) =>
    <String, dynamic>{
      'ticker': instance.ticker,
      'name': instance.name,
      'icon_url': instance.iconUrl,
    };
