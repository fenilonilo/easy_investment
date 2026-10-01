import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:easy_finance/data/datasources/user_storage_service.dart';
import 'package:easy_finance/data/models/user_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mocktail/mocktail.dart';

class _T2SecureStorage extends Mock implements FlutterSecureStorage {}

/// UserStorageService em memoria (nao toca secure storage).
class T2InMemoryUserStorage extends UserStorageService {
  UserModel? stored;
  int saveCalls = 0;
  T2InMemoryUserStorage({this.stored}) : super(_T2SecureStorage());

  @override
  Future<void> saveUser(UserModel user) async {
    saveCalls++;
    stored = user;
  }

  @override
  Future<UserModel?> readUser() async => stored;

  @override
  Future<void> clear() async => stored = null;
}

const t2User = UserModel(
  id: 'u-1',
  name: 'Usuario Teste',
  email: 'teste@example.com',
  birthDate: '2001-01-01',
  investorProfile: 'CONSERVATIVE',
  isActive: true,
);

const t2UserJson = {
  'id': 'u-1',
  'name': 'Usuario Teste',
  'email': 'teste@example.com',
  'birth_date': '2001-01-01',
  'investor_profile': 'CONSERVATIVE',
  'is_active': true,
};

String t2Jwt(String sub) {
  String b(Object o) =>
      base64Url.encode(utf8.encode(jsonEncode(o))).replaceAll('=', '');
  return '${b({'alg': 'none'})}.${b({'sub': sub})}.sig';
}

/// Adapter que registra requests e responde via [handler] -> (status, body).
class T2Adapter implements HttpClientAdapter {
  final List<RequestOptions> requests = [];
  final (int, Object?) Function(RequestOptions) handler;
  T2Adapter(this.handler);

  List<RequestOptions> puts() =>
      requests.where((r) => r.method == 'PUT').toList();

  @override
  Future<ResponseBody> fetch(RequestOptions o, Stream<Uint8List>? s,
      Future<void>? c) async {
    requests.add(o);
    final (status, body) = handler(o);
    return ResponseBody.fromString(jsonEncode(body ?? {}), status, headers: {
      Headers.contentTypeHeader: ['application/json'],
    });
  }

  @override
  void close({bool force = false}) {}
}

Dio t2Dio(T2Adapter a) =>
    Dio(BaseOptions(baseUrl: 'http://t2.test'))..httpClientAdapter = a;
