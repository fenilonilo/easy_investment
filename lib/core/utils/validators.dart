class Validators {
  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'Email obrigatório';
    final re = RegExp(r'^[\w\-.]+@[\w\-]+\.\w{2,}$');
    if (!re.hasMatch(value)) return 'Email inválido';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Senha obrigatória';
    if (value.length < 6) return 'Mínimo 6 caracteres';
    return null;
  }

  static String? required(String? value, [String label = 'Campo']) {
    if (value == null || value.trim().isEmpty) return '$label obrigatório';
    return null;
  }
}
