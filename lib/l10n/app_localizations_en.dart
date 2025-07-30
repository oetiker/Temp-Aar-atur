// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Aare Temperature in Olten';

  @override
  String get currentTab => 'Now';

  @override
  String get historyTab => 'History';

  @override
  String get infoTab => 'Info';

  @override
  String get waterTemperature => 'Aare';

  @override
  String get airTemperature => 'Air';

  @override
  String get loading => 'Loading data...';

  @override
  String get noConnection => 'No Internet Connection';

  @override
  String get checkNetwork => 'Please check your network connection';

  @override
  String get retry => 'Try Again';

  @override
  String get dataLoadError => 'Error loading data';

  @override
  String get tryAgainLater => 'Please try again or wait a moment';

  @override
  String get unexpectedError => 'An unexpected error occurred';

  @override
  String get appWillRestart => 'The app will restart automatically.';

  @override
  String get restartApp => 'Restart App';

  @override
  String get errorDetails => 'Error details:';

  @override
  String lastMeasurementAndBattery(String text) {
    return 'Last measurement and battery voltage: $text';
  }

  @override
  String temperatureUpdate(String waterTemp, String airTemp) {
    return 'Temperature update: Water temperature $waterTemp degrees Celsius, Air temperature $airTemp degrees Celsius';
  }

  @override
  String temperatureChart(String title) {
    return '$title temperature chart: Shows temperature development over time. Touch to zoom and pan.';
  }

  @override
  String get noDataForPeriod =>
      'No data available for the selected time period';

  @override
  String get aboutApp => 'About TemperAare';

  @override
  String get aboutText =>
      'The temperature of the Aare in Olten is naturally not massively different from Solothurn or Aarau, but I\'ve always been bothered by the fact that the federal government doesn\'t operate a [hydrological data station](https://www.hydrodaten.admin.ch/) on the Aare in Olten, only on the Dünnern.\n\nI therefore built my own small temperature measuring station with two temperature sensors and deposited it on the banks of the Aare. One sensor measures the ambient temperature, the other lies about 40 cm below the water surface.\n\nThe measuring device works with a 3000 mAh Li-Ion battery. Thanks to sophisticated programming, it can measure temperatures every few minutes for many weeks and send the results to the server via LoRaWAN. The [app](https://github.com/oetiker/Temp-Aar-atur) gets its data directly from the server and prepares it locally for display.\n\nHave fun swimming in the Aare!\n\n[Tobias Oetiker](mailto:tobi@oetiker.ch?subject=TemperAare)';
}
