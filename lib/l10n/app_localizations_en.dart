// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Finance Pro';

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get name => 'Name';

  @override
  String get birthDate => 'Birth Date';

  @override
  String get investorProfile => 'Investor Profile';

  @override
  String get conservative => 'Conservative';

  @override
  String get moderate => 'Moderate';

  @override
  String get aggressive => 'Aggressive';

  @override
  String get home => 'Home';

  @override
  String get profile => 'Profile';

  @override
  String get chat => 'Chat';

  @override
  String get settings => 'Settings';

  @override
  String get watchlist => 'Watchlist';

  @override
  String get searchAssets => 'Search assets...';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get logout => 'Logout';

  @override
  String get theme => 'Theme';

  @override
  String get language => 'Language';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get addFirstAsset => 'Add your first asset';

  @override
  String get noAssetsSubtitle =>
      'Search for assets in the Profile tab and add them to your watchlist.';

  @override
  String get loading => 'Loading...';

  @override
  String get retry => 'Retry';

  @override
  String get error => 'Error';

  @override
  String get period1D => '1D';

  @override
  String get period1W => '1W';

  @override
  String get period1M => '1M';

  @override
  String get period1Y => '1Y';

  @override
  String get periodAll => 'ALL';

  @override
  String get news => 'News';

  @override
  String get dividends => 'Dividends';

  @override
  String get financials => 'Financials';

  @override
  String get typeMessage => 'Type a message...';

  @override
  String get aiAssistant => 'Finance AI';

  @override
  String get configTab => 'Settings';

  @override
  String get aiChat => 'AI Chat';

  @override
  String get appearance => 'Appearance';

  @override
  String get darkModeOn => 'On (OLED)';

  @override
  String get darkModeOff => 'Off';

  @override
  String get about => 'About';

  @override
  String get version => 'Version';

  @override
  String get privacy => 'Privacy';

  @override
  String get privacyDesc =>
      'Your token and profile are stored securely on this device';

  @override
  String get languageName => 'English (US)';

  @override
  String get logoutAccount => 'Log out of account';

  @override
  String get logoutConfirm => 'Do you really want to log out?';

  @override
  String get cancel => 'Cancel';

  @override
  String get emptyWatchlist => 'Your watchlist is empty';

  @override
  String get quoteError => 'Failed to load quote';

  @override
  String get charts => 'Charts';

  @override
  String get profileError => 'Failed to load profile.';

  @override
  String get searchAssetsHint => 'Search assets (e.g. AAPL, BTC)...';

  @override
  String get noAssetsFound => 'No assets found.';

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get loginToContinue => 'Log in to continue';

  @override
  String get noAccount => 'Don\'t have an account? ';

  @override
  String get signUp => 'Sign up';

  @override
  String get createAccount => 'Create Account';

  @override
  String get yourInfo => 'Your information';

  @override
  String get fullName => 'Full name';

  @override
  String get selectBirthDate => 'Select your birth date';

  @override
  String get haveAccount => 'Already have an account? ';

  @override
  String get assetAdvisor => 'Asset Advisor';

  @override
  String get liveMarketData => 'Live market data';

  @override
  String get thinking => 'Thinking…';

  @override
  String get previousChats => 'Previous chats';

  @override
  String get newChat => 'New chat';

  @override
  String get askAboutAsset => 'Ask about an asset...';

  @override
  String charLimitReached(int max) {
    return 'Limit of $max characters reached';
  }

  @override
  String get retryAgain => 'Try again';

  @override
  String get delete => 'Delete';

  @override
  String get deleteChat => 'Delete chat';

  @override
  String get deleteChatTitle => 'Delete chat?';

  @override
  String get deleteChatBody =>
      'This chat will be deleted and cannot be recovered.';

  @override
  String get deleteFailed => 'Failed to delete.';

  @override
  String get loadChatsFailed => 'Could not load your chats.';

  @override
  String get noChatsYet => 'No chats here yet.';

  @override
  String exchanges(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count exchanges',
      one: '$count exchange',
    );
    return '$_temp0';
  }

  @override
  String get splashTagline => 'Your investments, under control.';

  @override
  String get chartError => 'Failed to load chart';

  @override
  String get noData => 'No data';

  @override
  String get dirUp => 'Up';

  @override
  String get dirFlat => 'Flat';

  @override
  String get dirDown => 'Down';

  @override
  String get field => 'Field';

  @override
  String fieldRequired(String label) {
    return '$label is required';
  }

  @override
  String get emailRequired => 'Email is required';

  @override
  String get emailInvalid => 'Invalid email';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get passwordMin => 'Minimum 6 characters';

  @override
  String get chatGreeting =>
      'Hi! I\'m your Asset Advisor. I can analyze your watchlist, fetch live quotes, dividends and news, and explain indicators. What would you like to know?';

  @override
  String get personalInfo => 'Information';

  @override
  String get watchlistHint => 'Search and select the assets you want to track.';
}
