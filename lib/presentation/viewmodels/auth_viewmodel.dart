import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/secure_storage_service.dart';
import '../../data/datasources/user_storage_service.dart';
import '../../data/repositories/auth_repository_impl.dart';

enum AuthStatus { initial, loading, success, error }

class AuthState {
  final AuthStatus status;
  final String? error;
  const AuthState({this.status = AuthStatus.initial, this.error});
  AuthState copyWith({AuthStatus? status, String? error}) =>
      AuthState(status: status ?? this.status, error: error ?? this.error);
}

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref _ref;
  AuthNotifier(this._ref) : super(const AuthState());

  Future<void> login(String email, String password) async {
    state = const AuthState(status: AuthStatus.loading);
    try {
      final repo = _ref.read(authRepositoryProvider);
      final storage = _ref.read(secureStorageServiceProvider);
      final token = await repo.login(email, password);
      await storage.saveToken(token.accessToken);
      state = const AuthState(status: AuthStatus.success);
    } catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        error: _extractError(e),
      );
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String birthDate,
    required String investorProfile,
  }) async {
    state = const AuthState(status: AuthStatus.loading);
    try {
      final repo = _ref.read(authRepositoryProvider);
      await repo.register(
        name: name,
        email: email,
        password: password,
        birthDate: birthDate,
        investorProfile: investorProfile,
      );
      // Auto-login after register
      await login(email, password);
    } catch (e) {
      state = AuthState(status: AuthStatus.error, error: _extractError(e));
    }
  }

  Future<void> logout() async {
    final storage = _ref.read(secureStorageServiceProvider);
    await storage.clearToken();
    await _ref.read(userStorageServiceProvider).clear();
    state = const AuthState();
  }

  String _extractError(Object e) {
    if (e is Exception) {
      final msg = e.toString();
      if (msg.contains('401') || msg.contains('Unauthorized')) {
        return 'Email ou senha incorretos.';
      }
      if (msg.contains('422')) return 'Dados inválidos.';
      if (msg.contains('400')) return 'Email já cadastrado.';
      if (msg.contains('SocketException') || msg.contains('connect')) {
        return 'Sem conexão com o servidor.';
      }
    }
    return 'Erro inesperado. Tente novamente.';
  }
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) => AuthNotifier(ref));
