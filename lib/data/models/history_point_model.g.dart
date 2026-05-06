// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_point_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$HistoryPointModelImpl _$$HistoryPointModelImplFromJson(
  Map<String, dynamic> json,
) => _$HistoryPointModelImpl(
  date: json['date'] as String,
  close: (json['close'] as num).toDouble(),
);

Map<String, dynamic> _$$HistoryPointModelImplToJson(
  _$HistoryPointModelImpl instance,
) => <String, dynamic>{'date': instance.date, 'close': instance.close};
