import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mocktail/mocktail.dart';
import 'fake_repositories.dart';

/// FlutterSecureStorage em memoria (mapa compartilhado) para testes T1.
MockFlutterSecureStorage t1MemoryStorage(Map<String, String> data) {
  final m = MockFlutterSecureStorage();
  when(() => m.read(key: any(named: 'key'))).thenAnswer(
      (i) async => data[i.namedArguments[#key] as String]);
  when(() => m.write(
          key: any(named: 'key'), value: any(named: 'value')))
      .thenAnswer((i) async {
    data[i.namedArguments[#key] as String] =
        i.namedArguments[#value] as String;
  });
  when(() => m.delete(key: any(named: 'key'))).thenAnswer((i) async {
    data.remove(i.namedArguments[#key] as String);
  });
  return m;
}
