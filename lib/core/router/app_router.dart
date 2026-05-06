import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/datasources/secure_storage_service.dart';
import '../../presentation/views/splash/splash_view.dart';
import '../../presentation/views/auth/login_view.dart';
import '../../presentation/views/auth/register_view.dart';
import '../../presentation/views/home/home_view.dart';
import '../../presentation/views/profile/profile_view.dart';
import '../../presentation/views/chat/chat_view.dart';
import '../../presentation/views/config/config_view.dart';
import '../../presentation/views/shared/app_shell.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) async {
      final storage = ref.read(secureStorageServiceProvider);
      final hasToken = await storage.hasToken();
      final loc = state.uri.toString();
      final publicRoutes = ['/', '/login', '/register'];
      if (!hasToken && !publicRoutes.contains(loc)) return '/login';
      if (hasToken && (loc == '/login' || loc == '/register')) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (_, __) => const SplashView()),
      GoRoute(path: '/login', builder: (_, __) => const LoginView()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterView()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/home', builder: (_, __) => const HomeView()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/profile', builder: (_, __) => const ProfileView()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/chat', builder: (_, __) => const ChatView()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/config', builder: (_, __) => const ConfigView()),
          ]),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Rota não encontrada: ${state.uri}')),
    ),
  );
});
