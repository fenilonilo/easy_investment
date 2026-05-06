import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/api_constants.dart';
import 'auth_interceptor.dart';
import 'secure_storage_service.dart';

final logoutCallbackProvider = StateProvider<void Function()>(
  (_) => () {},
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
