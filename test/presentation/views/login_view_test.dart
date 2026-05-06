import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_finance/presentation/views/auth/login_view.dart';
import 'package:easy_finance/presentation/viewmodels/auth_viewmodel.dart';

class FakeAuthNotifier extends StateNotifier<AuthState> implements AuthNotifier {
  FakeAuthNotifier() : super(const AuthState());

  @override
  Future<void> login(String email, String password) async {}

  @override
  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String birthDate,
    required String investorProfile,
  }) async {}

  @override
  Future<void> logout() async {}
}

Widget buildTestApp() {
  final router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (_, __) => const LoginView()),
      GoRoute(path: '/home', builder: (_, __) => const Scaffold(body: Text('Home'))),
      GoRoute(path: '/register', builder: (_, __) => const Scaffold(body: Text('Register'))),
    ],
  );

  return ProviderScope(
    overrides: [
      authNotifierProvider.overrideWith((ref) => FakeAuthNotifier()),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

void main() {
  group('LoginView form validation', () {
    testWidgets('empty fields show email obrigatorio', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      expect(find.text('Email obrigatório'), findsOneWidget);
    });

    testWidgets('invalid email shows email invalido', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, 'invalidemail');
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      expect(find.text('Email inválido'), findsOneWidget);
    });

    testWidgets('valid email but empty password shows senha obrigatoria', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      expect(find.text('Senha obrigatória'), findsOneWidget);
    });

    testWidgets('valid email and short password shows minimo 6 caracteres', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
      await tester.enterText(find.byType(TextFormField).last, '123');
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      expect(find.text('Mínimo 6 caracteres'), findsOneWidget);
    });

    testWidgets('valid email and valid password show no validation errors', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
      await tester.enterText(find.byType(TextFormField).last, 'senha123');
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      expect(find.text('Email obrigatório'), findsNothing);
      expect(find.text('Email inválido'), findsNothing);
      expect(find.text('Senha obrigatória'), findsNothing);
      expect(find.text('Mínimo 6 caracteres'), findsNothing);
    });
  });
}
