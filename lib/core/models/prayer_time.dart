class PrayerTime {
  final String name;
  final DateTime time;

  const PrayerTime({
    required this.name,
    required this.time,
  });

  factory PrayerTime.fromJson(String name, String timeStr, DateTime date) {
    // Aladhan returns "HH:mm (TZ)" — strip timezone part
    final cleaned = timeStr.split(' ').first;
    final parts = cleaned.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return PrayerTime(
      name: name,
      time: DateTime(date.year, date.month, date.day, hour, minute),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'time': time.toIso8601String(),
      };

  factory PrayerTime.fromCacheJson(Map<String, dynamic> json) => PrayerTime(
        name: json['name'] as String,
        time: DateTime.parse(json['time'] as String),
      );
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

  /// Returns the next upcoming prayer, or null if all prayers have passed.
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
    final hijriMonth =
        (hijri['month'] as Map<String, dynamic>)['en'] as String;
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

  /// Serialize for Hive cache.
  Map<String, dynamic> toCacheJson(int method) => {
        'method': method,
        'date': date.toIso8601String(),
        'hijriDate': hijriDate,
        'fajr': fajr.toJson(),
        'sunrise': sunrise.toJson(),
        'dhuhr': dhuhr.toJson(),
        'asr': asr.toJson(),
        'maghrib': maghrib.toJson(),
        'isha': isha.toJson(),
      };

  factory DailyPrayerTimes.fromCacheJson(Map<String, dynamic> json) {
    return DailyPrayerTimes(
      date: DateTime.parse(json['date'] as String),
      hijriDate: json['hijriDate'] as String,
      fajr: PrayerTime.fromCacheJson(json['fajr'] as Map<String, dynamic>),
      sunrise:
          PrayerTime.fromCacheJson(json['sunrise'] as Map<String, dynamic>),
      dhuhr: PrayerTime.fromCacheJson(json['dhuhr'] as Map<String, dynamic>),
      asr: PrayerTime.fromCacheJson(json['asr'] as Map<String, dynamic>),
      maghrib:
          PrayerTime.fromCacheJson(json['maghrib'] as Map<String, dynamic>),
      isha: PrayerTime.fromCacheJson(json['isha'] as Map<String, dynamic>),
    );
  }
}
