// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'asset_quote_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AssetQuoteModel _$AssetQuoteModelFromJson(Map<String, dynamic> json) {
  return _AssetQuoteModel.fromJson(json);
}

/// @nodoc
mixin _$AssetQuoteModel {
  String get ticker => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'icon_url')
  String get iconUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'price_usd')
  double get priceUsd => throw _privateConstructorUsedError;
  String get direction => throw _privateConstructorUsedError;

  /// Serializes this AssetQuoteModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AssetQuoteModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AssetQuoteModelCopyWith<AssetQuoteModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AssetQuoteModelCopyWith<$Res> {
  factory $AssetQuoteModelCopyWith(
    AssetQuoteModel value,
    $Res Function(AssetQuoteModel) then,
  ) = _$AssetQuoteModelCopyWithImpl<$Res, AssetQuoteModel>;
  @useResult
  $Res call({
    String ticker,
    String name,
    @JsonKey(name: 'icon_url') String iconUrl,
    @JsonKey(name: 'price_usd') double priceUsd,
    String direction,
  });
}

/// @nodoc
class _$AssetQuoteModelCopyWithImpl<$Res, $Val extends AssetQuoteModel>
    implements $AssetQuoteModelCopyWith<$Res> {
  _$AssetQuoteModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AssetQuoteModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? ticker = null,
    Object? name = null,
    Object? iconUrl = null,
    Object? priceUsd = null,
    Object? direction = null,
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
            priceUsd: null == priceUsd
                ? _value.priceUsd
                : priceUsd // ignore: cast_nullable_to_non_nullable
                      as double,
            direction: null == direction
                ? _value.direction
                : direction // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AssetQuoteModelImplCopyWith<$Res>
    implements $AssetQuoteModelCopyWith<$Res> {
  factory _$$AssetQuoteModelImplCopyWith(
    _$AssetQuoteModelImpl value,
    $Res Function(_$AssetQuoteModelImpl) then,
  ) = __$$AssetQuoteModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String ticker,
    String name,
    @JsonKey(name: 'icon_url') String iconUrl,
    @JsonKey(name: 'price_usd') double priceUsd,
    String direction,
  });
}

/// @nodoc
class __$$AssetQuoteModelImplCopyWithImpl<$Res>
    extends _$AssetQuoteModelCopyWithImpl<$Res, _$AssetQuoteModelImpl>
    implements _$$AssetQuoteModelImplCopyWith<$Res> {
  __$$AssetQuoteModelImplCopyWithImpl(
    _$AssetQuoteModelImpl _value,
    $Res Function(_$AssetQuoteModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AssetQuoteModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? ticker = null,
    Object? name = null,
    Object? iconUrl = null,
    Object? priceUsd = null,
    Object? direction = null,
  }) {
    return _then(
      _$AssetQuoteModelImpl(
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
        priceUsd: null == priceUsd
            ? _value.priceUsd
            : priceUsd // ignore: cast_nullable_to_non_nullable
                  as double,
        direction: null == direction
            ? _value.direction
            : direction // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AssetQuoteModelImpl implements _AssetQuoteModel {
  const _$AssetQuoteModelImpl({
    required this.ticker,
    required this.name,
    @JsonKey(name: 'icon_url') required this.iconUrl,
    @JsonKey(name: 'price_usd') required this.priceUsd,
    required this.direction,
  });

  factory _$AssetQuoteModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$AssetQuoteModelImplFromJson(json);

  @override
  final String ticker;
  @override
  final String name;
  @override
  @JsonKey(name: 'icon_url')
  final String iconUrl;
  @override
  @JsonKey(name: 'price_usd')
  final double priceUsd;
  @override
  final String direction;

  @override
  String toString() {
    return 'AssetQuoteModel(ticker: $ticker, name: $name, iconUrl: $iconUrl, priceUsd: $priceUsd, direction: $direction)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AssetQuoteModelImpl &&
            (identical(other.ticker, ticker) || other.ticker == ticker) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.iconUrl, iconUrl) || other.iconUrl == iconUrl) &&
            (identical(other.priceUsd, priceUsd) ||
                other.priceUsd == priceUsd) &&
            (identical(other.direction, direction) ||
                other.direction == direction));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, ticker, name, iconUrl, priceUsd, direction);

  /// Create a copy of AssetQuoteModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AssetQuoteModelImplCopyWith<_$AssetQuoteModelImpl> get copyWith =>
      __$$AssetQuoteModelImplCopyWithImpl<_$AssetQuoteModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AssetQuoteModelImplToJson(this);
  }
}

abstract class _AssetQuoteModel implements AssetQuoteModel {
  const factory _AssetQuoteModel({
    required final String ticker,
    required final String name,
    @JsonKey(name: 'icon_url') required final String iconUrl,
    @JsonKey(name: 'price_usd') required final double priceUsd,
    required final String direction,
  }) = _$AssetQuoteModelImpl;

  factory _AssetQuoteModel.fromJson(Map<String, dynamic> json) =
      _$AssetQuoteModelImpl.fromJson;

  @override
  String get ticker;
  @override
  String get name;
  @override
  @JsonKey(name: 'icon_url')
  String get iconUrl;
  @override
  @JsonKey(name: 'price_usd')
  double get priceUsd;
  @override
  String get direction;

  /// Create a copy of AssetQuoteModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AssetQuoteModelImplCopyWith<_$AssetQuoteModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
