import 'package:intl/intl.dart';

class Formatters {
  static String currency(double value) =>
      NumberFormat.simpleCurrency(locale: 'en_US').format(value);

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

  static String directionLabel(String direction) =>
      direction.toLowerCase() == 'subindo' ? 'up' : 'down';
}
