// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Ummati';

  @override
  String get prayerTimes => 'Prayer Times';

  @override
  String get qibla => 'Qibla';

  @override
  String get quran => 'Quran';

  @override
  String get settings => 'Settings';

  @override
  String get fajr => 'Fajr';

  @override
  String get sunrise => 'Sunrise';

  @override
  String get dhuhr => 'Dhuhr';

  @override
  String get asr => 'Asr';

  @override
  String get maghrib => 'Maghrib';

  @override
  String get isha => 'Isha';

  @override
  String get nextPrayer => 'Next prayer';

  @override
  String inTime(String time) {
    return 'in $time';
  }

  @override
  String get qiblaDirection => 'Qibla Direction';

  @override
  String get qiblaDescription => 'Point your phone towards the Qibla';

  @override
  String degreesFromNorth(String degrees) {
    return '$degrees° from North';
  }

  @override
  String get surahList => 'Surah List';

  @override
  String verses(int count) {
    return '$count verses';
  }

  @override
  String get meccan => 'Meccan';

  @override
  String get medinan => 'Medinan';

  @override
  String get language => 'Language';

  @override
  String get theme => 'Theme';

  @override
  String get notifications => 'Notifications';

  @override
  String get prayerNotifications => 'Prayer Notifications';

  @override
  String get prayerNotificationsDesc =>
      'Receive a notification before each prayer';

  @override
  String get calculationMethod => 'Calculation Method';

  @override
  String get about => 'About';

  @override
  String version(String version) {
    return 'Version $version';
  }

  @override
  String get locationPermissionRequired => 'Location permission is required';

  @override
  String get enableLocation => 'Enable Location';

  @override
  String get loading => 'Loading...';

  @override
  String get errorLoading => 'Error loading data';

  @override
  String get retry => 'Retry';

  @override
  String get today => 'Today';

  @override
  String get hijriDate => 'Hijri Date';

  @override
  String get bismillah =>
      'In the name of Allah, the Most Gracious, the Most Merciful';

  @override
  String get aboutDesc => 'Free Islamic app with no ads';

  @override
  String get noCompass => 'Compass sensor not available on this device';

  @override
  String get calibrateCompass =>
      'Calibrate by moving your phone in a figure-8 pattern';

  @override
  String get qiblaAligned => 'You are facing the Qibla ✓';

  @override
  String get location => 'Location';

  @override
  String get locationAuto => 'Automatic (GPS)';

  @override
  String get locationManual => 'Manual';

  @override
  String get locationAutoDesc => 'Use device GPS for prayer times';

  @override
  String get locationManualDesc => 'Choose a city manually';

  @override
  String get selectCity => 'Select a city';

  @override
  String currentCity(String city) {
    return 'Current city: $city';
  }

  @override
  String get searchCity => 'Search for a city...';

  @override
  String get noCitySelected => 'No city selected';

  @override
  String get resumeReading => 'Resume reading';

  @override
  String get saveBookmark => 'Save bookmark';

  @override
  String get bookmarkSaved => 'Bookmark saved';

  @override
  String get duas => 'Duas';

  @override
  String get searchDuas => 'Search duas...';

  @override
  String get notifOff => 'Off';

  @override
  String get notifBeep => 'Beep';

  @override
  String get notifAdhanMakkah => 'Adhan Makkah';

  @override
  String get notifAdhanMadinah => 'Adhan Madinah';

  @override
  String get notifAdhanAlaqsa => 'Adhan Al-Aqsa';

  @override
  String get notifAdhanSection => 'Adhan';

  @override
  String get notifyBefore => 'Notify before';

  @override
  String get atPrayerTime => 'At prayer time';

  @override
  String minutesBefore(int minutes) {
    return '$minutes min before';
  }

  @override
  String get monthlySchedule => 'Monthly Schedule';

  @override
  String get dayColumn => 'Date';

  @override
  String monthName(String month) {
    String _temp0 = intl.Intl.selectLogic(
      month,
      {
        'january': 'January',
        'february': 'February',
        'march': 'March',
        'april': 'April',
        'may': 'May',
        'june': 'June',
        'july': 'July',
        'august': 'August',
        'september': 'September',
        'october': 'October',
        'november': 'November',
        'december': 'December',
        'other': '',
      },
    );
    return '$_temp0';
  }

  @override
  String get locationPermissionTitle => 'Location Access';

  @override
  String get locationPermissionDescription =>
      'Ummati needs your location to calculate accurate prayer times and Qibla direction for your area.';

  @override
  String get allowLocation => 'Allow Location Access';

  @override
  String get notificationPermissionTitle => 'Notifications';

  @override
  String get notificationPermissionDescription =>
      'Allow Ummati to send you notifications so you never miss a prayer time.';

  @override
  String get allowNotifications => 'Allow Notifications';

  @override
  String get skipForNow => 'Skip for now';

  @override
  String verseNumber(int number) {
    return 'Verse $number';
  }

  @override
  String get play => 'Play';

  @override
  String get pause => 'Pause';

  @override
  String get stopAudio => 'Stop';

  @override
  String get repeatVerse => 'Repeat';

  @override
  String repeatNTimes(int count) {
    return '$count times';
  }

  @override
  String get noRepeat => 'No repeat';

  @override
  String get loopRange => 'Loop range';

  @override
  String loopFrom(int start, int end) {
    return 'From verse $start to $end';
  }

  @override
  String get clearLoop => 'Clear loop';

  @override
  String get setLoopStart => 'Set as loop start';

  @override
  String get setLoopEnd => 'Set as loop end';

  @override
  String get downloadAudio => 'Download audio';

  @override
  String get downloading => 'Downloading...';

  @override
  String get audioDownloaded => 'Audio downloaded';
}
