import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_service.dart';

const _localeKey = 'locale_code';

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider).valueOrNull;
  return LocaleNotifier(prefs);
});

class LocaleNotifier extends StateNotifier<Locale> {
  final SharedPreferences? _prefs;

  LocaleNotifier(this._prefs)
      : super(Locale(_prefs?.getString(_localeKey) ?? 'pt'));

  void setLocale(Locale locale) {
    state = locale;
    _prefs?.setString(_localeKey, locale.languageCode);
  }
}
