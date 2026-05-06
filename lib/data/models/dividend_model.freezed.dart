// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dividend_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

DividendModel _$DividendModelFromJson(Map<String, dynamic> json) {
  return _DividendModel.fromJson(json);
}

/// @nodoc
mixin _$DividendModel {
  String get date => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;

  /// Serializes this DividendModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DividendModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DividendModelCopyWith<DividendModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DividendModelCopyWith<$Res> {
  factory $DividendModelCopyWith(
    DividendModel value,
    $Res Function(DividendModel) then,
  ) = _$DividendModelCopyWithImpl<$Res, DividendModel>;
  @useResult
  $Res call({String date, double amount});
}

/// @nodoc
class _$DividendModelCopyWithImpl<$Res, $Val extends DividendModel>
    implements $DividendModelCopyWith<$Res> {
  _$DividendModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DividendModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? date = null, Object? amount = null}) {
    return _then(
      _value.copyWith(
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as String,
            amount: null == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DividendModelImplCopyWith<$Res>
    implements $DividendModelCopyWith<$Res> {
  factory _$$DividendModelImplCopyWith(
    _$DividendModelImpl value,
    $Res Function(_$DividendModelImpl) then,
  ) = __$$DividendModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String date, double amount});
}

/// @nodoc
class __$$DividendModelImplCopyWithImpl<$Res>
    extends _$DividendModelCopyWithImpl<$Res, _$DividendModelImpl>
    implements _$$DividendModelImplCopyWith<$Res> {
  __$$DividendModelImplCopyWithImpl(
    _$DividendModelImpl _value,
    $Res Function(_$DividendModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DividendModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? date = null, Object? amount = null}) {
    return _then(
      _$DividendModelImpl(
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as String,
        amount: null == amount
            ? _value.amount
            : amount // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DividendModelImpl implements _DividendModel {
  const _$DividendModelImpl({required this.date, required this.amount});

  factory _$DividendModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$DividendModelImplFromJson(json);

  @override
  final String date;
  @override
  final double amount;

  @override
  String toString() {
    return 'DividendModel(date: $date, amount: $amount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DividendModelImpl &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.amount, amount) || other.amount == amount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, date, amount);

  /// Create a copy of DividendModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DividendModelImplCopyWith<_$DividendModelImpl> get copyWith =>
      __$$DividendModelImplCopyWithImpl<_$DividendModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DividendModelImplToJson(this);
  }
}

abstract class _DividendModel implements DividendModel {
  const factory _DividendModel({
    required final String date,
    required final double amount,
  }) = _$DividendModelImpl;

  factory _DividendModel.fromJson(Map<String, dynamic> json) =
      _$DividendModelImpl.fromJson;

  @override
  String get date;
  @override
  double get amount;

  /// Create a copy of DividendModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DividendModelImplCopyWith<_$DividendModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
