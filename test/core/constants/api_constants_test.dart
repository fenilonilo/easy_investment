import 'package:flutter_test/flutter_test.dart';
import 'package:easy_finance/core/constants/api_constants.dart';

void main() {
  group('ApiConstants', () {
    test('baseUrl tem valor padrão correto', () {
      expect(ApiConstants.baseUrl, 'http://localhost:8000');
    });
  });

  group('PeriodMap.uiToApi', () {
    test('mapeia 1D para 1d', () {
      expect(PeriodMap.uiToApi['1D'], '1d');
    });

    test('mapeia 1W para 5d', () {
      expect(PeriodMap.uiToApi['1W'], '5d');
    });

    test('mapeia 1M para 1mo', () {
      expect(PeriodMap.uiToApi['1M'], '1mo');
    });

    test('mapeia 1Y para 1y', () {
      expect(PeriodMap.uiToApi['1Y'], '1y');
    });

    test('mapeia ALL para max', () {
      expect(PeriodMap.uiToApi['ALL'], 'max');
    });
  });
}
