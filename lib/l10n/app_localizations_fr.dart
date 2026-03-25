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
  String get duas => 'Invocations';

  @override
  String get searchDuas => 'Rechercher une invocation...';

  @override
  String get notifOff => 'Désactivé';

  @override
  String get notifBeep => 'Bip';

  @override
  String get notifAdhanMakkah => 'Adhan La Mecque';

  @override
  String get notifAdhanMadinah => 'Adhan Médine';

  @override
  String get notifAdhanAlaqsa => 'Adhan Al-Aqsa';

  @override
  String get notifAdhanSection => 'Adhan';

  @override
  String get notifyBefore => 'Notifier avant';

  @override
  String get atPrayerTime => 'À l\'heure de la prière';

  @override
  String minutesBefore(int minutes) {
    return '$minutes min avant';
  }

  @override
  String get monthlySchedule => 'Horaires du mois';

  @override
  String get dayColumn => 'Date';

  @override
  String monthName(String month) {
    String _temp0 = intl.Intl.selectLogic(
      month,
      {
        'january': 'Janvier',
        'february': 'Février',
        'march': 'Mars',
        'april': 'Avril',
        'may': 'Mai',
        'june': 'Juin',
        'july': 'Juillet',
        'august': 'Août',
        'september': 'Septembre',
        'october': 'Octobre',
        'november': 'Novembre',
        'december': 'Décembre',
        'other': '',
      },
    );
    return '$_temp0';
  }

  @override
  String get locationPermissionTitle => 'Accès à la localisation';

  @override
  String get locationPermissionDescription =>
      'Ummati a besoin de votre position pour calculer les horaires de prière et la direction de la Qibla de votre zone.';

  @override
  String get allowLocation => 'Autoriser la localisation';

  @override
  String get notificationPermissionTitle => 'Notifications';

  @override
  String get notificationPermissionDescription =>
      'Autorisez Ummati à vous envoyer des notifications pour ne jamais manquer une prière.';

  @override
  String get allowNotifications => 'Autoriser les notifications';

  @override
  String get skipForNow => 'Passer pour le moment';

  @override
  String verseNumber(int number) {
    return 'Verset $number';
  }

  @override
  String get play => 'Lire';

  @override
  String get pause => 'Pause';

  @override
  String get stopAudio => 'Arrêter';

  @override
  String get repeatVerse => 'Répéter';

  @override
  String repeatNTimes(int count) {
    return '$count fois';
  }

  @override
  String get noRepeat => 'Pas de répétition';

  @override
  String get loopRange => 'Boucle de versets';

  @override
  String loopFrom(int start, int end) {
    return 'Du verset $start au $end';
  }

  @override
  String get clearLoop => 'Supprimer la boucle';

  @override
  String get setLoopStart => 'Début de la boucle';

  @override
  String get setLoopEnd => 'Fin de la boucle';

  @override
  String get downloadAudio => 'Télécharger l\'audio';

  @override
  String get downloading => 'Téléchargement...';

  @override
  String get audioDownloaded => 'Audio téléchargé';
}
