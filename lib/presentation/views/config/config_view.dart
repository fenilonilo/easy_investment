import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/locale_service.dart';
import '../../../core/theme/theme_service.dart';
import '../../viewmodels/auth_viewmodel.dart';

class ConfigView extends ConsumerWidget {
  const ConfigView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;
    final locale = ref.watch(localeProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Aparência ──────────────────────────────────────────────
          _SectionHeader(label: l10n.appearance),
          _SettingsTile(
            icon: Icons.dark_mode_rounded,
            iconColor: const Color(0xFF9C88FF),
            title: l10n.darkMode,
            subtitle: isDark ? l10n.darkModeOn : l10n.darkModeOff,
            trailing: Switch.adaptive(
              value: isDark,
              activeColor: AppColors.primary,
              onChanged: (_) {
                HapticFeedback.lightImpact();
                ref.read(themeProvider.notifier).toggle();
              },
            ),
          ),
          const SizedBox(height: 8),

          // ── Idioma ─────────────────────────────────────────────────
          _SectionHeader(label: l10n.language),
          _SettingsTile(
            icon: Icons.language_rounded,
            iconColor: const Color(0xFF4FC3F7),
            title: l10n.language,
            subtitle: l10n.languageName,
            trailing: DropdownButton<String>(
              value: locale.languageCode,
              underline: const SizedBox.shrink(),
              borderRadius: BorderRadius.circular(12),
              items: const [
                DropdownMenuItem(value: 'pt', child: Text('PT-BR')),
                DropdownMenuItem(value: 'en', child: Text('EN-US')),
              ],
              onChanged: (code) {
                if (code == null) return;
                HapticFeedback.selectionClick();
                ref.read(localeProvider.notifier).setLocale(Locale(code));
              },
            ),
          ),
          const SizedBox(height: 8),

          // ── Sobre ──────────────────────────────────────────────────
          _SectionHeader(label: l10n.about),
          _SettingsTile(
            icon: Icons.info_outline_rounded,
            iconColor: AppColors.textSecondary,
            title: l10n.version,
            subtitle: '1.0.0',
          ),
          _SettingsTile(
            icon: Icons.shield_outlined,
            iconColor: AppColors.textSecondary,
            title: l10n.privacy,
            subtitle: l10n.privacyDesc,
          ),
          const SizedBox(height: 24),

          // ── Logout ─────────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.loss,
                side: const BorderSide(color: AppColors.loss),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.logout_rounded),
              label: Text(
                l10n.logoutAccount,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: () async {
                HapticFeedback.mediumImpact();
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text(l10n.logout),
                    content: Text(l10n.logoutConfirm),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: Text(l10n.cancel),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        style: TextButton.styleFrom(
                            foregroundColor: AppColors.loss),
                        child: Text(l10n.logout),
                      ),
                    ],
                  ),
                );
                if (confirmed == true && context.mounted) {
                  await ref.read(authNotifierProvider.notifier).logout();
                  if (context.mounted) context.go('/login');
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 8),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget? trailing;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.divider : Colors.grey.shade200,
          width: 0.5,
        ),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Text(subtitle,
            style: const TextStyle(
                fontSize: 12, color: AppColors.textSecondary)),
        trailing: trailing,
      ),
    );
  }
}
