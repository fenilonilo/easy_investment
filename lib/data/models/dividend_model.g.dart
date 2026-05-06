// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dividend_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DividendModelImpl _$$DividendModelImplFromJson(Map<String, dynamic> json) =>
    _$DividendModelImpl(
      date: json['date'] as String,
      amount: (json['amount'] as num).toDouble(),
    );

Map<String, dynamic> _$$DividendModelImplToJson(_$DividendModelImpl instance) =>
    <String, dynamic>{'date': instance.date, 'amount': instance.amount};
