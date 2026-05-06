import 'package:freezed_annotation/freezed_annotation.dart';

part 'dividend_model.freezed.dart';
part 'dividend_model.g.dart';

@freezed
class DividendModel with _$DividendModel {
  const factory DividendModel({
    required String date,
    required double amount,
  }) = _DividendModel;

  factory DividendModel.fromJson(Map<String, dynamic> json) =>
      _$DividendModelFromJson(json);
}
