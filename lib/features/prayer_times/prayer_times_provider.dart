import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/prayer_time.dart';
import '../../core/services/prayer_api_service.dart';
import '../../core/services/location_service.dart';

final prayerApiServiceProvider = Provider<PrayerApiService>((ref) {
  return PrayerApiService();
});

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

final prayerTimesProvider =
    AsyncNotifierProvider<PrayerTimesNotifier, DailyPrayerTimes>(
  PrayerTimesNotifier.new,
);

class PrayerTimesNotifier extends AsyncNotifier<DailyPrayerTimes> {
  @override
  Future<DailyPrayerTimes> build() async {
    return _fetchPrayerTimes();
  }

  Future<DailyPrayerTimes> _fetchPrayerTimes() async {
    final locationService = ref.read(locationServiceProvider);
    final apiService = ref.read(prayerApiServiceProvider);

    final position = await locationService.getCurrentPosition();
    return apiService.getPrayerTimes(
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchPrayerTimes);
  }
}
