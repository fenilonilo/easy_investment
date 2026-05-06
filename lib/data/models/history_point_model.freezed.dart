// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'history_point_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

HistoryPointModel _$HistoryPointModelFromJson(Map<String, dynamic> json) {
  return _HistoryPointModel.fromJson(json);
}

/// @nodoc
mixin _$HistoryPointModel {
  String get date => throw _privateConstructorUsedError;
  double get close => throw _privateConstructorUsedError;

  /// Serializes this HistoryPointModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of HistoryPointModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HistoryPointModelCopyWith<HistoryPointModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HistoryPointModelCopyWith<$Res> {
  factory $HistoryPointModelCopyWith(
    HistoryPointModel value,
    $Res Function(HistoryPointModel) then,
  ) = _$HistoryPointModelCopyWithImpl<$Res, HistoryPointModel>;
  @useResult
  $Res call({String date, double close});
}

/// @nodoc
class _$HistoryPointModelCopyWithImpl<$Res, $Val extends HistoryPointModel>
    implements $HistoryPointModelCopyWith<$Res> {
  _$HistoryPointModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HistoryPointModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? date = null, Object? close = null}) {
    return _then(
      _value.copyWith(
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as String,
            close: null == close
                ? _value.close
                : close // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$HistoryPointModelImplCopyWith<$Res>
    implements $HistoryPointModelCopyWith<$Res> {
  factory _$$HistoryPointModelImplCopyWith(
    _$HistoryPointModelImpl value,
    $Res Function(_$HistoryPointModelImpl) then,
  ) = __$$HistoryPointModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String date, double close});
}

/// @nodoc
class __$$HistoryPointModelImplCopyWithImpl<$Res>
    extends _$HistoryPointModelCopyWithImpl<$Res, _$HistoryPointModelImpl>
    implements _$$HistoryPointModelImplCopyWith<$Res> {
  __$$HistoryPointModelImplCopyWithImpl(
    _$HistoryPointModelImpl _value,
    $Res Function(_$HistoryPointModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of HistoryPointModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? date = null, Object? close = null}) {
    return _then(
      _$HistoryPointModelImpl(
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as String,
        close: null == close
            ? _value.close
            : close // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$HistoryPointModelImpl implements _HistoryPointModel {
  const _$HistoryPointModelImpl({required this.date, required this.close});

  factory _$HistoryPointModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$HistoryPointModelImplFromJson(json);

  @override
  final String date;
  @override
  final double close;

  @override
  String toString() {
    return 'HistoryPointModel(date: $date, close: $close)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HistoryPointModelImpl &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.close, close) || other.close == close));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, date, close);

  /// Create a copy of HistoryPointModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HistoryPointModelImplCopyWith<_$HistoryPointModelImpl> get copyWith =>
      __$$HistoryPointModelImplCopyWithImpl<_$HistoryPointModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$HistoryPointModelImplToJson(this);
  }
}

abstract class _HistoryPointModel implements HistoryPointModel {
  const factory _HistoryPointModel({
    required final String date,
    required final double close,
  }) = _$HistoryPointModelImpl;

  factory _HistoryPointModel.fromJson(Map<String, dynamic> json) =
      _$HistoryPointModelImpl.fromJson;

  @override
  String get date;
  @override
  double get close;

  /// Create a copy of HistoryPointModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HistoryPointModelImplCopyWith<_$HistoryPointModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
