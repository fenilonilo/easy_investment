// T1 - regressao Auth/Config: B01, B15, B27 (ver docs/qa/QA-SINTESE.md).
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:easy_finance/app.dart';
import 'package:easy_finance/core/router/app_router.dart';
import 'package:easy_finance/data/datasources/auth_interceptor.dart';
import 'package:easy_finance/data/datasources/dio_client.dart';
import 'package:easy_finance/data/datasources/secure_storage_service.dart';
import 'package:easy_finance/data/datasources/user_storage_service.dart';
import 'package:easy_finance/presentation/views/config/config_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/t1_memory_storage.dart';

const _userJson = '{"id":1,"name":"Ana","email":"a@b.com"}';

class _Adapter implements HttpClientAdapter {
  final int status;
  _Adapter(this.status);
  @override
  Future<ResponseBody> fetch(RequestOptions o, Stream<Uint8List>? s,
          Future<void>? c) async =>
      ResponseBody.fromString('{"detail":"Token invalido ou expirado"}', status,
          headers: {
            Headers.contentTypeHeader: ['application/json']
          });
  @override
  void close({bool force = false}) {}
}

List<Override> _overrides(Map<String, String> data) {
  final s = t1MemoryStorage(data);
  return [
    secureStorageServiceProvider.overrideWithValue(SecureStorageService(s)),
    userStorageServiceProvider.overrideWithValue(UserStorageService(s)),
  ];
}

void main() {
  group('R1: token ilegivel no storage', () {
    test('readToken devolve null e descarta o valor, sem lancar', () async {
      final data = {'auth_token': 'lixo'};
      final m = t1MemoryStorage(data);
      when(() => m.read(key: any(named: 'key')))
          .thenThrow(const FormatException('token corrompido'));
      final svc = SecureStorageService(m);

      expect(await svc.readToken(), isNull);
      expect(await svc.hasToken(), isFalse);
      verify(() => m.delete(key: 'auth_token')).called(greaterThan(0));
    });

    test('readToken devolve null mesmo se o delete tambem falhar', () async {
      final m = t1MemoryStorage({});
      when(() => m.read(key: any(named: 'key'))).thenThrow(Exception('x'));
      when(() => m.delete(key: any(named: 'key'))).thenThrow(Exception('y'));
      expect(await SecureStorageService(m).readToken(), isNull);
    });
  });

  late Map<String, String> data;
  setUp(() => data = {'auth_token': 'tok', 'user_data': _userJson});

  // App real (router + shell), como no browser: Config dentro do StatefulShellRoute.
  Future<void> pumpConfig(WidgetTester t) async {
    t.view.physicalSize = const Size(1200, 4000); // tela alta: botao Sair visivel
    addTearDown(t.view.resetPhysicalSize);
    await t.pumpWidget(ProviderScope(
      overrides: _overrides(data),
      child: const FinanceProApp(),
    ));
    ProviderScope.containerOf(t.element(find.byType(FinanceProApp)))
        .read(appRouterProvider)
        .go('/config');
    await t.pumpAndSettle();
  }

  Future<void> openDialog(WidgetTester t) async {
    final btn = find.text('Sair da conta');
    await t.ensureVisible(btn);
    await t.tap(btn);
    await t.pumpAndSettle();
    expect(find.text('Deseja realmente sair da sua conta?'), findsOneWidget);
  }

  // Confirma e devolve excecao capturada (overflow do LoginView em tela
  // sintetica e ruido alheio; so 'popped the last page' interessa).
  Future<Object?> confirmSair(WidgetTester t) async {
    await t.tap(find.widgetWithText(TextButton, 'Sair'));
    await t.pumpAndSettle();
    return t.takeException();
  }

  testWidgets('B01: Cancelar fecha so o dialogo; Config segue e token intacto',
      (t) async {
    await pumpConfig(t);
    await openDialog(t);
    await t.tap(find.text('Cancelar'));
    await t.pumpAndSettle();

    expect(t.takeException(), isNull);
    expect(find.text('Deseja realmente sair da sua conta?'), findsNothing);
    expect(find.text('Configurações'), findsOneWidget);
    expect(find.text('Entrar'), findsNothing);
    expect(data['auth_token'], 'tok');
  });

  testWidgets('B01: Confirmar Sair limpa token e navega a /login sem excecao',
      (t) async {
    await pumpConfig(t);
    await openDialog(t);
    final err = await confirmSair(t);

    expect(err.toString(), isNot(contains('popped the last page')));
    expect(data.containsKey('auth_token'), isFalse);
    expect(find.text('Entrar'), findsWidgets);
  });

  testWidgets('B27: logout via Config limpa tambem user_data', (t) async {
    await pumpConfig(t);
    await openDialog(t);
    final err = await confirmSair(t);

    expect(data.containsKey('auth_token'), isFalse);
    expect(data.containsKey('user_data'), isFalse);
  });

  test('B15: AuthInterceptor em 401 limpa token e chama onLogout', () async {
    final s = t1MemoryStorage(data);
    var called = 0;
    final dio = Dio(BaseOptions(baseUrl: 'http://x'))
      ..httpClientAdapter = _Adapter(401)
      ..interceptors.add(AuthInterceptor(SecureStorageService(s),
          onLogout: () => called++));
    await expectLater(dio.get('/a'), throwsA(isA<DioException>()));
    expect(called, 1);
    expect(data.containsKey('auth_token'), isFalse);
  });

  test('B15: 200 nao dispara logout', () async {
    final s = t1MemoryStorage(data);
    var called = 0;
    final dio = Dio(BaseOptions(baseUrl: 'http://x'))
      ..httpClientAdapter = _Adapter(200)
      ..interceptors.add(AuthInterceptor(SecureStorageService(s),
          onLogout: () => called++));
    await dio.get('/a');
    expect(called, 0);
    expect(data['auth_token'], 'tok');
  });

  testWidgets(
      'B15: 401 no dioClientProvider real do app limpa sessao e vai ao login',
      (t) async {
    await t.pumpWidget(ProviderScope(
      overrides: _overrides(data),
      child: const FinanceProApp(),
    ));
    final container =
        ProviderScope.containerOf(t.element(find.byType(FinanceProApp)));
    container.read(appRouterProvider).go('/config');
    await t.pumpAndSettle();
    expect(find.text('Configurações'), findsOneWidget);

    final dio = container.read(dioClientProvider)
      ..httpClientAdapter = _Adapter(401);
    await t.runAsync(() async {
      await expectLater(dio.get('/portfolio'), throwsA(isA<DioException>()));
    });
    await t.pumpAndSettle();

    expect(data.containsKey('auth_token'), isFalse);
    expect(find.text('Configurações'), findsNothing);
    expect(find.text('Entrar'), findsWidgets); // LoginView
  });
}

