// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'financials_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

FinancialsModel _$FinancialsModelFromJson(Map<String, dynamic> json) {
  return _FinancialsModel.fromJson(json);
}

/// @nodoc
mixin _$FinancialsModel {
  @JsonKey(name: 'market_cap')
  int? get marketCap => throw _privateConstructorUsedError;
  @JsonKey(name: 'pe_ratio')
  double? get peRatio => throw _privateConstructorUsedError;
  @JsonKey(name: 'dividend_yield')
  double? get dividendYield => throw _privateConstructorUsedError;
  @JsonKey(name: 'target_price')
  double? get targetPrice => throw _privateConstructorUsedError;
  String? get recommendation => throw _privateConstructorUsedError;

  /// Serializes this FinancialsModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FinancialsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FinancialsModelCopyWith<FinancialsModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FinancialsModelCopyWith<$Res> {
  factory $FinancialsModelCopyWith(
    FinancialsModel value,
    $Res Function(FinancialsModel) then,
  ) = _$FinancialsModelCopyWithImpl<$Res, FinancialsModel>;
  @useResult
  $Res call({
    @JsonKey(name: 'market_cap') int? marketCap,
    @JsonKey(name: 'pe_ratio') double? peRatio,
    @JsonKey(name: 'dividend_yield') double? dividendYield,
    @JsonKey(name: 'target_price') double? targetPrice,
    String? recommendation,
  });
}

/// @nodoc
class _$FinancialsModelCopyWithImpl<$Res, $Val extends FinancialsModel>
    implements $FinancialsModelCopyWith<$Res> {
  _$FinancialsModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FinancialsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? marketCap = freezed,
    Object? peRatio = freezed,
    Object? dividendYield = freezed,
    Object? targetPrice = freezed,
    Object? recommendation = freezed,
  }) {
    return _then(
      _value.copyWith(
            marketCap: freezed == marketCap
                ? _value.marketCap
                : marketCap // ignore: cast_nullable_to_non_nullable
                      as int?,
            peRatio: freezed == peRatio
                ? _value.peRatio
                : peRatio // ignore: cast_nullable_to_non_nullable
                      as double?,
            dividendYield: freezed == dividendYield
                ? _value.dividendYield
                : dividendYield // ignore: cast_nullable_to_non_nullable
                      as double?,
            targetPrice: freezed == targetPrice
                ? _value.targetPrice
                : targetPrice // ignore: cast_nullable_to_non_nullable
                      as double?,
            recommendation: freezed == recommendation
                ? _value.recommendation
                : recommendation // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FinancialsModelImplCopyWith<$Res>
    implements $FinancialsModelCopyWith<$Res> {
  factory _$$FinancialsModelImplCopyWith(
    _$FinancialsModelImpl value,
    $Res Function(_$FinancialsModelImpl) then,
  ) = __$$FinancialsModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'market_cap') int? marketCap,
    @JsonKey(name: 'pe_ratio') double? peRatio,
    @JsonKey(name: 'dividend_yield') double? dividendYield,
    @JsonKey(name: 'target_price') double? targetPrice,
    String? recommendation,
  });
}

/// @nodoc
class __$$FinancialsModelImplCopyWithImpl<$Res>
    extends _$FinancialsModelCopyWithImpl<$Res, _$FinancialsModelImpl>
    implements _$$FinancialsModelImplCopyWith<$Res> {
  __$$FinancialsModelImplCopyWithImpl(
    _$FinancialsModelImpl _value,
    $Res Function(_$FinancialsModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FinancialsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? marketCap = freezed,
    Object? peRatio = freezed,
    Object? dividendYield = freezed,
    Object? targetPrice = freezed,
    Object? recommendation = freezed,
  }) {
    return _then(
      _$FinancialsModelImpl(
        marketCap: freezed == marketCap
            ? _value.marketCap
            : marketCap // ignore: cast_nullable_to_non_nullable
                  as int?,
        peRatio: freezed == peRatio
            ? _value.peRatio
            : peRatio // ignore: cast_nullable_to_non_nullable
                  as double?,
        dividendYield: freezed == dividendYield
            ? _value.dividendYield
            : dividendYield // ignore: cast_nullable_to_non_nullable
                  as double?,
        targetPrice: freezed == targetPrice
            ? _value.targetPrice
            : targetPrice // ignore: cast_nullable_to_non_nullable
                  as double?,
        recommendation: freezed == recommendation
            ? _value.recommendation
            : recommendation // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$FinancialsModelImpl implements _FinancialsModel {
  const _$FinancialsModelImpl({
    @JsonKey(name: 'market_cap') this.marketCap,
    @JsonKey(name: 'pe_ratio') this.peRatio,
    @JsonKey(name: 'dividend_yield') this.dividendYield,
    @JsonKey(name: 'target_price') this.targetPrice,
    this.recommendation,
  });

  factory _$FinancialsModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$FinancialsModelImplFromJson(json);

  @override
  @JsonKey(name: 'market_cap')
  final int? marketCap;
  @override
  @JsonKey(name: 'pe_ratio')
  final double? peRatio;
  @override
  @JsonKey(name: 'dividend_yield')
  final double? dividendYield;
  @override
  @JsonKey(name: 'target_price')
  final double? targetPrice;
  @override
  final String? recommendation;

  @override
  String toString() {
    return 'FinancialsModel(marketCap: $marketCap, peRatio: $peRatio, dividendYield: $dividendYield, targetPrice: $targetPrice, recommendation: $recommendation)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FinancialsModelImpl &&
            (identical(other.marketCap, marketCap) ||
                other.marketCap == marketCap) &&
            (identical(other.peRatio, peRatio) || other.peRatio == peRatio) &&
            (identical(other.dividendYield, dividendYield) ||
                other.dividendYield == dividendYield) &&
            (identical(other.targetPrice, targetPrice) ||
                other.targetPrice == targetPrice) &&
            (identical(other.recommendation, recommendation) ||
                other.recommendation == recommendation));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    marketCap,
    peRatio,
    dividendYield,
    targetPrice,
    recommendation,
  );

  /// Create a copy of FinancialsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FinancialsModelImplCopyWith<_$FinancialsModelImpl> get copyWith =>
      __$$FinancialsModelImplCopyWithImpl<_$FinancialsModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$FinancialsModelImplToJson(this);
  }
}

abstract class _FinancialsModel implements FinancialsModel {
  const factory _FinancialsModel({
    @JsonKey(name: 'market_cap') final int? marketCap,
    @JsonKey(name: 'pe_ratio') final double? peRatio,
    @JsonKey(name: 'dividend_yield') final double? dividendYield,
    @JsonKey(name: 'target_price') final double? targetPrice,
    final String? recommendation,
  }) = _$FinancialsModelImpl;

  factory _FinancialsModel.fromJson(Map<String, dynamic> json) =
      _$FinancialsModelImpl.fromJson;

  @override
  @JsonKey(name: 'market_cap')
  int? get marketCap;
  @override
  @JsonKey(name: 'pe_ratio')
  double? get peRatio;
  @override
  @JsonKey(name: 'dividend_yield')
  double? get dividendYield;
  @override
  @JsonKey(name: 'target_price')
  double? get targetPrice;
  @override
  String? get recommendation;

  /// Create a copy of FinancialsModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FinancialsModelImplCopyWith<_$FinancialsModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
