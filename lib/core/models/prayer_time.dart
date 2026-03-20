class PrayerTime {
  final String name;
  final DateTime time;

  const PrayerTime({
    required this.name,
    required this.time,
  });

  factory PrayerTime.fromJson(String name, String timeStr, DateTime date) {
    final parts = timeStr.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1].split(' ')[0]);
    return PrayerTime(
      name: name,
      time: DateTime(date.year, date.month, date.day, hour, minute),
    );
  }
}

class DailyPrayerTimes {
  final DateTime date;
  final String hijriDate;
  final PrayerTime fajr;
  final PrayerTime sunrise;
  final PrayerTime dhuhr;
  final PrayerTime asr;
  final PrayerTime maghrib;
  final PrayerTime isha;

  const DailyPrayerTimes({
    required this.date,
    required this.hijriDate,
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
  });

  List<PrayerTime> get all => [fajr, sunrise, dhuhr, asr, maghrib, isha];

  PrayerTime? get nextPrayer {
    final now = DateTime.now();
    for (final prayer in all) {
      if (prayer.time.isAfter(now)) {
        return prayer;
      }
    }
    return null;
  }

  factory DailyPrayerTimes.fromAladhanJson(Map<String, dynamic> json) {
    final timings = json['timings'] as Map<String, dynamic>;
    final dateInfo = json['date'] as Map<String, dynamic>;
    final gregorian = dateInfo['gregorian'] as Map<String, dynamic>;
    final hijri = dateInfo['hijri'] as Map<String, dynamic>;

    final dateStr = gregorian['date'] as String;
    final parts = dateStr.split('-');
    final date = DateTime(
      int.parse(parts[2]),
      int.parse(parts[1]),
      int.parse(parts[0]),
    );

    final hijriDay = hijri['day'] as String;
    final hijriMonth = (hijri['month'] as Map<String, dynamic>)['en'] as String;
    final hijriYear = hijri['year'] as String;
    final hijriDateStr = '$hijriDay $hijriMonth $hijriYear';

    return DailyPrayerTimes(
      date: date,
      hijriDate: hijriDateStr,
      fajr: PrayerTime.fromJson('Fajr', timings['Fajr'] as String, date),
      sunrise:
          PrayerTime.fromJson('Sunrise', timings['Sunrise'] as String, date),
      dhuhr: PrayerTime.fromJson('Dhuhr', timings['Dhuhr'] as String, date),
      asr: PrayerTime.fromJson('Asr', timings['Asr'] as String, date),
      maghrib:
          PrayerTime.fromJson('Maghrib', timings['Maghrib'] as String, date),
      isha: PrayerTime.fromJson('Isha', timings['Isha'] as String, date),
    );
  }
}
