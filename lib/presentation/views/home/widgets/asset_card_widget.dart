import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../data/models/asset_quote_model.dart';

class AssetCardWidget extends StatelessWidget {
  final AssetQuoteModel quote;
  final VoidCallback? onTap;

  /// Índice na ReorderableListView; quando informado, o handle inicia o drag.
  final int? dragIndex;

  const AssetCardWidget(
      {super.key, required this.quote, this.onTap, this.dragIndex});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dir = Formatters.directionLabel(quote.direction);
    final dirColor = dir == 'up'
        ? AppColors.gain
        : dir == 'flat'
            ? AppColors.textSecondary
            : AppColors.loss;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.divider : Colors.grey.shade200,
            width: 0.5,
          ),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.bgLight,
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.antiAlias,
              child: CachedNetworkImage(
                imageUrl: quote.iconUrl,
                fit: BoxFit.contain,
                placeholder: (_, __) => const Center(
                  child: Icon(Icons.bar_chart, size: 20, color: AppColors.textSecondary),
                ),
                errorWidget: (_, __, ___) => Center(
                  child: Text(
                    quote.ticker.substring(0, 1),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: dirColor,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Ticker + Name
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    quote.ticker,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    quote.name,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Price + Direction
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  Formatters.currency(quote.priceUsd, quote.currency),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      dir == 'up'
                          ? Icons.arrow_upward_rounded
                          : dir == 'flat'
                              ? Icons.remove_rounded
                              : Icons.arrow_downward_rounded,
                      color: dirColor,
                      size: 14,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      dir == 'up' ? l10n.dirUp : dir == 'flat' ? l10n.dirFlat : l10n.dirDown,
                      style: TextStyle(
                        color: dirColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            // Drag handle
            const SizedBox(width: 10),
            if (dragIndex != null)
              ReorderableDragStartListener(
                index: dragIndex!,
                child: Icon(
                  Icons.drag_handle_rounded,
                  color: AppColors.textSecondary.withOpacity(0.4),
                  size: 18,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
