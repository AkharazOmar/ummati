// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Ummati';

  @override
  String get prayerTimes => 'Horaires de prière';

  @override
  String get qibla => 'Qibla';

  @override
  String get quran => 'Coran';

  @override
  String get settings => 'Paramètres';

  @override
  String get fajr => 'Fajr';

  @override
  String get sunrise => 'Lever du soleil';

  @override
  String get dhuhr => 'Dhuhr';

  @override
  String get asr => 'Asr';

  @override
  String get maghrib => 'Maghrib';

  @override
  String get isha => 'Isha';

  @override
  String get nextPrayer => 'Prochaine prière';

  @override
  String inTime(String time) {
    return 'dans $time';
  }

  @override
  String get qiblaDirection => 'Direction de la Qibla';

  @override
  String get qiblaDescription => 'Pointez votre téléphone vers la Qibla';

  @override
  String degreesFromNorth(String degrees) {
    return '$degrees° du Nord';
  }

  @override
  String get surahList => 'Liste des sourates';

  @override
  String verses(int count) {
    return '$count versets';
  }

  @override
  String get meccan => 'Mecquoise';

  @override
  String get medinan => 'Médinoise';

  @override
  String get language => 'Langue';

  @override
  String get theme => 'Thème';

  @override
  String get notifications => 'Notifications';

  @override
  String get prayerNotifications => 'Notifications de prière';

  @override
  String get prayerNotificationsDesc =>
      'Recevoir une notification avant chaque prière';

  @override
  String get calculationMethod => 'Méthode de calcul';

  @override
  String get about => 'À propos';

  @override
  String version(String version) {
    return 'Version $version';
  }

  @override
  String get locationPermissionRequired =>
      'La permission de localisation est requise';

  @override
  String get enableLocation => 'Activer la localisation';

  @override
  String get loading => 'Chargement...';

  @override
  String get errorLoading => 'Erreur lors du chargement';

  @override
  String get retry => 'Réessayer';

  @override
  String get today => 'Aujourd\'hui';

  @override
  String get hijriDate => 'Date hégirien';

  @override
  String get bismillah =>
      'Au nom d\'Allah, le Tout Miséricordieux, le Très Miséricordieux';

  @override
  String get aboutDesc => 'Application islamique gratuite et sans publicité';

  @override
  String get noCompass => 'Capteur de boussole non disponible sur cet appareil';

  @override
  String get calibrateCompass =>
      'Calibrez la boussole en faisant un 8 avec votre téléphone';

  @override
  String get qiblaAligned => 'Vous êtes orienté vers la Qibla ✓';

  @override
  String get location => 'Localisation';

  @override
  String get locationAuto => 'Automatique (GPS)';

  @override
  String get locationManual => 'Manuelle';

  @override
  String get locationAutoDesc => 'Utiliser le GPS pour les horaires de prière';

  @override
  String get locationManualDesc => 'Choisir une ville manuellement';

  @override
  String get selectCity => 'Sélectionner une ville';

  @override
  String currentCity(String city) {
    return 'Ville actuelle : $city';
  }

  @override
  String get searchCity => 'Rechercher une ville...';

  @override
  String get noCitySelected => 'Aucune ville sélectionnée';

  @override
  String get resumeReading => 'Reprendre la lecture';

  @override
  String get saveBookmark => 'Sauvegarder le marque-page';

  @override
  String get bookmarkSaved => 'Marque-page sauvegardé';

  @override
  String verseNumber(int number) {
    return 'Verset $number';
  }
}
