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

    final response = await _dio.get(
      '$_aladhanBaseUrl/timings/$dateStr',
      queryParameters: {
        'latitude': latitude,
        'longitude': longitude,
        'method': method,
      },
    );

    final data = response.data['data'] as Map<String, dynamic>;
    return DailyPrayerTimes.fromAladhanJson(data);
  }

  /// Fetch the list of all 114 surahs.
  Future<List<Surah>> getSurahList() async {
    final response = await _dio.get('$_quranBaseUrl/surah');
    final data = response.data['data'] as List;
    return data
        .map((json) => Surah.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Fetch the ayahs of a specific surah.
  Future<List<Ayah>> getSurahAyahs(int surahNumber) async {
    final response =
        await _dio.get('$_quranBaseUrl/surah/$surahNumber/ar.alafasy');
    final data = response.data['data'] as Map<String, dynamic>;
    final ayahs = data['ayahs'] as List;
    return ayahs
        .map((json) => Ayah.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
