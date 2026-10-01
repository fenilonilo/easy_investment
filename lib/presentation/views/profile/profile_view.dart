import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/profile_viewmodel.dart';
import 'widgets/asset_search_bar.dart';
import 'widgets/search_results_list.dart';
import 'widgets/selection_chips.dart';

class ProfileView extends ConsumerStatefulWidget {
  const ProfileView({super.key});

  @override
  ConsumerState<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends ConsumerState<ProfileView> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _searchCtrl = TextEditingController();
  String _investorProfile = 'CONSERVATIVE';
  bool _obscure = true;
  bool _formDirty = false;
  bool _initialized = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  bool _hasDiff(ProfileState state) {
    if (_formDirty) return true;
    final origTickers =
        state.originalWatchlist.map((a) => a.ticker).toSet();
    final selTickers = state.selectedAssets.map((a) => a.ticker).toSet();
    return origTickers.length != selTickers.length ||
        !origTickers.containsAll(selTickers);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileNotifierProvider);
    final notifier = ref.read(profileNotifierProvider.notifier);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    ref.listen<ProfileState>(profileNotifierProvider, (_, s) {
      if (!_initialized && s.user != null) {
        _emailCtrl.text = s.user!.email;
        _investorProfile = s.user!.investorProfile;
        _initialized = true;
      }
      if (s.successMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(s.successMessage!),
            backgroundColor: AppColors.gain,
          ),
        );
        setState(() => _formDirty = false);
      }
      if (s.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(s.error!)),
        );
      }
    });

    if (state.loading) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.profile)),
        body: const Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              SizedBox(height: 16),
              ShimmerBox(height: 48),
              SizedBox(height: 16),
              ShimmerBox(height: 48),
              SizedBox(height: 16),
              ShimmerBox(height: 48),
              SizedBox(height: 16),
              ShimmerBox(height: 48),
            ],
          ),
        ),
      );
    }

    if (state.loadFailed) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.profile)),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.profileError),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: notifier.reload,
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
      );
    }

    final user = state.user;
    final hasDiff = _hasDiff(state);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profile),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Sair',
            onPressed: () async {
              HapticFeedback.lightImpact();
              await ref.read(authNotifierProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      floatingActionButton: hasDiff
          ? FloatingActionButton.extended(
              onPressed: state.saving
                  ? null
                  : () async {
                      HapticFeedback.mediumImpact();
                      if (_formDirty) {
                        if (!(_formKey.currentState?.validate() ?? false)) {
                          return;
                        }
                        final ok = await notifier.updateProfile(
                          email: _emailCtrl.text.trim(),
                          investorProfile: _investorProfile,
                        );
                        if (!ok) return;
                      }
                      await notifier.saveChanges();
                    },
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.black,
              icon: state.saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.black,
                      ),
                    )
                  : const Icon(Icons.save_rounded),
              label: const Text(
                'Salvar Alterações',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            )
          : null,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.personalInfo,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (user == null) ...[
              Text(
                'Dados do usuário indisponíveis. Saia e entre novamente.',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
            ],
            Form(
              key: _formKey,
              child: Column(
                children: [
                  Opacity(
                    opacity: 0.5,
                    child: TextFormField(
                      initialValue: user?.name ?? '',
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: l10n.name,
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Opacity(
                    opacity: 0.5,
                    child: TextFormField(
                      initialValue: user?.birthDate ?? '',
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: l10n.birthDate,
                        prefixIcon: Icon(Icons.calendar_today_outlined),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => Validators.email(v, l10n),
                    onChanged: (_) => setState(() => _formDirty = true),
                    decoration: InputDecoration(
                      labelText: l10n.email,
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Opacity(
                    opacity: 0.5,
                    child: TextFormField(
                      obscureText: _obscure,
                      initialValue: '••••••••',
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: l10n.password,
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(_obscure
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined),
                          onPressed: () =>
                              setState(() => _obscure = !_obscure),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _investorProfile,
                    decoration: InputDecoration(
                      labelText: l10n.investorProfile,
                      prefixIcon: Icon(Icons.show_chart_rounded),
                    ),
                    items: [
                      DropdownMenuItem(
                          value: 'CONSERVATIVE',
                          child: Text(l10n.conservative)),
                      DropdownMenuItem(
                          value: 'MODERATE', child: Text(l10n.moderate)),
                      DropdownMenuItem(
                          value: 'AGGRESSIVE', child: Text(l10n.aggressive)),
                    ],
                    onChanged: (v) {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _investorProfile = v!;
                        _formDirty = true;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              'Watchlist',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.watchlistHint,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            if (state.selectedAssets.isNotEmpty) ...[
              SelectionChips(
                assets: state.selectedAssets,
                onRemove: (ticker) {
                  HapticFeedback.lightImpact();
                  notifier.removeAsset(ticker);
                },
              ),
              const SizedBox(height: 12),
            ],
            AssetSearchBar(
              controller: _searchCtrl,
              onChanged: notifier.search,
            ),
            const SizedBox(height: 8),
            SearchResultsList(
              results: state.searchResults,
              searching: state.searching,
              searchError: state.searchError,
              hasQuery: _searchCtrl.text.trim().isNotEmpty,
              selectedTickers:
                  state.selectedAssets.map((a) => a.ticker).toSet(),
              onAdd: (asset) {
                HapticFeedback.lightImpact();
                notifier.addAsset(asset);
              },
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
