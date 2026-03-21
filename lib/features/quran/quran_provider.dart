import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../core/models/surah.dart';
import '../../core/services/prayer_api_service.dart';
import '../prayer_times/prayer_times_provider.dart';
import '../settings/settings_provider.dart';

final surahListProvider =
    AsyncNotifierProvider<SurahListNotifier, List<Surah>>(
  SurahListNotifier.new,
);

class SurahListNotifier extends AsyncNotifier<List<Surah>> {
  @override
  Future<List<Surah>> build() async {
    final apiService = ref.read(prayerApiServiceProvider);
    return apiService.getSurahList();
  }
}

/// Parameter combining surah number and locale for cache keying.
class SurahAyahsParam {
  final int surahNumber;
  final String locale;

  const SurahAyahsParam(this.surahNumber, this.locale);

  @override
  bool operator ==(Object other) =>
      other is SurahAyahsParam &&
      other.surahNumber == surahNumber &&
      other.locale == locale;

  @override
  int get hashCode => Object.hash(surahNumber, locale);
}

final surahAyahsProvider =
    FutureProvider.family<List<Ayah>, SurahAyahsParam>((ref, param) async {
  final apiService = ref.read(prayerApiServiceProvider);
  final edition = PrayerApiService.translationEditionForLocale(param.locale);
  return apiService.getSurahAyahs(param.surahNumber, translationEdition: edition);
});

// --- Reading position bookmark ---

class ReadingPosition {
  final int surahNumber;
  final String surahName;
  final int ayahIndex;

  const ReadingPosition({
    required this.surahNumber,
    required this.surahName,
    required this.ayahIndex,
  });
}

final readingPositionProvider =
    StateNotifierProvider<ReadingPositionNotifier, ReadingPosition?>((ref) {
  final box = ref.read(settingsBoxProvider);
  return ReadingPositionNotifier(box);
});

class ReadingPositionNotifier extends StateNotifier<ReadingPosition?> {
  final Box _box;

  ReadingPositionNotifier(this._box) : super(_loadFromBox(_box));

  static ReadingPosition? _loadFromBox(Box box) {
    final surah = box.get('bookmarkSurah') as int?;
    final name = box.get('bookmarkSurahName') as String?;
    final ayah = box.get('bookmarkAyah') as int?;
    if (surah != null && name != null && ayah != null) {
      return ReadingPosition(
        surahNumber: surah,
        surahName: name,
        ayahIndex: ayah,
      );
    }
    return null;
  }

  void save(int surahNumber, String surahName, int ayahIndex) {
    _box.put('bookmarkSurah', surahNumber);
    _box.put('bookmarkSurahName', surahName);
    _box.put('bookmarkAyah', ayahIndex);
    state = ReadingPosition(
      surahNumber: surahNumber,
      surahName: surahName,
      ayahIndex: ayahIndex,
    );
  }

  void clear() {
    _box.delete('bookmarkSurah');
    _box.delete('bookmarkSurahName');
    _box.delete('bookmarkAyah');
    state = null;
  }
}
