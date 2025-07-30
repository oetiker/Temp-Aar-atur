// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Température de l\'Aar à Olten';

  @override
  String get currentTab => 'Maintenant';

  @override
  String get historyTab => 'Historique';

  @override
  String get infoTab => 'Info';

  @override
  String get waterTemperature => 'Aare';

  @override
  String get airTemperature => 'Air';

  @override
  String get loading => 'Chargement des données...';

  @override
  String get noConnection => 'Aucune connexion Internet';

  @override
  String get checkNetwork => 'Veuillez vérifier votre connexion réseau';

  @override
  String get retry => 'Réessayer';

  @override
  String get dataLoadError => 'Erreur lors du chargement des données';

  @override
  String get tryAgainLater => 'Veuillez réessayer ou attendre un moment';

  @override
  String get unexpectedError => 'Une erreur inattendue s\'est produite';

  @override
  String get appWillRestart => 'L\'application va redémarrer automatiquement.';

  @override
  String get restartApp => 'Redémarrer l\'app';

  @override
  String get errorDetails => 'Détails de l\'erreur:';

  @override
  String lastMeasurementAndBattery(String text) {
    return 'Dernière mesure et tension de la batterie: $text';
  }

  @override
  String temperatureUpdate(String waterTemp, String airTemp) {
    return 'Mise à jour de température: Température de l\'eau $waterTemp degrés Celsius, Température de l\'air $airTemp degrés Celsius';
  }

  @override
  String temperatureChart(String title) {
    return 'Graphique de température $title: Montre l\'évolution de la température dans le temps. Touchez pour zoomer et faire défiler.';
  }

  @override
  String get noDataForPeriod =>
      'Aucune donnée disponible pour la période sélectionnée';

  @override
  String get aboutApp => 'À propos de TemperAare';

  @override
  String get aboutText =>
      'La température de l\'Aar à Olten n\'est naturellement pas massivement différente de celle de Soleure ou d\'Aarau, mais j\'ai toujours été dérangé par le fait que la Confédération n\'exploite pas de [station de données hydrologiques](https://www.hydrodaten.admin.ch/) sur l\'Aar à Olten, mais seulement sur la Dünnern.\n\nJ\'ai donc construit ma propre petite station de mesure de température avec deux capteurs de température et l\'ai déposée sur les rives de l\'Aar. Un capteur mesure la température ambiante, l\'autre se trouve à environ 40 cm sous la surface de l\'eau.\n\nL\'appareil de mesure fonctionne avec une batterie Li-Ion de 3000 mAh. Grâce à une programmation sophistiquée, il peut mesurer les températures toutes les quelques minutes pendant de nombreuses semaines et envoyer les résultats au serveur via LoRaWAN. L\'[application](https://github.com/oetiker/Temp-Aar-atur) obtient ses données directement du serveur et les prépare localement pour l\'affichage.\n\nAmusez-vous bien en nageant dans l\'Aar !\n\n[Tobias Oetiker](mailto:tobi@oetiker.ch?subject=TemperAare)';
}
