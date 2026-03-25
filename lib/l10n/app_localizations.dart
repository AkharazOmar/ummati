import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
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
    Locale('ar'),
    Locale('en'),
    Locale('fr')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Ummati'**
  String get appTitle;

  /// No description provided for @prayerTimes.
  ///
  /// In en, this message translates to:
  /// **'Prayer Times'**
  String get prayerTimes;

  /// No description provided for @qibla.
  ///
  /// In en, this message translates to:
  /// **'Qibla'**
  String get qibla;

  /// No description provided for @quran.
  ///
  /// In en, this message translates to:
  /// **'Quran'**
  String get quran;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @fajr.
  ///
  /// In en, this message translates to:
  /// **'Fajr'**
  String get fajr;

  /// No description provided for @sunrise.
  ///
  /// In en, this message translates to:
  /// **'Sunrise'**
  String get sunrise;

  /// No description provided for @dhuhr.
  ///
  /// In en, this message translates to:
  /// **'Dhuhr'**
  String get dhuhr;

  /// No description provided for @asr.
  ///
  /// In en, this message translates to:
  /// **'Asr'**
  String get asr;

  /// No description provided for @maghrib.
  ///
  /// In en, this message translates to:
  /// **'Maghrib'**
  String get maghrib;

  /// No description provided for @isha.
  ///
  /// In en, this message translates to:
  /// **'Isha'**
  String get isha;

  /// No description provided for @nextPrayer.
  ///
  /// In en, this message translates to:
  /// **'Next prayer'**
  String get nextPrayer;

  /// No description provided for @inTime.
  ///
  /// In en, this message translates to:
  /// **'in {time}'**
  String inTime(String time);

  /// No description provided for @qiblaDirection.
  ///
  /// In en, this message translates to:
  /// **'Qibla Direction'**
  String get qiblaDirection;

  /// No description provided for @qiblaDescription.
  ///
  /// In en, this message translates to:
  /// **'Point your phone towards the Qibla'**
  String get qiblaDescription;

  /// No description provided for @degreesFromNorth.
  ///
  /// In en, this message translates to:
  /// **'{degrees}° from North'**
  String degreesFromNorth(String degrees);

  /// No description provided for @surahList.
  ///
  /// In en, this message translates to:
  /// **'Surah List'**
  String get surahList;

  /// No description provided for @verses.
  ///
  /// In en, this message translates to:
  /// **'{count} verses'**
  String verses(int count);

  /// No description provided for @meccan.
  ///
  /// In en, this message translates to:
  /// **'Meccan'**
  String get meccan;

  /// No description provided for @medinan.
  ///
  /// In en, this message translates to:
  /// **'Medinan'**
  String get medinan;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @prayerNotifications.
  ///
  /// In en, this message translates to:
  /// **'Prayer Notifications'**
  String get prayerNotifications;

  /// No description provided for @prayerNotificationsDesc.
  ///
  /// In en, this message translates to:
  /// **'Receive a notification before each prayer'**
  String get prayerNotificationsDesc;

  /// No description provided for @calculationMethod.
  ///
  /// In en, this message translates to:
  /// **'Calculation Method'**
  String get calculationMethod;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String version(String version);

  /// No description provided for @locationPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Location permission is required'**
  String get locationPermissionRequired;

  /// No description provided for @enableLocation.
  ///
  /// In en, this message translates to:
  /// **'Enable Location'**
  String get enableLocation;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @errorLoading.
  ///
  /// In en, this message translates to:
  /// **'Error loading data'**
  String get errorLoading;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @hijriDate.
  ///
  /// In en, this message translates to:
  /// **'Hijri Date'**
  String get hijriDate;

  /// No description provided for @bismillah.
  ///
  /// In en, this message translates to:
  /// **'In the name of Allah, the Most Gracious, the Most Merciful'**
  String get bismillah;

  /// No description provided for @aboutDesc.
  ///
  /// In en, this message translates to:
  /// **'Free Islamic app with no ads'**
  String get aboutDesc;

  /// No description provided for @noCompass.
  ///
  /// In en, this message translates to:
  /// **'Compass sensor not available on this device'**
  String get noCompass;

  /// No description provided for @calibrateCompass.
  ///
  /// In en, this message translates to:
  /// **'Calibrate by moving your phone in a figure-8 pattern'**
  String get calibrateCompass;

  /// No description provided for @qiblaAligned.
  ///
  /// In en, this message translates to:
  /// **'You are facing the Qibla ✓'**
  String get qiblaAligned;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @locationAuto.
  ///
  /// In en, this message translates to:
  /// **'Automatic (GPS)'**
  String get locationAuto;

  /// No description provided for @locationManual.
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get locationManual;

  /// No description provided for @locationAutoDesc.
  ///
  /// In en, this message translates to:
  /// **'Use device GPS for prayer times'**
  String get locationAutoDesc;

  /// No description provided for @locationManualDesc.
  ///
  /// In en, this message translates to:
  /// **'Choose a city manually'**
  String get locationManualDesc;

  /// No description provided for @selectCity.
  ///
  /// In en, this message translates to:
  /// **'Select a city'**
  String get selectCity;

  /// No description provided for @currentCity.
  ///
  /// In en, this message translates to:
  /// **'Current city: {city}'**
  String currentCity(String city);

  /// No description provided for @searchCity.
  ///
  /// In en, this message translates to:
  /// **'Search for a city...'**
  String get searchCity;

  /// No description provided for @noCitySelected.
  ///
  /// In en, this message translates to:
  /// **'No city selected'**
  String get noCitySelected;

  /// No description provided for @resumeReading.
  ///
  /// In en, this message translates to:
  /// **'Resume reading'**
  String get resumeReading;

  /// No description provided for @saveBookmark.
  ///
  /// In en, this message translates to:
  /// **'Save bookmark'**
  String get saveBookmark;

  /// No description provided for @bookmarkSaved.
  ///
  /// In en, this message translates to:
  /// **'Bookmark saved'**
  String get bookmarkSaved;

  /// No description provided for @duas.
  ///
  /// In en, this message translates to:
  /// **'Duas'**
  String get duas;

  /// No description provided for @searchDuas.
  ///
  /// In en, this message translates to:
  /// **'Search duas...'**
  String get searchDuas;

  /// No description provided for @notifOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get notifOff;

  /// No description provided for @notifBeep.
  ///
  /// In en, this message translates to:
  /// **'Beep'**
  String get notifBeep;

  /// No description provided for @notifAdhanMakkah.
  ///
  /// In en, this message translates to:
  /// **'Adhan Makkah'**
  String get notifAdhanMakkah;

  /// No description provided for @notifAdhanMadinah.
  ///
  /// In en, this message translates to:
  /// **'Adhan Madinah'**
  String get notifAdhanMadinah;

  /// No description provided for @notifAdhanAlaqsa.
  ///
  /// In en, this message translates to:
  /// **'Adhan Al-Aqsa'**
  String get notifAdhanAlaqsa;

  /// No description provided for @notifAdhanSection.
  ///
  /// In en, this message translates to:
  /// **'Adhan'**
  String get notifAdhanSection;

  /// No description provided for @notifyBefore.
  ///
  /// In en, this message translates to:
  /// **'Notify before'**
  String get notifyBefore;

  /// No description provided for @atPrayerTime.
  ///
  /// In en, this message translates to:
  /// **'At prayer time'**
  String get atPrayerTime;

  /// No description provided for @minutesBefore.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min before'**
  String minutesBefore(int minutes);

  /// No description provided for @monthlySchedule.
  ///
  /// In en, this message translates to:
  /// **'Monthly Schedule'**
  String get monthlySchedule;

  /// No description provided for @dayColumn.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get dayColumn;

  /// No description provided for @monthName.
  ///
  /// In en, this message translates to:
  /// **'{month, select, january{January} february{February} march{March} april{April} may{May} june{June} july{July} august{August} september{September} october{October} november{November} december{December} other{}}'**
  String monthName(String month);

  /// No description provided for @locationPermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Location Access'**
  String get locationPermissionTitle;

  /// No description provided for @locationPermissionDescription.
  ///
  /// In en, this message translates to:
  /// **'Ummati needs your location to calculate accurate prayer times and Qibla direction for your area.'**
  String get locationPermissionDescription;

  /// No description provided for @allowLocation.
  ///
  /// In en, this message translates to:
  /// **'Allow Location Access'**
  String get allowLocation;

  /// No description provided for @notificationPermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationPermissionTitle;

  /// No description provided for @notificationPermissionDescription.
  ///
  /// In en, this message translates to:
  /// **'Allow Ummati to send you notifications so you never miss a prayer time.'**
  String get notificationPermissionDescription;

  /// No description provided for @allowNotifications.
  ///
  /// In en, this message translates to:
  /// **'Allow Notifications'**
  String get allowNotifications;

  /// No description provided for @skipForNow.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get skipForNow;

  /// No description provided for @verseNumber.
  ///
  /// In en, this message translates to:
  /// **'Verse {number}'**
  String verseNumber(int number);

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @stopAudio.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stopAudio;

  /// No description provided for @repeatVerse.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get repeatVerse;

  /// No description provided for @repeatNTimes.
  ///
  /// In en, this message translates to:
  /// **'{count} times'**
  String repeatNTimes(int count);

  /// No description provided for @noRepeat.
  ///
  /// In en, this message translates to:
  /// **'No repeat'**
  String get noRepeat;

  /// No description provided for @loopRange.
  ///
  /// In en, this message translates to:
  /// **'Loop range'**
  String get loopRange;

  /// No description provided for @loopFrom.
  ///
  /// In en, this message translates to:
  /// **'From verse {start} to {end}'**
  String loopFrom(int start, int end);

  /// No description provided for @clearLoop.
  ///
  /// In en, this message translates to:
  /// **'Clear loop'**
  String get clearLoop;

  /// No description provided for @setLoopStart.
  ///
  /// In en, this message translates to:
  /// **'Set as loop start'**
  String get setLoopStart;

  /// No description provided for @setLoopEnd.
  ///
  /// In en, this message translates to:
  /// **'Set as loop end'**
  String get setLoopEnd;

  /// No description provided for @downloadAudio.
  ///
  /// In en, this message translates to:
  /// **'Download audio'**
  String get downloadAudio;

  /// No description provided for @downloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading...'**
  String get downloading;

  /// No description provided for @audioDownloaded.
  ///
  /// In en, this message translates to:
  /// **'Audio downloaded'**
  String get audioDownloaded;
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
      <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
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
