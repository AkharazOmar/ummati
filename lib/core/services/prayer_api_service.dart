import 'package:dio/dio.dart';

import '../models/prayer_time.dart';
import '../models/surah.dart';

class PrayerApiService {
  final Dio _dio;

  static const String _aladhanBaseUrl = 'https://api.aladhan.com/v1';
  static const String _quranBaseUrl = 'https://api.alquran.cloud/v1';

  PrayerApiService({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
            ));

  /// Custom method ID used by Aladhan for user-defined parameters.
  static const int customMethodId = 99;

  /// Moroccan method: Fajr 19°, Isha 17° (Ministère des Habous).
  static const String moroccanMethodSettings = '19,null,17';

  /// Fetch prayer times for a given location and date.
  ///
  /// [method] is the calculation method ID (default 2 = ISNA).
  Future<DailyPrayerTimes> getPrayerTimes({
    required double latitude,
    required double longitude,
    DateTime? date,
    int method = 2,
  }) async {
    final d = date ?? DateTime.now();
    final dateStr =
        '${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}';

    final params = <String, dynamic>{
      'latitude': latitude,
      'longitude': longitude,
      'method': method,
    };
    if (method == customMethodId) {
      params['methodSettings'] = moroccanMethodSettings;
    }

    final response = await _dio.get(
      '$_aladhanBaseUrl/timings/$dateStr',
      queryParameters: params,
    );

    final data = response.data['data'] as Map<String, dynamic>;
    return DailyPrayerTimes.fromAladhanJson(data);
  }

  /// Fetch prayer times for an entire month.
  Future<List<DailyPrayerTimes>> getMonthlyPrayerTimes({
    required double latitude,
    required double longitude,
    required int year,
    required int month,
    int method = 2,
  }) async {
    final params = <String, dynamic>{
      'latitude': latitude,
      'longitude': longitude,
      'method': method,
    };
    if (method == customMethodId) {
      params['methodSettings'] = moroccanMethodSettings;
    }

    final response = await _dio.get(
      '$_aladhanBaseUrl/calendar/$year/$month',
      queryParameters: params,
    );

    final days = response.data['data'] as List;
    return days
        .map((json) =>
            DailyPrayerTimes.fromAladhanJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Fetch the list of all 114 surahs.
  Future<List<Surah>> getSurahList() async {
    final response = await _dio.get('$_quranBaseUrl/surah');
    final data = response.data['data'] as List;
    return data
        .map((json) => Surah.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Fetch the ayahs of a specific surah with transliteration and translation.
  Future<List<Ayah>> getSurahAyahs(int surahNumber, {String? translationEdition}) async {
    final futures = <Future>[
      _dio.get('$_quranBaseUrl/surah/$surahNumber/ar.alafasy'),
      _dio.get('$_quranBaseUrl/surah/$surahNumber/en.transliteration'),
      if (translationEdition != null)
        _dio.get('$_quranBaseUrl/surah/$surahNumber/$translationEdition'),
    ];

    final responses = await Future.wait(futures);

    final arabicData = responses[0].data['data'] as Map<String, dynamic>;
    final arabicAyahs = arabicData['ayahs'] as List;

    final ayahs = arabicAyahs
        .map((json) => Ayah.fromJson(json as Map<String, dynamic>))
        .toList();

    // Add phonetic transliteration
    final phoneticData = responses[1].data['data'] as Map<String, dynamic>;
    final phoneticAyahs = phoneticData['ayahs'] as List;
    for (var i = 0; i < ayahs.length && i < phoneticAyahs.length; i++) {
      final phoneticText = (phoneticAyahs[i] as Map<String, dynamic>)['text'] as String;
      ayahs[i] = ayahs[i].withPhonetic(phoneticText);
    }

    // Add translation
    final translationIndex = translationEdition != null ? 2 : -1;
    if (translationIndex >= 0 && translationIndex < responses.length) {
      final translationData = responses[translationIndex].data['data'] as Map<String, dynamic>;
      final translationAyahs = translationData['ayahs'] as List;
      for (var i = 0; i < ayahs.length && i < translationAyahs.length; i++) {
        final translationText = (translationAyahs[i] as Map<String, dynamic>)['text'] as String;
        ayahs[i] = ayahs[i].withTranslation(translationText);
      }
    }

    return ayahs;
  }

  /// Map locale code to alquran.cloud translation edition.
  static String? translationEditionForLocale(String locale) {
    const editions = {
      'fr': 'fr.hamidullah',
      'en': 'en.asad',
      'ar': null, // No translation needed for Arabic
    };
    return editions[locale];
  }
}
