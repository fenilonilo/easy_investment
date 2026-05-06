import 'package:freezed_annotation/freezed_annotation.dart';

part 'news_item_model.freezed.dart';
part 'news_item_model.g.dart';

@freezed
class NewsItemModel with _$NewsItemModel {
  const factory NewsItemModel({
    required String title,
    required String link,
    required String publisher,
    @Default('') String? summary,
    @JsonKey(name: 'provider_publish_time') required String providerPublishTime,
  }) = _NewsItemModel;

  factory NewsItemModel.fromJson(Map<String, dynamic> json) =>
      _$NewsItemModelFromJson(json);
}
