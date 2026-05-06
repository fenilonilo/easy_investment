import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String name,
    required String email,
    @JsonKey(name: 'birth_date') required String birthDate,
    @JsonKey(name: 'investor_profile') required String investorProfile,
    @JsonKey(name: 'is_active') required bool isActive,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}
