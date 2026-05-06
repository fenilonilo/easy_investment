import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../viewmodels/home_viewmodel.dart';
import 'widgets/asset_card_widget.dart';
import 'widgets/historical_chart_card.dart';
import 'widgets/news_ticker.dart';

const _periods = ['1D', '1W', '1M', '1Y', 'ALL'];

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeNotifierProvider);
    final notifier = ref.read(homeNotifierProvider.notifier);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(7),
              ),
              child: const Icon(Icons.trending_up_rounded,
                  color: Colors.black, size: 16),
            ),
            const SizedBox(width: 8),
            const Text('Finance Pro'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              HapticFeedback.lightImpact();
              notifier.load(refresh: true);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => notifier.load(refresh: true),
        child: _buildBody(context, state, notifier, theme),
      ),
    );
  }

  Widget _buildBody(BuildContext context, HomeState state,
      HomeNotifier notifier, ThemeData theme) {
    if (state.loading) return const AssetCardShimmer();

    if (state.error != null) {
      return ErrorView(
        message: state.error!,
        onRetry: () => notifier.load(),
      );
    }

    if (state.quotes.isEmpty) {
      return EmptyState(
        icon: Icons.show_chart_rounded,
        title: 'Sua watchlist está vazia',
        subtitle:
            'Adicione ativos na aba Perfil para começar a monitorar.',
        buttonLabel: 'Adicionar seu primeiro ativo',
        onButtonTap: () {
          HapticFeedback.lightImpact();
          context.go('/profile');
        },
      );
    }

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        // Watchlist header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Text('Watchlist',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const Spacer(),
                if (state.refreshing)
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
          ),
        ),
        // Reorderable asset cards
        SliverToBoxAdapter(
          child: ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            onReorderStart: (_) => HapticFeedback.mediumImpact(),
            onReorder: notifier.reorder,
            itemCount: state.quotes.length,
            itemBuilder: (_, i) {
              final q = state.quotes[i];
              return AssetCardWidget(key: ValueKey(q.ticker), quote: q);
            },
          ),
        ),
        // Charts
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text('Gráficos',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (_, i) {
              final q = state.quotes[i];
              final hist = state.history[q.ticker] ?? [];
              return HistoricalChartCard(
                quote: q,
                history: hist,
                selectedPeriod: state.selectedPeriod,
                periods: _periods,
                onPeriodChanged: notifier.setPeriod,
              );
            },
            childCount: state.quotes.length,
          ),
        ),
        // News ticker
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                child: Text('Notícias',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
              ),
              state.newsLoading && state.news.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: ShimmerBox(height: 110, radius: 16),
                    )
                  : NewsTicker(news: state.news),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }
}
