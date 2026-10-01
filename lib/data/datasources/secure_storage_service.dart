import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _tokenKey = 'auth_token';

class SecureStorageService {
  final FlutterSecureStorage _storage;

  const SecureStorageService(this._storage);

  Future<void> saveToken(String token) =>
      _storage.write(key: _tokenKey, value: token);

  /// Token ilegivel (storage corrompido) vira "sem token" e e descartado,
  /// para o app cair no login em vez de tela branca.
  Future<String?> readToken() async {
    try {
      return await _storage.read(key: _tokenKey);
    } catch (_) {
      try {
        await _storage.delete(key: _tokenKey);
      } catch (_) {}
      return null;
    }
  }

  Future<void> clearToken() => _storage.delete(key: _tokenKey);

  Future<bool> hasToken() async => (await readToken()) != null;
}

final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  const storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  return SecureStorageService(storage);
});
