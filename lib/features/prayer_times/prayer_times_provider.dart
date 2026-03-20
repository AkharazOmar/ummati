import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
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

class PrayerTimesNotifier extends AsyncNotifier<DailyPrayerTimes> {
  @override
  Future<DailyPrayerTimes> build() async {
    // Watch calculation method — auto-refresh when it changes
    final method = ref.watch(calculationMethodProvider);
    return _fetchPrayerTimes(method: method);
  }

  Future<DailyPrayerTimes> _fetchPrayerTimes({int method = 2}) async {
    final cacheBox = ref.read(_prayerCacheBoxProvider);
    final today = _todayKey();

    // Try cache first
    final cached = cacheBox.get('prayers_$today');
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

    // Fetch from API
    final locationService = ref.read(locationServiceProvider);
    final apiService = ref.read(prayerApiServiceProvider);

    final position = await locationService.getCurrentPosition();
    final data = await apiService.getPrayerTimes(
      latitude: position.latitude,
      longitude: position.longitude,
      method: method,
    );

    // Cache result
    cacheBox.put('prayers_$today', jsonEncode(data.toCacheJson(method)));

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
      final notifService = NotificationService();
      await notifService.initialize();
      await notifService.cancelAll();

      final prayers = [
        data.fajr,
        data.dhuhr,
        data.asr,
        data.maghrib,
        data.isha,
      ];

      for (var i = 0; i < prayers.length; i++) {
        final prayer = prayers[i];
        if (prayer.time.isAfter(DateTime.now())) {
          await notifService.schedulePrayerNotification(
            id: i,
            prayerName: prayer.name,
            scheduledTime: prayer.time,
          );
        }
      }
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
