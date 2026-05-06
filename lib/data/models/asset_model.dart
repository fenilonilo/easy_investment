import 'package:freezed_annotation/freezed_annotation.dart';

part 'asset_model.freezed.dart';
part 'asset_model.g.dart';

@freezed
class AssetModel with _$AssetModel {
  const factory AssetModel({
    required String ticker,
    required String name,
    @JsonKey(name: 'icon_url') required String iconUrl,
  }) = _AssetModel;

  factory AssetModel.fromJson(Map<String, dynamic> json) =>
      _$AssetModelFromJson(json);
}
