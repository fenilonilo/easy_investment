import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/api_endpoints.dart';
import '../../data/datasources/dio_client.dart';
import '../../data/datasources/user_storage_service.dart';
import '../../data/models/asset_model.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/asset_repository_impl.dart';
import '../../data/repositories/watchlist_repository_impl.dart';

class ProfileState {
  final bool loading;
  final bool saving;
  final String? error;
  final String? successMessage;
  final UserModel? user;
  final List<AssetModel> originalWatchlist;
  final List<AssetModel> selectedAssets;
  final List<AssetModel> searchResults;
  final bool searching;
  final String? searchError;
  final bool loadFailed;

  const ProfileState({
    this.loading = true,
    this.saving = false,
    this.error,
    this.successMessage,
    this.user,
    this.originalWatchlist = const [],
    this.selectedAssets = const [],
    this.searchResults = const [],
    this.searching = false,
    this.searchError,
    this.loadFailed = false,
  });

  ProfileState copyWith({
    bool? loading,
    bool? saving,
    String? error,
    String? successMessage,
    UserModel? user,
    List<AssetModel>? originalWatchlist,
    List<AssetModel>? selectedAssets,
    List<AssetModel>? searchResults,
    bool? searching,
    Object? searchError = _keep,
    bool? loadFailed,
  }) =>
      ProfileState(
        loading: loading ?? this.loading,
        saving: saving ?? this.saving,
        error: error,
        successMessage: successMessage,
        user: user ?? this.user,
        originalWatchlist: originalWatchlist ?? this.originalWatchlist,
        selectedAssets: selectedAssets ?? this.selectedAssets,
        searchResults: searchResults ?? this.searchResults,
        searching: searching ?? this.searching,
        searchError: identical(searchError, _keep)
            ? this.searchError
            : searchError as String?,
        loadFailed: loadFailed ?? this.loadFailed,
      );
}

const Object _keep = Object();

// Mensagem do back (400 com detail) ou texto por status.
String _apiError(Object e, String fallback) {
  if (e is DioException) {
    final data = e.response?.data;
    final detail = data is Map ? data['detail'] : null;
    switch (e.response?.statusCode) {
      case 400:
        return detail is String ? detail : 'Dados inválidos.';
      case 404:
        return 'Usuário não encontrado.';
      case 422:
        return 'Dados inválidos.';
    }
    if (e.response == null) return 'Sem conexão com o servidor.';
  }
  return fallback;
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  final Ref _ref;
  Timer? _debounce;

  ProfileNotifier(this._ref) : super(const ProfileState()) {
    _init();
  }

  Future<void> reload() {
    state = state.copyWith(loading: true, loadFailed: false);
    return _init();
  }

  Future<void> _init() async {
    try {
      final userStorage = _ref.read(userStorageServiceProvider);
      final watchlistRepo = _ref.read(watchlistRepositoryProvider);
      final user = await userStorage.readUser();
      final watchlist = await watchlistRepo.getWatchlist();
      state = state.copyWith(
        loading: false,
        user: user,
        originalWatchlist: watchlist,
        selectedAssets: List.from(watchlist),
      );
    } catch (e) {
      state = state.copyWith(
          loading: false, loadFailed: true, error: 'Erro ao carregar perfil.');
    }
  }

  void search(String query) {
    _debounce?.cancel();
    if (query.trim().isEmpty) {
      state = state.copyWith(
          searchResults: [], searching: false, searchError: null);
      return;
    }
    state = state.copyWith(searching: true, searchError: null);
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      try {
        final results = await _ref.read(assetRepositoryProvider).search(query);
        state = state.copyWith(searchResults: results, searching: false);
      } catch (_) {
        state = state.copyWith(
            searchResults: [],
            searching: false,
            searchError: 'Erro ao buscar ativos. Tente novamente.');
      }
    });
  }

  void addAsset(AssetModel asset) {
    if (state.selectedAssets.any((a) => a.ticker == asset.ticker)) return;
    state = state.copyWith(
      selectedAssets: [...state.selectedAssets, asset],
    );
  }

  void removeAsset(String ticker) {
    state = state.copyWith(
      selectedAssets:
          state.selectedAssets.where((a) => a.ticker != ticker).toList(),
    );
  }

  Future<void> saveChanges() async {
    state = state.copyWith(saving: true, error: state.error);
    try {
      final watchlistRepo = _ref.read(watchlistRepositoryProvider);
      final originalTickers =
          state.originalWatchlist.map((a) => a.ticker).toSet();
      final selectedTickers =
          state.selectedAssets.map((a) => a.ticker).toSet();

      final toAdd = state.selectedAssets
          .where((a) => !originalTickers.contains(a.ticker))
          .toList();
      final toRemove = state.originalWatchlist
          .where((a) => !selectedTickers.contains(a.ticker))
          .map((a) => a.ticker)
          .toList();

      if (toAdd.isNotEmpty) await watchlistRepo.addAssets(toAdd);
      if (toRemove.isNotEmpty) await watchlistRepo.removeAssets(toRemove);

      state = state.copyWith(
        saving: false,
        error: state.error,
        originalWatchlist: List.from(state.selectedAssets),
        successMessage: (toAdd.isNotEmpty || toRemove.isNotEmpty)
            ? 'Watchlist atualizada!'
            : null,
      );
    } catch (e) {
      state =
          state.copyWith(saving: false, error: _apiError(e, 'Erro ao salvar.'));
    }
  }

  /// Retorna true so se o PUT foi enviado e salvo.
  Future<bool> updateProfile({
    required String email,
    required String investorProfile,
  }) async {
    final user = state.user;
    if (user == null) {
      state = state.copyWith(
          error: 'Dados do usuário indisponíveis. Saia e entre novamente.');
      return false;
    }
    state = state.copyWith(saving: true, error: null);
    try {
      final dio = _ref.read(dioClientProvider);
      await dio.put(
        ApiEndpoints.updateUser(user.id),
        data: {
          'id': user.id,
          'name': user.name,
          'email': email,
          'investor_profile': investorProfile,
        },
      );
      final updated = UserModel(
        id: user.id,
        name: user.name,
        email: email,
        birthDate: user.birthDate,
        investorProfile: investorProfile,
        isActive: user.isActive,
      );
      await _ref.read(userStorageServiceProvider).saveUser(updated);
      state = state.copyWith(
        saving: false,
        user: updated,
        successMessage: 'Perfil atualizado!',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
          saving: false, error: _apiError(e, 'Erro ao atualizar perfil.'));
      return false;
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}

final profileNotifierProvider =
    StateNotifierProvider<ProfileNotifier, ProfileState>(
        (ref) => ProfileNotifier(ref));
