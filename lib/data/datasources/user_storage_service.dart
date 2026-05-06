import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';

const _userKey = 'user_data';

class UserStorageService {
  final FlutterSecureStorage _storage;
  const UserStorageService(this._storage);

  Future<void> saveUser(UserModel user) async {
    final json = jsonEncode({
      'id': user.id,
      'name': user.name,
      'email': user.email,
      'birth_date': user.birthDate,
      'investor_profile': user.investorProfile,
      'is_active': user.isActive,
    });
    await _storage.write(key: _userKey, value: json);
  }

  Future<UserModel?> readUser() async {
    final raw = await _storage.read(key: _userKey);
    if (raw == null) return null;
    try {
      return UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> clear() => _storage.delete(key: _userKey);
}

final userStorageServiceProvider = Provider<UserStorageService>((ref) {
  const storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  return UserStorageService(storage);
});
