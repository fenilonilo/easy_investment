import 'package:flutter_test/flutter_test.dart';
import 'package:easy_finance/data/datasources/api_endpoints.dart';

void main() {
  group('ApiEndpoints - constantes estáticas', () {
    test('login está correto', () {
      expect(ApiEndpoints.login, '/auth/login');
    });

    test('register está correto', () {
      expect(ApiEndpoints.register, '/user/register');
    });

    test('assets está correto', () {
      expect(ApiEndpoints.assets, '/assets');
    });

    test('watchlist está correto', () {
      expect(ApiEndpoints.watchlist, '/profile/watchlist');
    });

    test('watchlistAdd está correto', () {
      expect(ApiEndpoints.watchlistAdd, '/profile/watchlist/add');
    });

    test('watchlistRemove está correto', () {
      expect(ApiEndpoints.watchlistRemove, '/profile/watchlist/remove');
    });
  });

  group('ApiEndpoints - métodos com parâmetro id', () {
    test('updateUser constrói path correto', () {
      expect(ApiEndpoints.updateUser('abc123'), '/user/update/abc123');
    });

    test('deleteUser constrói path correto', () {
      expect(ApiEndpoints.deleteUser('abc123'), '/user/delete/abc123');
    });
  });

  group('ApiEndpoints - métodos com parâmetro ticker', () {
    test('assetQuote constrói path correto', () {
      expect(ApiEndpoints.assetQuote('AAPL'), '/assets/AAPL');
    });

    test('assetHistory constrói path correto', () {
      expect(ApiEndpoints.assetHistory('AAPL'), '/assets/AAPL/history');
    });

    test('assetFinancials constrói path correto', () {
      expect(ApiEndpoints.assetFinancials('AAPL'), '/assets/AAPL/financials');
    });

    test('assetDividends constrói path correto', () {
      expect(ApiEndpoints.assetDividends('AAPL'), '/assets/AAPL/dividends');
    });

    test('assetNews constrói path correto', () {
      expect(ApiEndpoints.assetNews('AAPL'), '/assets/AAPL/news');
    });
  });
}
