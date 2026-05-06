import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/asset_model.dart';

class SelectionChips extends StatelessWidget {
  final List<AssetModel> assets;
  final void Function(String ticker) onRemove;

  const SelectionChips({
    super.key,
    required this.assets,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: assets.map((a) {
        return Chip(
          label: Text(
            a.ticker,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          avatar: CircleAvatar(
            backgroundColor: AppColors.primary.withOpacity(0.2),
            child: Text(
              a.ticker.substring(0, 1),
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          deleteIcon: const Icon(Icons.close_rounded, size: 16),
          onDeleted: () => onRemove(a.ticker),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        );
      }).toList(),
    );
  }
}
