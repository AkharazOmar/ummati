// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'أمّتي';

  @override
  String get prayerTimes => 'مواقيت الصلاة';

  @override
  String get qibla => 'القبلة';

  @override
  String get quran => 'القرآن';

  @override
  String get settings => 'الإعدادات';

  @override
  String get fajr => 'الفجر';

  @override
  String get sunrise => 'الشروق';

  @override
  String get dhuhr => 'الظهر';

  @override
  String get asr => 'العصر';

  @override
  String get maghrib => 'المغرب';

  @override
  String get isha => 'العشاء';

  @override
  String get nextPrayer => 'الصلاة القادمة';

  @override
  String inTime(String time) {
    return 'بعد $time';
  }

  @override
  String get qiblaDirection => 'اتجاه القبلة';

  @override
  String get qiblaDescription => 'وجّه هاتفك نحو القبلة';

  @override
  String degreesFromNorth(String degrees) {
    return '$degrees° من الشمال';
  }

  @override
  String get surahList => 'قائمة السور';

  @override
  String verses(int count) {
    return '$count آيات';
  }

  @override
  String get meccan => 'مكّيّة';

  @override
  String get medinan => 'مدنيّة';

  @override
  String get language => 'اللغة';

  @override
  String get theme => 'المظهر';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get prayerNotifications => 'إشعارات الصلاة';

  @override
  String get prayerNotificationsDesc => 'تلقّي إشعار قبل كل صلاة';

  @override
  String get calculationMethod => 'طريقة الحساب';

  @override
  String get about => 'حول التطبيق';

  @override
  String version(String version) {
    return 'الإصدار $version';
  }

  @override
  String get locationPermissionRequired => 'إذن الموقع مطلوب';

  @override
  String get enableLocation => 'تفعيل الموقع';

  @override
  String get loading => 'جاري التحميل...';

  @override
  String get errorLoading => 'خطأ في تحميل البيانات';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get today => 'اليوم';

  @override
  String get hijriDate => 'التاريخ الهجري';

  @override
  String get bismillah => 'بسم الله الرحمن الرحيم';

  @override
  String get aboutDesc => 'تطبيق إسلامي مجاني بدون إعلانات';

  @override
  String get noCompass => 'مستشعر البوصلة غير متوفر على هذا الجهاز';

  @override
  String get calibrateCompass =>
      'قم بمعايرة البوصلة بتحريك هاتفك على شكل رقم ٨';

  @override
  String get qiblaAligned => 'أنت متجه نحو القبلة ✓';

  @override
  String get location => 'الموقع';

  @override
  String get locationAuto => 'تلقائي (GPS)';

  @override
  String get locationManual => 'يدوي';

  @override
  String get locationAutoDesc => 'استخدام GPS للحصول على مواقيت الصلاة';

  @override
  String get locationManualDesc => 'اختيار مدينة يدوياً';

  @override
  String get selectCity => 'اختر مدينة';

  @override
  String currentCity(String city) {
    return 'المدينة الحالية: $city';
  }

  @override
  String get searchCity => 'ابحث عن مدينة...';

  @override
  String get noCitySelected => 'لم يتم اختيار مدينة';

  @override
  String get resumeReading => 'متابعة القراءة';

  @override
  String get saveBookmark => 'حفظ العلامة';

  @override
  String get bookmarkSaved => 'تم حفظ العلامة';

  @override
  String get notifOff => 'إيقاف';

  @override
  String get notifBeep => 'تنبيه';

  @override
  String get notifAdhanMakkah => 'أذان مكة';

  @override
  String get notifAdhanMadinah => 'أذان المدينة';

  @override
  String get notifAdhanAlaqsa => 'أذان الأقصى';

  @override
  String get notifAdhanSection => 'الأذان';

  @override
  String get notifyBefore => 'التنبيه قبل';

  @override
  String get atPrayerTime => 'عند وقت الصلاة';

  @override
  String minutesBefore(int minutes) {
    return 'قبل $minutes دقيقة';
  }

  @override
  String get monthlySchedule => 'جدول الشهر';

  @override
  String get dayColumn => 'التاريخ';

  @override
  String monthName(String month) {
    String _temp0 = intl.Intl.selectLogic(
      month,
      {
        'january': 'يناير',
        'february': 'فبراير',
        'march': 'مارس',
        'april': 'أبريل',
        'may': 'مايو',
        'june': 'يونيو',
        'july': 'يوليو',
        'august': 'أغسطس',
        'september': 'سبتمبر',
        'october': 'أكتوبر',
        'november': 'نوفمبر',
        'december': 'ديسمبر',
        'other': '',
      },
    );
    return '$_temp0';
  }

  @override
  String get locationPermissionTitle => 'الوصول إلى الموقع';

  @override
  String get locationPermissionDescription =>
      'يحتاج أمّتي إلى موقعك لحساب مواقيت الصلاة واتجاه القبلة بدقة في منطقتك.';

  @override
  String get allowLocation => 'السماح بالوصول إلى الموقع';

  @override
  String get notificationPermissionTitle => 'الإشعارات';

  @override
  String get notificationPermissionDescription =>
      'اسمح لأمّتي بإرسال إشعارات حتى لا تفوتك أي صلاة.';

  @override
  String get allowNotifications => 'السماح بالإشعارات';

  @override
  String get skipForNow => 'تخطي الآن';

  @override
  String verseNumber(int number) {
    return 'الآية $number';
  }
}
