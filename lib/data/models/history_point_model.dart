import 'package:freezed_annotation/freezed_annotation.dart';

part 'history_point_model.freezed.dart';
part 'history_point_model.g.dart';

@freezed
class HistoryPointModel with _$HistoryPointModel {
  const factory HistoryPointModel({
    required String date,
    required double close,
  }) = _HistoryPointModel;

  factory HistoryPointModel.fromJson(Map<String, dynamic> json) =>
      _$HistoryPointModelFromJson(json);
}
