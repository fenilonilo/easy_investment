import 'package:dio/dio.dart';
import 'secure_storage_service.dart';

class AuthInterceptor extends Interceptor {
  final SecureStorageService _storage;
  final void Function() onLogout;

  AuthInterceptor(this._storage, {required this.onLogout});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _storage.readToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // só expira sessão se a requisição levava token (401 do login = senha errada)
    if (err.response?.statusCode == 401 &&
        err.requestOptions.headers.containsKey('Authorization')) {
      await _storage.clearToken();
      onLogout();
    }
    handler.next(err);
  }
}
