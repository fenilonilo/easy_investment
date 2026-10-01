import 'package:intl/intl.dart';

class Formatters {
  /// [code] e a moeda nativa do ativo (ISO 4217); o preco nao e convertido.
  static String currency(double value, [String code = 'USD']) =>
      NumberFormat.simpleCurrency(
        locale: code == 'BRL' ? 'pt_BR' : 'en_US',
        name: code,
      ).format(value);

  static String date(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate);
      return DateFormat('dd/MM/yyyy').format(dt);
    } catch (_) {
      return isoDate;
    }
  }

  static String relativeTime(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate);
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 60) return '${diff.inMinutes}m atrás';
      if (diff.inHours < 24) return '${diff.inHours}h atrás';
      return '${diff.inDays}d atrás';
    } catch (_) {
      return '';
    }
  }

  /// 'up' | 'flat' | 'down'. Desconhecido cai em 'down' (comportamento legado).
  static String directionLabel(String direction) {
    switch (direction.toLowerCase()) {
      case 'subindo':
        return 'up';
      case 'estável':
      case 'estavel':
        return 'flat';
      default:
        return 'down';
    }
  }
}
