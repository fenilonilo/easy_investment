import 'package:flutter/material.dart';

class AssetSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final void Function(String) onChanged;

  const AssetSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Buscar ativos (ex: AAPL, BTC)...',
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear_rounded),
                onPressed: () {
                  controller.clear();
                  onChanged('');
                },
              )
            : null,
      ),
    );
  }
}
