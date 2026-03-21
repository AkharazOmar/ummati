import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:hive_flutter/hive_flutter.dart';

import '../../core/models/prayer_time.dart';
import '../../core/services/prayer_api_service.dart';
import '../../core/services/location_service.dart';
import '../../core/services/notification_service.dart';
import '../settings/settings_provider.dart';

final prayerApiServiceProvider = Provider<PrayerApiService>((ref) {
  return PrayerApiService();
});

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

/// Provides the current city name based on location mode.
final cityNameProvider = FutureProvider<String>((ref) async {
  final locationMode = ref.watch(locationModeProvider);
  final manualLocation = ref.watch(manualLocationProvider);

  if (locationMode == 'manual' && manualLocation != null) {
    return manualLocation.cityName;
  }

  try {
    final locationService = ref.read(locationServiceProvider);
    final position = await locationService.getCurrentPosition();
    final placemarks = await geocoding.placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );
    if (placemarks.isNotEmpty) {
      final place = placemarks.first;
      return place.locality ?? place.subAdministrativeArea ?? place.administrativeArea ?? '';
    }
  } catch (_) {
    // Geocoding failed — return empty
  }
  return '';
});

final _prayerCacheBoxProvider = Provider<Box>((ref) {
  return Hive.box('prayer_cache');
});

/// Initialize the prayer cache box. Call once at app startup.
Future<void> initPrayerCacheBox() async {
  await Hive.openBox('prayer_cache');
}

final prayerTimesProvider =
    AsyncNotifierProvider<PrayerTimesNotifier, DailyPrayerTimes>(
  PrayerTimesNotifier.new,
);

/// Parameter for monthly prayer times: year + month.
class MonthlyParam {
  final int year;
  final int month;

  const MonthlyParam(this.year, this.month);

  @override
  bool operator ==(Object other) =>
      other is MonthlyParam && other.year == year && other.month == month;

  @override
  int get hashCode => Object.hash(year, month);
}

final monthlyPrayerTimesProvider = FutureProvider.family<List<DailyPrayerTimes>, MonthlyParam>(
  (ref, param) async {
    final method = ref.watch(calculationMethodProvider);
    final locationMode = ref.watch(locationModeProvider);
    final manualLocation = ref.watch(manualLocationProvider);

    double latitude;
    double longitude;

    if (locationMode == 'manual' && manualLocation != null) {
      latitude = manualLocation.latitude;
      longitude = manualLocation.longitude;
    } else {
      final locationService = ref.read(locationServiceProvider);
      final position = await locationService.getCurrentPosition();
      latitude = position.latitude;
      longitude = position.longitude;
    }

    final apiService = ref.read(prayerApiServiceProvider);
    return apiService.getMonthlyPrayerTimes(
      latitude: latitude,
      longitude: longitude,
      year: param.year,
      month: param.month,
      method: method,
    );
  },
);

class PrayerTimesNotifier extends AsyncNotifier<DailyPrayerTimes> {
  @override
  Future<DailyPrayerTimes> build() async {
    // Watch calculation method and location — auto-refresh when they change
    final method = ref.watch(calculationMethodProvider);
    final locationMode = ref.watch(locationModeProvider);
    final manualLocation = ref.watch(manualLocationProvider);
    return _fetchPrayerTimes(
      method: method,
      locationMode: locationMode,
      manualLocation: manualLocation,
    );
  }

  Future<DailyPrayerTimes> _fetchPrayerTimes({
    int method = 3,
    String locationMode = 'auto',
    ManualLocation? manualLocation,
  }) async {
    final cacheBox = ref.read(_prayerCacheBoxProvider);
    final today = _todayKey();

    // Build a cache key that includes location mode
    final cacheKey = locationMode == 'manual' && manualLocation != null
        ? 'prayers_${today}_manual'
        : 'prayers_${today}_auto';

    // Try cache first
    final cached = cacheBox.get(cacheKey);
    if (cached != null) {
      try {
        final json = jsonDecode(cached as String) as Map<String, dynamic>;
        final cachedMethod = json['method'] as int?;
        if (cachedMethod == method) {
          return DailyPrayerTimes.fromCacheJson(json);
        }
      } catch (_) {
        // Cache corrupt — fetch fresh
      }
    }

    // Determine coordinates
    double latitude;
    double longitude;

    if (locationMode == 'manual' && manualLocation != null) {
      latitude = manualLocation.latitude;
      longitude = manualLocation.longitude;
    } else {
      final locationService = ref.read(locationServiceProvider);
      final position = await locationService.getCurrentPosition();
      latitude = position.latitude;
      longitude = position.longitude;
    }

    // Fetch from API
    final apiService = ref.read(prayerApiServiceProvider);
    final data = await apiService.getPrayerTimes(
      latitude: latitude,
      longitude: longitude,
      method: method,
    );

    // Cache result
    cacheBox.put(cacheKey, jsonEncode(data.toCacheJson(method)));

    // Clean old cache entries
    _cleanOldCache(cacheBox, today);

    // Schedule notifications
    await _scheduleNotifications(data);

    return data;
  }

  Future<void> refresh() async {
    final method = ref.read(calculationMethodProvider);
    // Clear today's cache to force re-fetch
    final cacheBox = ref.read(_prayerCacheBoxProvider);
    cacheBox.delete('prayers_${_todayKey()}');

    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchPrayerTimes(method: method));
  }

  Future<void> _scheduleNotifications(DailyPrayerTimes data) async {
    try {
      final notifSettings = ref.read(prayerNotificationSettingsProvider);
      final notifOffsets = ref.read(prayerNotificationOffsetsProvider);

      final notifService = NotificationService();
      await notifService.initialize();

      await notifService.scheduleAllPrayerNotifications(
        prayerTimes: {
          'Fajr': data.fajr.time,
          'Dhuhr': data.dhuhr.time,
          'Asr': data.asr.time,
          'Maghrib': data.maghrib.time,
          'Isha': data.isha.time,
        },
        settings: notifSettings,
        offsets: notifOffsets,
      );
    } catch (_) {
      // Notifications are best-effort
    }
  }

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  void _cleanOldCache(Box box, String todayKey) {
    final keysToRemove = <String>[];
    for (final key in box.keys) {
      if (key is String && key.startsWith('prayers_') && key != 'prayers_$todayKey') {
        keysToRemove.add(key);
      }
    }
    for (final key in keysToRemove) {
      box.delete(key);
    }
  }
}
