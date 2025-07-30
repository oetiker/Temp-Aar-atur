import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

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
    Locale('de'),
    Locale('en'),
    Locale('fr')
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Aare Temperature in Olten'**
  String get appTitle;

  /// Label for current temperature tab
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get currentTab;

  /// Label for historical chart tab
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyTab;

  /// Label for information tab
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get infoTab;

  /// Label for water temperature display
  ///
  /// In en, this message translates to:
  /// **'Aare'**
  String get waterTemperature;

  /// Label for air temperature display
  ///
  /// In en, this message translates to:
  /// **'Air'**
  String get airTemperature;

  /// Loading indicator text
  ///
  /// In en, this message translates to:
  /// **'Loading data...'**
  String get loading;

  /// Error message when offline
  ///
  /// In en, this message translates to:
  /// **'No Internet Connection'**
  String get noConnection;

  /// Error message instructing user to check network
  ///
  /// In en, this message translates to:
  /// **'Please check your network connection'**
  String get checkNetwork;

  /// Retry button text
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get retry;

  /// Generic error message for data loading failures
  ///
  /// In en, this message translates to:
  /// **'Error loading data'**
  String get dataLoadError;

  /// Error message suggesting user to try again later
  ///
  /// In en, this message translates to:
  /// **'Please try again or wait a moment'**
  String get tryAgainLater;

  /// Generic unexpected error message
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred'**
  String get unexpectedError;

  /// Message shown when app will restart after error
  ///
  /// In en, this message translates to:
  /// **'The app will restart automatically.'**
  String get appWillRestart;

  /// Button text to restart the app
  ///
  /// In en, this message translates to:
  /// **'Restart App'**
  String get restartApp;

  /// Label for error details section
  ///
  /// In en, this message translates to:
  /// **'Error details:'**
  String get errorDetails;

  /// Accessibility label for battery info widget
  ///
  /// In en, this message translates to:
  /// **'Last measurement and battery voltage: {text}'**
  String lastMeasurementAndBattery(String text);

  /// Accessibility announcement for temperature updates
  ///
  /// In en, this message translates to:
  /// **'Temperature update: Water temperature {waterTemp} degrees Celsius, Air temperature {airTemp} degrees Celsius'**
  String temperatureUpdate(String waterTemp, String airTemp);

  /// Accessibility label for temperature charts
  ///
  /// In en, this message translates to:
  /// **'{title} temperature chart: Shows temperature development over time. Touch to zoom and pan.'**
  String temperatureChart(String title);

  /// Message shown when no chart data is available
  ///
  /// In en, this message translates to:
  /// **'No data available for the selected time period'**
  String get noDataForPeriod;

  /// Title for the about section
  ///
  /// In en, this message translates to:
  /// **'About TemperAare'**
  String get aboutApp;

  /// The full about text explaining the app and temperature station
  ///
  /// In en, this message translates to:
  /// **'The temperature of the Aare in Olten is naturally not massively different from Solothurn or Aarau, but I\'ve always been bothered by the fact that the federal government doesn\'t operate a [hydrological data station](https://www.hydrodaten.admin.ch/) on the Aare in Olten, only on the Dünnern.\n\nI therefore built my own small temperature measuring station with two temperature sensors and deposited it on the banks of the Aare. One sensor measures the ambient temperature, the other lies about 40 cm below the water surface.\n\nThe measuring device works with a 3000 mAh Li-Ion battery. Thanks to sophisticated programming, it can measure temperatures every few minutes for many weeks and send the results to the server via LoRaWAN. The [app](https://github.com/oetiker/Temp-Aar-atur) gets its data directly from the server and prepares it locally for display.\n\nHave fun swimming in the Aare!\n\n[Tobias Oetiker](mailto:tobi@oetiker.ch?subject=TemperAare)'**
  String get aboutText;
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
      <String>['de', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
