class ApiConstants {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE',
    defaultValue: 'http://localhost:8000',
  );
}

class PeriodMap {
  static const Map<String, String> uiToApi = {
    '1D': '1d',
    '1W': '5d',
    '1M': '1mo',
    '1Y': '1y',
    'ALL': 'max',
  };
}
