// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Aare-Temperatur in Olten';

  @override
  String get currentTab => 'Jetzt';

  @override
  String get historyTab => 'Vergangenheit';

  @override
  String get infoTab => 'Info';

  @override
  String get waterTemperature => 'Aare';

  @override
  String get airTemperature => 'Luft';

  @override
  String get loading => 'Daten werden geladen...';

  @override
  String get noConnection => 'Keine Internetverbindung';

  @override
  String get checkNetwork => 'Bitte überprüfen Sie Ihre Netzwerkverbindung';

  @override
  String get retry => 'Erneut versuchen';

  @override
  String get dataLoadError => 'Fehler beim Laden der Daten';

  @override
  String get tryAgainLater =>
      'Versuchen Sie es erneut oder warten Sie einen Moment';

  @override
  String get unexpectedError => 'Ein unerwarteter Fehler ist aufgetreten';

  @override
  String get appWillRestart => 'Die App wird automatisch neu gestartet.';

  @override
  String get restartApp => 'App neu starten';

  @override
  String get errorDetails => 'Fehlerdetails:';

  @override
  String lastMeasurementAndBattery(String text) {
    return 'Letzte Messung und Batteriespannung: $text';
  }

  @override
  String temperatureUpdate(String waterTemp, String airTemp) {
    return 'Temperaturaktualisierung: Wassertemperatur $waterTemp Grad Celsius, Lufttemperatur $airTemp Grad Celsius';
  }

  @override
  String temperatureChart(String title) {
    return '$title Temperaturverlauf: Zeigt die Temperaturentwicklung über die Zeit an. Berühren Sie zum Zoomen und Verschieben.';
  }

  @override
  String get noDataForPeriod => 'Keine Daten für den gewählten Zeitraum';

  @override
  String get aboutApp => 'Über TemperAare';

  @override
  String get aboutText =>
      'Die Temperatur der Aare in Olten ist natürlich nicht massiv anders als in Solothurn oder Aarau, aber trotzdem habe ich mich immer daran gestört, dass der Bund in Olten keine [Hydrodaten-Messtation](https://www.hydrodaten.admin.ch/) an der Aare betreibt, sondern nur an der Dünnern.\n\nIch habe daher eine eigene kleine Temperaturmessstation mit zwei Temperatursensoren gebaut und sie am Ufer der Aare deponiert. Der eine Sensor misst die Umgebungstemperatur, der andere liegt ca. 40 cm unter der Wasseroberfläche.\n\nDas Messgerät arbeitet mit einer 3000 mAh-Li-Ion-Batterie. Dank ausgeklügelter Programmierung kann es während vieler Wochen alle paar Minuten die Temperaturen messen und die Resultate via LoRaWAN an den Server senden. Die [App](https://github.com/oetiker/Temp-Aar-atur) bezieht ihre Daten direkt vom Server und bereitet sie lokal für die Darstellung auf.\n\nViel Spass beim Aareschwimmen!\n\n[Tobias Oetiker](mailto:tobi@oetiker.ch?subject=TemperAare)';
}
