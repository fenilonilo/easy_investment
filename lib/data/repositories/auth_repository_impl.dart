import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/api_endpoints.dart';
import '../../data/datasources/dio_client.dart';
import '../../data/models/auth_token_model.dart';
import '../../data/models/user_model.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final Dio _dio;
  AuthRepositoryImpl(this._dio);

  @override
  Future<AuthTokenModel> login(String email, String password) async {
    final response = await _dio.post(
      ApiEndpoints.login,
      data: 'username=${Uri.encodeComponent(email)}&password=${Uri.encodeComponent(password)}&grant_type=password',
      options: Options(
        contentType: 'application/x-www-form-urlencoded',
      ),
    );
    return AuthTokenModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required String birthDate,
    required String investorProfile,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.register,
      data: {
        'name': name,
        'email': email,
        'password': password,
        'birth_date': birthDate,
        'investor_profile': investorProfile,
      },
    );
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.read(dioClientProvider));
});
