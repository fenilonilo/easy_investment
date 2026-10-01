import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pt'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Finance Pro'**
  String get appTitle;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @birthDate.
  ///
  /// In en, this message translates to:
  /// **'Birth Date'**
  String get birthDate;

  /// No description provided for @investorProfile.
  ///
  /// In en, this message translates to:
  /// **'Investor Profile'**
  String get investorProfile;

  /// No description provided for @conservative.
  ///
  /// In en, this message translates to:
  /// **'Conservative'**
  String get conservative;

  /// No description provided for @moderate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get moderate;

  /// No description provided for @aggressive.
  ///
  /// In en, this message translates to:
  /// **'Aggressive'**
  String get aggressive;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @chat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @watchlist.
  ///
  /// In en, this message translates to:
  /// **'Watchlist'**
  String get watchlist;

  /// No description provided for @searchAssets.
  ///
  /// In en, this message translates to:
  /// **'Search assets...'**
  String get searchAssets;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @addFirstAsset.
  ///
  /// In en, this message translates to:
  /// **'Add your first asset'**
  String get addFirstAsset;

  /// No description provided for @noAssetsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Search for assets in the Profile tab and add them to your watchlist.'**
  String get noAssetsSubtitle;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @period1D.
  ///
  /// In en, this message translates to:
  /// **'1D'**
  String get period1D;

  /// No description provided for @period1W.
  ///
  /// In en, this message translates to:
  /// **'1W'**
  String get period1W;

  /// No description provided for @period1M.
  ///
  /// In en, this message translates to:
  /// **'1M'**
  String get period1M;

  /// No description provided for @period1Y.
  ///
  /// In en, this message translates to:
  /// **'1Y'**
  String get period1Y;

  /// No description provided for @periodAll.
  ///
  /// In en, this message translates to:
  /// **'ALL'**
  String get periodAll;

  /// No description provided for @news.
  ///
  /// In en, this message translates to:
  /// **'News'**
  String get news;

  /// No description provided for @dividends.
  ///
  /// In en, this message translates to:
  /// **'Dividends'**
  String get dividends;

  /// No description provided for @financials.
  ///
  /// In en, this message translates to:
  /// **'Financials'**
  String get financials;

  /// No description provided for @typeMessage.
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get typeMessage;

  /// No description provided for @aiAssistant.
  ///
  /// In en, this message translates to:
  /// **'Finance AI'**
  String get aiAssistant;

  /// No description provided for @configTab.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get configTab;

  /// No description provided for @aiChat.
  ///
  /// In en, this message translates to:
  /// **'AI Chat'**
  String get aiChat;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @darkModeOn.
  ///
  /// In en, this message translates to:
  /// **'On (OLED)'**
  String get darkModeOn;

  /// No description provided for @darkModeOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get darkModeOff;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacy;

  /// No description provided for @privacyDesc.
  ///
  /// In en, this message translates to:
  /// **'Your token and profile are stored securely on this device'**
  String get privacyDesc;

  /// No description provided for @languageName.
  ///
  /// In en, this message translates to:
  /// **'English (US)'**
  String get languageName;

  /// No description provided for @logoutAccount.
  ///
  /// In en, this message translates to:
  /// **'Log out of account'**
  String get logoutAccount;

  /// No description provided for @logoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Do you really want to log out?'**
  String get logoutConfirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @emptyWatchlist.
  ///
  /// In en, this message translates to:
  /// **'Your watchlist is empty'**
  String get emptyWatchlist;

  /// No description provided for @quoteError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load quote'**
  String get quoteError;

  /// No description provided for @charts.
  ///
  /// In en, this message translates to:
  /// **'Charts'**
  String get charts;

  /// No description provided for @profileError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load profile.'**
  String get profileError;

  /// No description provided for @searchAssetsHint.
  ///
  /// In en, this message translates to:
  /// **'Search assets (e.g. AAPL, BTC)...'**
  String get searchAssetsHint;

  /// No description provided for @noAssetsFound.
  ///
  /// In en, this message translates to:
  /// **'No assets found.'**
  String get noAssetsFound;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @loginToContinue.
  ///
  /// In en, this message translates to:
  /// **'Log in to continue'**
  String get loginToContinue;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get noAccount;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signUp;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @yourInfo.
  ///
  /// In en, this message translates to:
  /// **'Your information'**
  String get yourInfo;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// No description provided for @selectBirthDate.
  ///
  /// In en, this message translates to:
  /// **'Select your birth date'**
  String get selectBirthDate;

  /// No description provided for @haveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get haveAccount;

  /// No description provided for @assetAdvisor.
  ///
  /// In en, this message translates to:
  /// **'Asset Advisor'**
  String get assetAdvisor;

  /// No description provided for @liveMarketData.
  ///
  /// In en, this message translates to:
  /// **'Live market data'**
  String get liveMarketData;

  /// No description provided for @thinking.
  ///
  /// In en, this message translates to:
  /// **'Thinking…'**
  String get thinking;

  /// No description provided for @previousChats.
  ///
  /// In en, this message translates to:
  /// **'Previous chats'**
  String get previousChats;

  /// No description provided for @newChat.
  ///
  /// In en, this message translates to:
  /// **'New chat'**
  String get newChat;

  /// No description provided for @askAboutAsset.
  ///
  /// In en, this message translates to:
  /// **'Ask about an asset...'**
  String get askAboutAsset;

  /// No description provided for @charLimitReached.
  ///
  /// In en, this message translates to:
  /// **'Limit of {max} characters reached'**
  String charLimitReached(int max);

  /// No description provided for @retryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retryAgain;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleteChat.
  ///
  /// In en, this message translates to:
  /// **'Delete chat'**
  String get deleteChat;

  /// No description provided for @deleteChatTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete chat?'**
  String get deleteChatTitle;

  /// No description provided for @deleteChatBody.
  ///
  /// In en, this message translates to:
  /// **'This chat will be deleted and cannot be recovered.'**
  String get deleteChatBody;

  /// No description provided for @deleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete.'**
  String get deleteFailed;

  /// No description provided for @loadChatsFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load your chats.'**
  String get loadChatsFailed;

  /// No description provided for @noChatsYet.
  ///
  /// In en, this message translates to:
  /// **'No chats here yet.'**
  String get noChatsYet;

  /// No description provided for @exchanges.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} exchange} other{{count} exchanges}}'**
  String exchanges(int count);

  /// No description provided for @splashTagline.
  ///
  /// In en, this message translates to:
  /// **'Your investments, under control.'**
  String get splashTagline;

  /// No description provided for @chartError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load chart'**
  String get chartError;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get noData;

  /// No description provided for @dirUp.
  ///
  /// In en, this message translates to:
  /// **'Up'**
  String get dirUp;

  /// No description provided for @dirFlat.
  ///
  /// In en, this message translates to:
  /// **'Flat'**
  String get dirFlat;

  /// No description provided for @dirDown.
  ///
  /// In en, this message translates to:
  /// **'Down'**
  String get dirDown;

  /// No description provided for @field.
  ///
  /// In en, this message translates to:
  /// **'Field'**
  String get field;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'{label} is required'**
  String fieldRequired(String label);

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// No description provided for @emailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid email'**
  String get emailInvalid;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// No description provided for @passwordMin.
  ///
  /// In en, this message translates to:
  /// **'Minimum 6 characters'**
  String get passwordMin;

  /// No description provided for @chatGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hi! I\'m your Asset Advisor. I can analyze your watchlist, fetch live quotes, dividends and news, and explain indicators. What would you like to know?'**
  String get chatGreeting;

  /// No description provided for @personalInfo.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get personalInfo;

  /// No description provided for @watchlistHint.
  ///
  /// In en, this message translates to:
  /// **'Search and select the assets you want to track.'**
  String get watchlistHint;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
