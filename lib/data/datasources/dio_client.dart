import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/api_constants.dart';
import '../../core/router/app_router.dart';
import 'auth_interceptor.dart';
import 'secure_storage_service.dart';
import 'user_storage_service.dart';

/// Chave do ScaffoldMessenger raiz (registrada em app.dart) para avisos fora de contexto.
final rootMessengerKey = GlobalKey<ScaffoldMessengerState>();

/// Chamado em 401 (token já limpo pelo interceptor): limpa user_data, avisa e vai ao login.
/// Sobrescrevível em testes via overrideWith.
final logoutCallbackProvider = StateProvider<void Function()>(
  (ref) => () {
    ref.read(userStorageServiceProvider).clear();
    ref.read(appRouterProvider).go('/login');
    rootMessengerKey.currentState
      ?..hideCurrentSnackBar()
      ..showSnackBar(
          const SnackBar(content: Text('Sessão expirada. Faça login novamente.')));
  },
);

final dioClientProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  final storage = ref.read(secureStorageServiceProvider);
  final onLogout = ref.read(logoutCallbackProvider);

  dio.interceptors.add(AuthInterceptor(storage, onLogout: onLogout));

  return dio;
});
