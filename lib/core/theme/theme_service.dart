import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _themeKey = 'is_dark_theme';

final sharedPreferencesProvider = FutureProvider<SharedPreferences>(
  (_) => SharedPreferences.getInstance(),
);

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider).valueOrNull;
  return ThemeNotifier(prefs);
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  final SharedPreferences? _prefs;

  ThemeNotifier(this._prefs)
      : super(
          (_prefs?.getBool(_themeKey) ?? true)
              ? ThemeMode.dark
              : ThemeMode.light,
        );

  void toggle() {
    final isDark = state == ThemeMode.dark;
    state = isDark ? ThemeMode.light : ThemeMode.dark;
    _prefs?.setBool(_themeKey, !isDark);
  }

  bool get isDark => state == ThemeMode.dark;
}
