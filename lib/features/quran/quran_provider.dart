import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/surah.dart';
import '../../core/services/prayer_api_service.dart';
import '../prayer_times/prayer_times_provider.dart';

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

final surahAyahsProvider =
    FutureProvider.family<List<Ayah>, int>((ref, surahNumber) async {
  final apiService = ref.read(prayerApiServiceProvider);
  return apiService.getSurahAyahs(surahNumber);
});
