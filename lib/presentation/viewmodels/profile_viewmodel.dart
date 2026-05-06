import 'dart:async';
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
      );
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  final Ref _ref;
  Timer? _debounce;

  ProfileNotifier(this._ref) : super(const ProfileState()) {
    _init();
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
      state = state.copyWith(loading: false, error: 'Erro ao carregar perfil.');
    }
  }

  void search(String query) {
    _debounce?.cancel();
    if (query.trim().isEmpty) {
      state = state.copyWith(searchResults: [], searching: false);
      return;
    }
    state = state.copyWith(searching: true);
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      try {
        final results = await _ref.read(assetRepositoryProvider).search(query);
        state = state.copyWith(searchResults: results, searching: false);
      } catch (_) {
        state = state.copyWith(searchResults: [], searching: false);
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
    state = state.copyWith(saving: true, error: null, successMessage: null);
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
        originalWatchlist: List.from(state.selectedAssets),
        successMessage: 'Watchlist atualizada!',
      );
    } catch (e) {
      state = state.copyWith(saving: false, error: 'Erro ao salvar.');
    }
  }

  Future<void> updateProfile({
    required String email,
    required String investorProfile,
  }) async {
    final user = state.user;
    if (user == null) return;
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
    } catch (e) {
      state = state.copyWith(saving: false, error: 'Erro ao atualizar perfil.');
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
