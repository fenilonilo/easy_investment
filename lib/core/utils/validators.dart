import '../../l10n/app_localizations.dart';

/// Sem [l10n], mantém as mensagens em português.
class Validators {
  static String? email(String? value, [AppLocalizations? l10n]) {
    if (value == null || value.isEmpty) {
      return l10n?.emailRequired ?? 'Email obrigatório';
    }
    final re = RegExp(r'^[\w\-.]+@[\w\-]+\.\w{2,}$');
    if (!re.hasMatch(value)) return l10n?.emailInvalid ?? 'Email inválido';
    return null;
  }

  static String? password(String? value, [AppLocalizations? l10n]) {
    if (value == null || value.isEmpty) {
      return l10n?.passwordRequired ?? 'Senha obrigatória';
    }
    if (value.length < 6) return l10n?.passwordMin ?? 'Mínimo 6 caracteres';
    return null;
  }

  static String? required(String? value,
      [String? label, AppLocalizations? l10n]) {
    if (value == null || value.trim().isEmpty) {
      return l10n != null
          ? l10n.fieldRequired(label ?? l10n.field)
          : '${label ?? 'Campo'} obrigatório';
    }
    return null;
  }
}
