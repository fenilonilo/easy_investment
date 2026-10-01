import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';

class AppShell extends StatelessWidget {
  final StatefulNavigationShell shell;

  const AppShell({super.key, required this.shell});

  void _onTap(int index) {
    HapticFeedback.lightImpact();
    shell.goBranch(
      index,
      initialLocation: index == shell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: shell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.divider : Colors.grey.shade200,
              width: 0.5,
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: BottomNavigationBar(
            currentIndex: shell.currentIndex,
            onTap: _onTap,
            backgroundColor: Colors.transparent,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.textSecondary,
            selectedFontSize: 11,
            unselectedFontSize: 11,
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home_rounded),
                label: l10n.home,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person_rounded),
                label: l10n.profile,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.smart_toy_outlined),
                activeIcon: Icon(Icons.smart_toy_rounded),
                label: l10n.aiChat,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings_outlined),
                activeIcon: Icon(Icons.settings_rounded),
                label: l10n.configTab,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
