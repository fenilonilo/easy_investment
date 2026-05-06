import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../../data/models/asset_model.dart';

class SearchResultsList extends StatelessWidget {
  final List<AssetModel> results;
  final bool searching;
  final Set<String> selectedTickers;
  final void Function(AssetModel) onAdd;

  const SearchResultsList({
    super.key,
    required this.results,
    required this.searching,
    required this.selectedTickers,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    if (searching) {
      return const Column(
        children: [
          ShimmerBox(height: 56, radius: 12),
          SizedBox(height: 6),
          ShimmerBox(height: 56, radius: 12),
          SizedBox(height: 6),
          ShimmerBox(height: 56, radius: 12),
        ],
      );
    }
    if (results.isEmpty) return const SizedBox.shrink();

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: results.length,
      separatorBuilder: (_, __) => const SizedBox(height: 4),
      itemBuilder: (_, i) {
        final asset = results[i];
        final selected = selectedTickers.contains(asset.ticker);
        return ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          tileColor:
              selected ? AppColors.primary.withOpacity(0.08) : null,
          leading: CircleAvatar(
            backgroundColor: AppColors.surfaceDark,
            child: Text(
              asset.ticker.substring(0, 1),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
                fontSize: 14,
              ),
            ),
          ),
          title: Text(asset.ticker,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(
            asset.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                fontSize: 11, color: AppColors.textSecondary),
          ),
          trailing: selected
              ? const Icon(Icons.check_circle_rounded, color: AppColors.gain)
              : IconButton(
                  icon: const Icon(Icons.add_circle_outline_rounded,
                      color: AppColors.primary),
                  onPressed: () => onAdd(asset),
                ),
        );
      },
    );
  }
}
