// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'asset_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AssetModel _$AssetModelFromJson(Map<String, dynamic> json) {
  return _AssetModel.fromJson(json);
}

/// @nodoc
mixin _$AssetModel {
  String get ticker => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'icon_url')
  String get iconUrl => throw _privateConstructorUsedError;

  /// Serializes this AssetModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AssetModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AssetModelCopyWith<AssetModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AssetModelCopyWith<$Res> {
  factory $AssetModelCopyWith(
    AssetModel value,
    $Res Function(AssetModel) then,
  ) = _$AssetModelCopyWithImpl<$Res, AssetModel>;
  @useResult
  $Res call({
    String ticker,
    String name,
    @JsonKey(name: 'icon_url') String iconUrl,
  });
}

/// @nodoc
class _$AssetModelCopyWithImpl<$Res, $Val extends AssetModel>
    implements $AssetModelCopyWith<$Res> {
  _$AssetModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AssetModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? ticker = null,
    Object? name = null,
    Object? iconUrl = null,
  }) {
    return _then(
      _value.copyWith(
            ticker: null == ticker
                ? _value.ticker
                : ticker // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            iconUrl: null == iconUrl
                ? _value.iconUrl
                : iconUrl // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AssetModelImplCopyWith<$Res>
    implements $AssetModelCopyWith<$Res> {
  factory _$$AssetModelImplCopyWith(
    _$AssetModelImpl value,
    $Res Function(_$AssetModelImpl) then,
  ) = __$$AssetModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String ticker,
    String name,
    @JsonKey(name: 'icon_url') String iconUrl,
  });
}

/// @nodoc
class __$$AssetModelImplCopyWithImpl<$Res>
    extends _$AssetModelCopyWithImpl<$Res, _$AssetModelImpl>
    implements _$$AssetModelImplCopyWith<$Res> {
  __$$AssetModelImplCopyWithImpl(
    _$AssetModelImpl _value,
    $Res Function(_$AssetModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AssetModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? ticker = null,
    Object? name = null,
    Object? iconUrl = null,
  }) {
    return _then(
      _$AssetModelImpl(
        ticker: null == ticker
            ? _value.ticker
            : ticker // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        iconUrl: null == iconUrl
            ? _value.iconUrl
            : iconUrl // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AssetModelImpl implements _AssetModel {
  const _$AssetModelImpl({
    required this.ticker,
    required this.name,
    @JsonKey(name: 'icon_url') required this.iconUrl,
  });

  factory _$AssetModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$AssetModelImplFromJson(json);

  @override
  final String ticker;
  @override
  final String name;
  @override
  @JsonKey(name: 'icon_url')
  final String iconUrl;

  @override
  String toString() {
    return 'AssetModel(ticker: $ticker, name: $name, iconUrl: $iconUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AssetModelImpl &&
            (identical(other.ticker, ticker) || other.ticker == ticker) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.iconUrl, iconUrl) || other.iconUrl == iconUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, ticker, name, iconUrl);

  /// Create a copy of AssetModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AssetModelImplCopyWith<_$AssetModelImpl> get copyWith =>
      __$$AssetModelImplCopyWithImpl<_$AssetModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AssetModelImplToJson(this);
  }
}

abstract class _AssetModel implements AssetModel {
  const factory _AssetModel({
    required final String ticker,
    required final String name,
    @JsonKey(name: 'icon_url') required final String iconUrl,
  }) = _$AssetModelImpl;

  factory _AssetModel.fromJson(Map<String, dynamic> json) =
      _$AssetModelImpl.fromJson;

  @override
  String get ticker;
  @override
  String get name;
  @override
  @JsonKey(name: 'icon_url')
  String get iconUrl;

  /// Create a copy of AssetModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AssetModelImplCopyWith<_$AssetModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
