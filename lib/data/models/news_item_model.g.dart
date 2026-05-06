// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'news_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NewsItemModelImpl _$$NewsItemModelImplFromJson(Map<String, dynamic> json) =>
    _$NewsItemModelImpl(
      title: json['title'] as String,
      link: json['link'] as String,
      publisher: json['publisher'] as String,
      summary: json['summary'] as String? ?? '',
      providerPublishTime: json['provider_publish_time'] as String,
    );

Map<String, dynamic> _$$NewsItemModelImplToJson(_$NewsItemModelImpl instance) =>
    <String, dynamic>{
      'title': instance.title,
      'link': instance.link,
      'publisher': instance.publisher,
      'summary': instance.summary,
      'provider_publish_time': instance.providerPublishTime,
    };
