import 'package:flutter_test/flutter_test.dart';
import 'package:easy_finance/core/utils/formatters.dart';

void main() {
  group('Formatters.currency', () {
    test('formata zero corretamente', () {
      expect(Formatters.currency(0), '\$0.00');
    });

    test('formata 1.5 corretamente', () {
      expect(Formatters.currency(1.5), '\$1.50');
    });

    test('formata 1000.99 corretamente', () {
      expect(Formatters.currency(1000.99), '\$1,000.99');
    });
  });

  group('Formatters.date', () {
    test('converte data ISO válida para dd/MM/yyyy', () {
      expect(Formatters.date('2024-01-15'), '15/01/2024');
    });

    test('retorna string original para data inválida', () {
      expect(Formatters.date('data-invalida'), 'data-invalida');
    });
  });

  group('Formatters.relativeTime', () {
    test('retorna string vazia para data inválida', () {
      expect(Formatters.relativeTime('nao-e-uma-data'), '');
    });
  });

  group('Formatters.directionLabel', () {
    test('retorna up para subindo em minúsculo', () {
      expect(Formatters.directionLabel('subindo'), 'up');
    });

    test('retorna up para SUBINDO em maiúsculo', () {
      expect(Formatters.directionLabel('SUBINDO'), 'up');
    });

    test('retorna down para qualquer outro valor', () {
      expect(Formatters.directionLabel('descendo'), 'down');
    });

    test('retorna down para string vazia', () {
      expect(Formatters.directionLabel(''), 'down');
    });

    test('retorna down para valor aleatório', () {
      expect(Formatters.directionLabel('lateral'), 'down');
    });
  });
}
