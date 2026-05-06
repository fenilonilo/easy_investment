import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:easy_finance/presentation/viewmodels/auth_viewmodel.dart';
import 'package:easy_finance/data/repositories/auth_repository_impl.dart';
import 'package:easy_finance/data/datasources/secure_storage_service.dart';
import 'package:easy_finance/data/models/auth_token_model.dart';
import 'package:easy_finance/domain/repositories/auth_repository.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockSecureStorageService extends Mock implements SecureStorageService {}

void main() {
  late MockAuthRepository mockAuthRepo;
  late MockSecureStorageService mockStorage;

  setUpAll(() {
    registerFallbackValue(const AuthTokenModel(accessToken: '', tokenType: ''));
  });

  setUp(() {
    mockAuthRepo = MockAuthRepository();
    mockStorage = MockSecureStorageService();
  });

  ProviderContainer buildContainer() {
    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(mockAuthRepo),
        secureStorageServiceProvider.overrideWithValue(mockStorage),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('AuthNotifier', () {
    test('initial state is AuthStatus.initial', () {
      final container = buildContainer();
      final state = container.read(authNotifierProvider);
      expect(state.status, AuthStatus.initial);
      expect(state.error, isNull);
    });

    test('login success transitions loading then success', () async {
      final container = buildContainer();

      when(() => mockAuthRepo.login(any(), any())).thenAnswer(
        (_) async => const AuthTokenModel(
          accessToken: 'token123',
          tokenType: 'bearer',
        ),
      );
      when(() => mockStorage.saveToken(any())).thenAnswer((_) async {});

      final future = container.read(authNotifierProvider.notifier).login('user@test.com', 'pass123');

      expect(container.read(authNotifierProvider).status, AuthStatus.loading);

      await future;

      expect(container.read(authNotifierProvider).status, AuthStatus.success);
      expect(container.read(authNotifierProvider).error, isNull);
    });

    test('login failure with 401 sets error Email ou senha incorretos.', () async {
      final container = buildContainer();

      when(() => mockAuthRepo.login(any(), any()))
          .thenThrow(Exception('401 Unauthorized'));

      await container.read(authNotifierProvider.notifier).login('user@test.com', 'wrongpass');

      final state = container.read(authNotifierProvider);
      expect(state.status, AuthStatus.error);
      expect(state.error, 'Email ou senha incorretos.');
    });

    test('login failure with generic exception sets error Erro inesperado.', () async {
      final container = buildContainer();

      when(() => mockAuthRepo.login(any(), any()))
          .thenThrow(Exception('Internal Server Error'));

      await container.read(authNotifierProvider.notifier).login('user@test.com', 'pass123');

      final state = container.read(authNotifierProvider);
      expect(state.status, AuthStatus.error);
      expect(state.error, 'Erro inesperado. Tente novamente.');
    });

    test('login failure with 422 sets error Dados inválidos.', () async {
      final container = buildContainer();

      when(() => mockAuthRepo.login(any(), any()))
          .thenThrow(Exception('422 Unprocessable Entity'));

      await container.read(authNotifierProvider.notifier).login('user@test.com', 'pass');

      final state = container.read(authNotifierProvider);
      expect(state.status, AuthStatus.error);
      expect(state.error, 'Dados inválidos.');
    });

    test('login failure with 400 sets error Email já cadastrado.', () async {
      final container = buildContainer();

      when(() => mockAuthRepo.login(any(), any()))
          .thenThrow(Exception('400 Bad Request'));

      await container.read(authNotifierProvider.notifier).login('user@test.com', 'pass');

      final state = container.read(authNotifierProvider);
      expect(state.status, AuthStatus.error);
      expect(state.error, 'Email já cadastrado.');
    });

    test('login failure with connect sets error Sem conexão com o servidor.', () async {
      final container = buildContainer();

      when(() => mockAuthRepo.login(any(), any()))
          .thenThrow(Exception('Failed to connect to host'));

      await container.read(authNotifierProvider.notifier).login('user@test.com', 'pass');

      final state = container.read(authNotifierProvider);
      expect(state.status, AuthStatus.error);
      expect(state.error, 'Sem conexão com o servidor.');
    });

    test('logout clears state back to initial', () async {
      final container = buildContainer();

      when(() => mockAuthRepo.login(any(), any())).thenAnswer(
        (_) async => const AuthTokenModel(
          accessToken: 'token123',
          tokenType: 'bearer',
        ),
      );
      when(() => mockStorage.saveToken(any())).thenAnswer((_) async {});
      when(() => mockStorage.clearToken()).thenAnswer((_) async {});

      await container.read(authNotifierProvider.notifier).login('user@test.com', 'pass123');
      expect(container.read(authNotifierProvider).status, AuthStatus.success);

      await container.read(authNotifierProvider.notifier).logout();

      final state = container.read(authNotifierProvider);
      expect(state.status, AuthStatus.initial);
      expect(state.error, isNull);
    });
  });
}
