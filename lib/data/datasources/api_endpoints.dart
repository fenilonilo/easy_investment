class ApiEndpoints {
  static const String login = '/auth/login';
  static const String register = '/user/register';
  static String updateUser(String id) => '/user/update/$id';
  static String deleteUser(String id) => '/user/delete/$id';
  static const String assets = '/assets';
  static String assetQuote(String ticker) => '/assets/$ticker';
  static String assetHistory(String ticker) => '/assets/$ticker/history';
  static String assetFinancials(String ticker) => '/assets/$ticker/financials';
  static String assetDividends(String ticker) => '/assets/$ticker/dividends';
  static String assetNews(String ticker) => '/assets/$ticker/news';
  static const String watchlist = '/profile/watchlist';
  static const String watchlistAdd = '/profile/watchlist/add';
  static const String watchlistRemove = '/profile/watchlist/remove';
}
