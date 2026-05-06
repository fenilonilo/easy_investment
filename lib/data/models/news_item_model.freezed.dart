// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'news_item_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

NewsItemModel _$NewsItemModelFromJson(Map<String, dynamic> json) {
  return _NewsItemModel.fromJson(json);
}

/// @nodoc
mixin _$NewsItemModel {
  String get title => throw _privateConstructorUsedError;
  String get link => throw _privateConstructorUsedError;
  String get publisher => throw _privateConstructorUsedError;
  String? get summary => throw _privateConstructorUsedError;
  @JsonKey(name: 'provider_publish_time')
  String get providerPublishTime => throw _privateConstructorUsedError;

  /// Serializes this NewsItemModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NewsItemModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NewsItemModelCopyWith<NewsItemModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NewsItemModelCopyWith<$Res> {
  factory $NewsItemModelCopyWith(
    NewsItemModel value,
    $Res Function(NewsItemModel) then,
  ) = _$NewsItemModelCopyWithImpl<$Res, NewsItemModel>;
  @useResult
  $Res call({
    String title,
    String link,
    String publisher,
    String? summary,
    @JsonKey(name: 'provider_publish_time') String providerPublishTime,
  });
}

/// @nodoc
class _$NewsItemModelCopyWithImpl<$Res, $Val extends NewsItemModel>
    implements $NewsItemModelCopyWith<$Res> {
  _$NewsItemModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NewsItemModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? link = null,
    Object? publisher = null,
    Object? summary = freezed,
    Object? providerPublishTime = null,
  }) {
    return _then(
      _value.copyWith(
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            link: null == link
                ? _value.link
                : link // ignore: cast_nullable_to_non_nullable
                      as String,
            publisher: null == publisher
                ? _value.publisher
                : publisher // ignore: cast_nullable_to_non_nullable
                      as String,
            summary: freezed == summary
                ? _value.summary
                : summary // ignore: cast_nullable_to_non_nullable
                      as String?,
            providerPublishTime: null == providerPublishTime
                ? _value.providerPublishTime
                : providerPublishTime // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$NewsItemModelImplCopyWith<$Res>
    implements $NewsItemModelCopyWith<$Res> {
  factory _$$NewsItemModelImplCopyWith(
    _$NewsItemModelImpl value,
    $Res Function(_$NewsItemModelImpl) then,
  ) = __$$NewsItemModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String title,
    String link,
    String publisher,
    String? summary,
    @JsonKey(name: 'provider_publish_time') String providerPublishTime,
  });
}

/// @nodoc
class __$$NewsItemModelImplCopyWithImpl<$Res>
    extends _$NewsItemModelCopyWithImpl<$Res, _$NewsItemModelImpl>
    implements _$$NewsItemModelImplCopyWith<$Res> {
  __$$NewsItemModelImplCopyWithImpl(
    _$NewsItemModelImpl _value,
    $Res Function(_$NewsItemModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of NewsItemModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? link = null,
    Object? publisher = null,
    Object? summary = freezed,
    Object? providerPublishTime = null,
  }) {
    return _then(
      _$NewsItemModelImpl(
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        link: null == link
            ? _value.link
            : link // ignore: cast_nullable_to_non_nullable
                  as String,
        publisher: null == publisher
            ? _value.publisher
            : publisher // ignore: cast_nullable_to_non_nullable
                  as String,
        summary: freezed == summary
            ? _value.summary
            : summary // ignore: cast_nullable_to_non_nullable
                  as String?,
        providerPublishTime: null == providerPublishTime
            ? _value.providerPublishTime
            : providerPublishTime // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$NewsItemModelImpl implements _NewsItemModel {
  const _$NewsItemModelImpl({
    required this.title,
    required this.link,
    required this.publisher,
    this.summary = '',
    @JsonKey(name: 'provider_publish_time') required this.providerPublishTime,
  });

  factory _$NewsItemModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$NewsItemModelImplFromJson(json);

  @override
  final String title;
  @override
  final String link;
  @override
  final String publisher;
  @override
  @JsonKey()
  final String? summary;
  @override
  @JsonKey(name: 'provider_publish_time')
  final String providerPublishTime;

  @override
  String toString() {
    return 'NewsItemModel(title: $title, link: $link, publisher: $publisher, summary: $summary, providerPublishTime: $providerPublishTime)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NewsItemModelImpl &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.link, link) || other.link == link) &&
            (identical(other.publisher, publisher) ||
                other.publisher == publisher) &&
            (identical(other.summary, summary) || other.summary == summary) &&
            (identical(other.providerPublishTime, providerPublishTime) ||
                other.providerPublishTime == providerPublishTime));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    title,
    link,
    publisher,
    summary,
    providerPublishTime,
  );

  /// Create a copy of NewsItemModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NewsItemModelImplCopyWith<_$NewsItemModelImpl> get copyWith =>
      __$$NewsItemModelImplCopyWithImpl<_$NewsItemModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NewsItemModelImplToJson(this);
  }
}

abstract class _NewsItemModel implements NewsItemModel {
  const factory _NewsItemModel({
    required final String title,
    required final String link,
    required final String publisher,
    final String? summary,
    @JsonKey(name: 'provider_publish_time')
    required final String providerPublishTime,
  }) = _$NewsItemModelImpl;

  factory _NewsItemModel.fromJson(Map<String, dynamic> json) =
      _$NewsItemModelImpl.fromJson;

  @override
  String get title;
  @override
  String get link;
  @override
  String get publisher;
  @override
  String? get summary;
  @override
  @JsonKey(name: 'provider_publish_time')
  String get providerPublishTime;

  /// Create a copy of NewsItemModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NewsItemModelImplCopyWith<_$NewsItemModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
