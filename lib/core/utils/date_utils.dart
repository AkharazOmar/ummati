/// Hijri date utilities.
///
/// Provides an approximate Gregorian-to-Hijri conversion using the
/// Kuwaiti algorithm. For precise dates, defer to the Aladhan API response.
class HijriDateUtils {
  static const List<String> hijriMonths = [
    'Muharram',
    'Safar',
    'Rabi al-Awwal',
    'Rabi al-Thani',
    'Jumada al-Ula',
    'Jumada al-Thani',
    'Rajab',
    'Shaban',
    'Ramadan',
    'Shawwal',
    'Dhu al-Qadah',
    'Dhu al-Hijjah',
  ];

  static const List<String> hijriMonthsAr = [
    'محرّم',
    'صفر',
    'ربيع الأول',
    'ربيع الثاني',
    'جمادى الأولى',
    'جمادى الآخرة',
    'رجب',
    'شعبان',
    'رمضان',
    'شوّال',
    'ذو القعدة',
    'ذو الحجة',
  ];

  /// Approximate Gregorian-to-Hijri conversion (Kuwaiti algorithm).
  static ({int year, int month, int day}) gregorianToHijri(DateTime date) {
    final julianDay = _gregorianToJulianDay(date.year, date.month, date.day);
    final l = julianDay - 1948440 + 10632;
    final n = ((l - 1) / 10631).floor();
    final remainder = l - 10631 * n + 354;
    final j = (((10985 - remainder) / 5316).floor()) *
            ((((50 * remainder) / 17719).floor())) +
        (((remainder / 5670).floor())) *
            ((((43 * remainder) / 15238).floor()));
    final correctedRemainder =
        remainder - (((30 - j) / 15).floor()) * (((17719 + j * 15238) / 43).floor()) + 29;
    final month = ((24 * correctedRemainder) / 709).floor();
    final day = correctedRemainder - ((709 * month) / 24).floor();
    final year = 30 * n + j - 30;

    return (year: year, month: month, day: day);
  }

  static int _gregorianToJulianDay(int year, int month, int day) {
    final a = ((14 - month) / 12).floor();
    final y = year + 4800 - a;
    final m = month + 12 * a - 3;
    return day +
        ((153 * m + 2) / 5).floor() +
        365 * y +
        (y / 4).floor() -
        (y / 100).floor() +
        (y / 400).floor() -
        32045;
  }

  /// Format a Hijri date as "day monthName year".
  static String formatHijri(DateTime date, {bool arabic = false}) {
    final hijri = gregorianToHijri(date);
    final monthNames = arabic ? hijriMonthsAr : hijriMonths;
    final monthName = monthNames[(hijri.month - 1).clamp(0, 11)];
    return '${hijri.day} $monthName ${hijri.year}';
  }

  /// Format time as HH:mm.
  static String formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Time remaining until a future DateTime, formatted as "Xh Ym".
  static String timeUntil(DateTime target) {
    final now = DateTime.now();
    final diff = target.difference(now);
    if (diff.isNegative) return '--';
    final hours = diff.inHours;
    final minutes = diff.inMinutes % 60;
    if (hours > 0) return '${hours}h ${minutes}m';
    return '${minutes}m';
  }
}
