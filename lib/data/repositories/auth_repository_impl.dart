import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/api_endpoints.dart';
import '../../data/datasources/dio_client.dart';
import '../../data/datasources/user_storage_service.dart';
import '../../data/models/auth_token_model.dart';
import '../../data/models/user_model.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final Dio _dio;
  final UserStorageService? _userStorage;
  AuthRepositoryImpl(this._dio, [this._userStorage]);

  @override
  Future<AuthTokenModel> login(String email, String password) async {
    final response = await _dio.post(
      ApiEndpoints.login,
      data: 'username=${Uri.encodeComponent(email)}&password=${Uri.encodeComponent(password)}&grant_type=password',
      options: Options(
        contentType: 'application/x-www-form-urlencoded',
      ),
    );
    final data = response.data as Map<String, dynamic>;
    await _persistUser(data['user'], email);
    return AuthTokenModel.fromJson(data);
  }

  // O back so devolve o token no login e nao tem GET /me: usa o usuario do
  // payload se vier; senao mantem o salvo no cadastro (mesmo e-mail) e descarta
  // o de outra conta, para o Perfil nunca mostrar dados de outro usuario.
  Future<void> _persistUser(Object? userJson, String email) async {
    final storage = _userStorage;
    if (storage == null) return;
    try {
      if (userJson is Map<String, dynamic>) {
        await storage.saveUser(UserModel.fromJson(userJson));
        return;
      }
      final saved = await storage.readUser();
      if (saved != null &&
          saved.email.toLowerCase() != email.trim().toLowerCase()) {
        await storage.clear();
      }
    } catch (_) {}
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
    final user = UserModel.fromJson(response.data as Map<String, dynamic>);
    try {
      await _userStorage?.saveUser(user);
    } catch (_) {}
    return user;
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
      ref.read(dioClientProvider), ref.read(userStorageServiceProvider));
});
