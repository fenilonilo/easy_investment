import 'package:easy_finance/l10n/app_localizations.dart';
// Regressao T2 (Perfil): B02, B03, B04, B26 (docs/qa/QA-SINTESE.md).
// Escrito a partir do comportamento esperado, sem depender da implementacao dos fixes.
import 'package:dio/dio.dart';
import 'package:easy_finance/data/datasources/dio_client.dart';
import 'package:easy_finance/data/datasources/secure_storage_service.dart';
import 'package:easy_finance/data/datasources/user_storage_service.dart';
import 'package:easy_finance/data/models/asset_model.dart';
import 'package:easy_finance/data/models/auth_token_model.dart';
import 'package:easy_finance/data/repositories/asset_repository_impl.dart';
import 'package:easy_finance/data/repositories/auth_repository_impl.dart';
import 'package:easy_finance/data/repositories/watchlist_repository_impl.dart';
import 'package:easy_finance/domain/repositories/auth_repository.dart';
import 'package:easy_finance/presentation/viewmodels/auth_viewmodel.dart';
import 'package:easy_finance/presentation/viewmodels/profile_viewmodel.dart';
import 'package:easy_finance/presentation/views/profile/profile_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/fake_repositories.dart';
import '../helpers/t2_profile_fakes.dart';

class _MockSecure extends Mock implements SecureStorageService {}

/// Repo de auth: login devolve token; qualquer metodo extra (ex.: getMe/fetchUser
/// que o fix possa criar) devolve o usuario de teste. ASSUNCAO: o fix pode buscar
/// o usuario por metodo novo do repo OU via dio (GET) OU decodificando o JWT.
class _FakeAuthRepo implements AuthRepository {
  @override
  Future<AuthTokenModel> login(String email, String password) async =>
      AuthTokenModel(accessToken: t2Jwt('u-1'), tokenType: 'bearer');

  @override
  dynamic noSuchMethod(Invocation i) => Future.value(t2User);
}

void main() {
  late MockWatchlistRepository wl;
  late MockAssetRepository assets;
  late T2InMemoryUserStorage storage;

  setUpAll(() {
    registerFallbackValue(<AssetModel>[]);
    registerFallbackValue(<String>[]);
  });

  setUp(() {
    wl = MockWatchlistRepository();
    assets = MockAssetRepository();
    storage = T2InMemoryUserStorage();
    when(() => wl.getWatchlist()).thenAnswer((_) async => []);
  });

  ProviderContainer build(T2Adapter adapter,
      {List<Override> extra = const []}) {
    final c = ProviderContainer(overrides: [
      watchlistRepositoryProvider.overrideWithValue(wl),
      assetRepositoryProvider.overrideWithValue(assets),
      userStorageServiceProvider.overrideWithValue(storage),
      dioClientProvider.overrideWithValue(t2Dio(adapter)),
      ...extra,
    ]);
    addTearDown(c.dispose);
    return c;
  }

  Future<ProfileNotifier> ready(ProviderContainer c) async {
    c.read(profileNotifierProvider);
    await Future.delayed(Duration.zero);
    return c.read(profileNotifierProvider.notifier);
  }

  T2Adapter okAdapter() =>
      T2Adapter((o) => o.method == 'GET' ? (200, t2UserJson) : (200, {}));

  group('B02 usuario disponivel apos login', () {
    // Login "como o app faz": AuthRepositoryImpl real + Dio fake + storage em memoria.
    Future<void> login(T2InMemoryUserStorage st, Map<String, dynamic> body,
        {String email = 'teste@example.com'}) async {
      final repo = AuthRepositoryImpl(
          t2Dio(T2Adapter((o) => (200, body))), st);
      await repo.login(email, 'x');
    }

    final token = {'access_token': 'tok', 'token_type': 'bearer'};

    test('B02: login com `user` na resposta grava o usuario para o perfil',
        () async {
      await login(storage, {...token, 'user': t2UserJson});
      final c = build(okAdapter());
      await ready(c);
      final u = c.read(profileNotifierProvider).user;
      expect(u, isNotNull);
      expect(u!.name, 'Usuario Teste');
      expect(u.birthDate, '2001-01-01');
      expect(u.email, 'teste@example.com');
    });

    test('B02: login sem `user` e mesmo e-mail mantem o usuario salvo', () async {
      storage.stored = t2User; // gravado no cadastro
      await login(storage, token);
      expect(storage.stored?.email, 'teste@example.com');
    });

    test('B02: login sem `user` com e-mail diferente limpa o usuario antigo',
        () async {
      storage.stored = t2User;
      await login(storage, token, email: 'outro@example.com');
      expect(storage.stored, isNull);
    });

    test('B02: cadastro grava o usuario', () async {
      final repo = AuthRepositoryImpl(
          t2Dio(T2Adapter((o) => (200, t2UserJson))), storage);
      await repo.register(
          name: 'Usuario Teste',
          email: 'teste@example.com',
          password: 'x',
          birthDate: '2001-01-01',
          investorProfile: 'CONSERVATIVE');
      expect(storage.stored?.name, 'Usuario Teste');
    });

    test('B02: login sem `user` no back deixa perfil com dados do usuario',
        () async {
      await login(storage, token); // storage vazio, back so devolve token
      expect(storage.stored, isNotNull);
    },
        skip: 'depende do BACK: sem GET /me nem user no login (B02)');
  });

  group('B03 salvar perfil', () {
    test('B03: sem usuario carregado nao mostra sucesso e mostra erro claro',
        () async {
      final adapter = okAdapter();
      final c = build(adapter); // storage vazio => user null
      final n = await ready(c);
      expect(c.read(profileNotifierProvider).user, isNull);

      await n.updateProfile(
          email: 'novo@example.com', investorProfile: 'MODERATE');

      final s = c.read(profileNotifierProvider);
      expect(s.successMessage, isNull);
      expect(s.error, isNotNull,
          reason: 'return silencioso nao pode acontecer');
      expect(s.error, isNotEmpty);
      expect(adapter.puts(), isEmpty);
    });

    test(
        'B03: fluxo da tela (updateProfile + saveChanges) sem usuario nunca mostra "Watchlist atualizada!"',
        () async {
      final c = build(okAdapter());
      final n = await ready(c);

      // fluxo do FAB (profile_view.dart): so chama saveChanges se updateProfile ok
      if (await n.updateProfile(
          email: 'novo@example.com', investorProfile: 'MODERATE')) {
        await n.saveChanges();
      }

      final s = c.read(profileNotifierProvider);
      expect(s.successMessage, isNot('Watchlist atualizada!'));
      expect(s.error, isNotNull);
    });

    test('B03: saveChanges sem add/remove nao mostra "Watchlist atualizada!"',
        () async {
      final c = build(okAdapter());
      final n = await ready(c);
      await n.saveChanges();
      expect(c.read(profileNotifierProvider).successMessage, isNull);
    });

    test('B03: com usuario envia PUT /user/update/{id} e so entao mostra sucesso',
        () async {
      storage.stored = t2User;
      final adapter = okAdapter();
      final c = build(adapter);
      final n = await ready(c);
      expect(c.read(profileNotifierProvider).successMessage, isNull);

      await n.updateProfile(
          email: 'novo@example.com', investorProfile: 'MODERATE');

      expect(adapter.puts(), hasLength(1));
      final put = adapter.puts().single;
      expect(put.path, contains('/user/update/u-1'));
      expect(put.data['email'], 'novo@example.com');
      expect(put.data['investor_profile'], 'MODERATE');
      final s = c.read(profileNotifierProvider);
      expect(s.error, isNull);
      expect(s.successMessage, isNotNull);
      expect(s.user!.email, 'novo@example.com');
    });
  });

  group('B04 erros de updateProfile', () {
    Future<String?> errorFor(int status) async {
      storage.stored = t2User;
      final c = build(T2Adapter((o) => (status, {'detail': 'x'})));
      final n = await ready(c);
      await n.updateProfile(
          email: 'novo@example.com', investorProfile: 'MODERATE');
      return c.read(profileNotifierProvider).error;
    }

    test('B04: erro de updateProfile nao e sobrescrito (fluxo do FAB)',
        () async {
      storage.stored = t2User;
      final c = build(T2Adapter((o) => (500, {'detail': 'boom'})));
      final n = await ready(c);

      final ok = await n.updateProfile(
          email: 'novo@example.com', investorProfile: 'MODERATE');
      expect(ok, isFalse);
      final erro = c.read(profileNotifierProvider).error;
      expect(erro, isNotNull);
      if (ok) await n.saveChanges(); // como profile_view.dart

      final s = c.read(profileNotifierProvider);
      expect(s.error, erro);
      expect(s.successMessage, isNull);
    });

    test('B04: saveChanges chamado direto nao apaga erro anterior', () async {
      storage.stored = t2User;
      final c = build(T2Adapter((o) => (500, {'detail': 'boom'})));
      final n = await ready(c);
      await n.updateProfile(
          email: 'novo@example.com', investorProfile: 'MODERATE');
      final erro = c.read(profileNotifierProvider).error;
      await n.saveChanges();
      expect(c.read(profileNotifierProvider).error, erro);
    });

    test('B04: 400 vira mensagem especifica (diferente do generico)', () async {
      final e = await errorFor(400);
      expect(e, isNotNull);
      expect(e, isNot('Erro ao atualizar perfil.'));
      expect(e, isNot('Erro ao salvar.'));
    });

    test('B04: 404 vira mensagem especifica (diferente do generico e do 400)',
        () async {
      final e404 = await errorFor(404);
      final e400 = await errorFor(400);
      expect(e404, isNotNull);
      expect(e404, isNot('Erro ao atualizar perfil.'));
      expect(e404, isNot('Erro ao salvar.'));
      expect(e404, isNot(e400));
    });

    test('B04: saveChanges com 400 do back nao usa "Erro ao salvar." generico',
        () async {
      when(() => wl.addAssets(any())).thenThrow(DioException(
        requestOptions: RequestOptions(path: '/profile/watchlist/add'),
        response: Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 400,
            data: {'detail': 'Todos os ativos ja estao na sua lista.'}),
        type: DioExceptionType.badResponse,
      ));
      final c = build(okAdapter());
      final n = await ready(c);
      n.addAsset(const AssetModel(ticker: 'AAPL', name: 'Apple', iconUrl: ''));
      await n.saveChanges();

      final s = c.read(profileNotifierProvider);
      expect(s.error, isNotNull);
      expect(s.error, isNot('Erro ao salvar.'));
      expect(s.successMessage, isNull);
    });
  });

  group('B26 busca', () {
    testWidgets('B26: busca sem resultado mostra mensagem na tela', (t) async {
      when(() => assets.search(any())).thenAnswer((_) async => []);
      final c = build(okAdapter());
      await t.pumpWidget(UncontrolledProviderScope(
        container: c,
        child: MaterialApp(localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, locale: const Locale('pt'), home: const ProfileView()),
      ));
      await t.pump();
      await t.pump();

      await t.enterText(find.byType(TextField).last, 'zzzzqq');
      await t.pump(const Duration(milliseconds: 500));
      await t.pump();

      expect(
          find.textContaining(RegExp(
              r'nenhum|não encontr|nao encontr|sem resultado',
              caseSensitive: false)),
          findsOneWidget);
    });

    test('B26: erro de busca e exposto (nao engolido)', () async {
      when(() => assets.search(any())).thenThrow(Exception('network'));
      final c = build(okAdapter());
      final n = await ready(c);

      n.search('AAPL');
      await Future.delayed(const Duration(milliseconds: 600));

      final s = c.read(profileNotifierProvider);
      expect(s.searching, false);
      expect(s.searchError, isNotNull);
      expect(s.error, isNull);
    });
  });
}
