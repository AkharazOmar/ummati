import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

const _settingsBoxName = 'settings';

final settingsBoxProvider = Provider<Box>((ref) {
  return Hive.box(_settingsBoxName);
});

/// Opens the Hive settings box. Call once at app startup.
Future<void> initSettingsBox() async {
  await Hive.openBox(_settingsBoxName);
}

// --- Locale ---

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  final box = ref.read(settingsBoxProvider);
  return LocaleNotifier(box);
});

class LocaleNotifier extends StateNotifier<Locale> {
  final Box _box;

  LocaleNotifier(this._box)
      : super(Locale(_box.get('locale', defaultValue: 'fr') as String));

  void setLocale(String languageCode) {
    _box.put('locale', languageCode);
    state = Locale(languageCode);
  }
}

// --- Notifications per prayer ---

/// The five configurable prayers.
const prayerKeys = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

/// A notification sound option.
class NotificationSound {
  final String id;
  final String displayName;
  final String? androidRaw;
  final String? iosFile;
  final String? assetPath;

  const NotificationSound({
    required this.id,
    required this.displayName,
    this.androidRaw,
    this.iosFile,
    this.assetPath,
  });

  bool get isSilent => androidRaw == null;
  bool get isAdhan => id.startsWith('adhan_');
}

/// Fixed sounds (off + beep), always available.
const _fixedSounds = [
  NotificationSound(id: 'none', displayName: 'Off'),
  NotificationSound(
    id: 'beep',
    displayName: 'Beep',
    androidRaw: 'beep',
    iosFile: 'beep.mp3',
    assetPath: 'assets/sounds/beep.mp3',
  ),
];

/// Provider that loads available sounds: fixed + adhans from adhan_list.json.
final availableSoundsProvider = FutureProvider<List<NotificationSound>>((ref) async {
  final adhans = await _loadAdhanList();
  return [..._fixedSounds, ...adhans];
});

Future<List<NotificationSound>> _loadAdhanList() async {
  try {
    final jsonStr = await rootBundle.loadString('assets/data/adhan_list.json');
    final list = jsonDecode(jsonStr) as List;
    return list.map((item) {
      final map = item as Map<String, dynamic>;
      final id = map['id'] as String;
      final name = map['name'] as String;
      final file = map['file'] as String;
      final androidRaw = map['androidRaw'] as String;
      // Format display name: capitalize first letter
      final displayName = '${name[0].toUpperCase()}${name.substring(1)}';
      return NotificationSound(
        id: id,
        displayName: displayName,
        androidRaw: androidRaw,
        iosFile: '$androidRaw.mp3',
        assetPath: 'assets/sounds/adhan/$file',
      );
    }).toList();
  } catch (_) {
    return [];
  }
}

/// Synchronous lookup — searches fixed sounds then falls back to id-based construction.
NotificationSound soundById(String id, [List<NotificationSound>? allSounds]) {
  if (allSounds != null) {
    return allSounds.firstWhere(
      (s) => s.id == id,
      orElse: () => allSounds.length > 2 ? allSounds[2] : _fixedSounds[0],
    );
  }
  // Fallback for notification service (no async)
  final fixed = _fixedSounds.where((s) => s.id == id);
  if (fixed.isNotEmpty) return fixed.first;
  // Construct from id for adhan sounds
  return NotificationSound(
    id: id,
    displayName: id.replaceFirst('adhan_', ''),
    androidRaw: id,
    iosFile: '$id.mp3',
    assetPath: 'assets/sounds/adhan/${id.replaceFirst('adhan_', '')}.mp3',
  );
}

/// State: a map of prayer name → sound id.
typedef PrayerNotificationSettings = Map<String, String>;

final prayerNotificationSettingsProvider = StateNotifierProvider<
    PrayerNotificationSettingsNotifier, PrayerNotificationSettings>((ref) {
  final box = ref.read(settingsBoxProvider);
  return PrayerNotificationSettingsNotifier(box);
});

class PrayerNotificationSettingsNotifier
    extends StateNotifier<PrayerNotificationSettings> {
  final Box _box;

  PrayerNotificationSettingsNotifier(this._box) : super(_loadFromBox(_box));

  static PrayerNotificationSettings _loadFromBox(Box box) {
    final result = <String, String>{};
    for (final key in prayerKeys) {
      result[key] =
          box.get('notif_$key', defaultValue: 'adhan_makkah') as String;
    }
    return result;
  }

  void setSound(String prayer, String soundId) {
    _box.put('notif_$prayer', soundId);
    state = {...state, prayer: soundId};
  }
}

// --- Notification offset (minutes before prayer) ---

/// Available offset options in minutes.
const notificationOffsetOptions = [0, 5, 10, 15, 20, 30];

/// State: a map of prayer name → offset in minutes.
typedef PrayerNotificationOffsets = Map<String, int>;

final prayerNotificationOffsetsProvider = StateNotifierProvider<
    PrayerNotificationOffsetsNotifier, PrayerNotificationOffsets>((ref) {
  final box = ref.read(settingsBoxProvider);
  return PrayerNotificationOffsetsNotifier(box);
});

class PrayerNotificationOffsetsNotifier
    extends StateNotifier<PrayerNotificationOffsets> {
  final Box _box;

  PrayerNotificationOffsetsNotifier(this._box) : super(_loadFromBox(_box));

  static PrayerNotificationOffsets _loadFromBox(Box box) {
    final result = <String, int>{};
    for (final key in prayerKeys) {
      result[key] = box.get('notifOffset_$key', defaultValue: 0) as int;
    }
    return result;
  }

  void setOffset(String prayer, int minutes) {
    _box.put('notifOffset_$prayer', minutes);
    state = {...state, prayer: minutes};
  }
}

// Returns true if any prayer has notifications enabled
final notificationsEnabledProvider = Provider<bool>((ref) {
  final settings = ref.watch(prayerNotificationSettingsProvider);
  return settings.values.any((id) => id != 'none');
});

// --- Location mode ---

final locationModeProvider =
    StateNotifierProvider<LocationModeNotifier, String>((ref) {
  final box = ref.read(settingsBoxProvider);
  return LocationModeNotifier(box);
});

class LocationModeNotifier extends StateNotifier<String> {
  final Box _box;

  LocationModeNotifier(this._box)
      : super(_box.get('locationMode', defaultValue: 'auto') as String);

  void setMode(String mode) {
    _box.put('locationMode', mode);
    state = mode;
  }
}

// --- Manual location ---

class ManualLocation {
  final String cityName;
  final double latitude;
  final double longitude;

  const ManualLocation({
    required this.cityName,
    required this.latitude,
    required this.longitude,
  });
}

final manualLocationProvider =
    StateNotifierProvider<ManualLocationNotifier, ManualLocation?>((ref) {
  final box = ref.read(settingsBoxProvider);
  return ManualLocationNotifier(box);
});

class ManualLocationNotifier extends StateNotifier<ManualLocation?> {
  final Box _box;

  ManualLocationNotifier(this._box) : super(_loadFromBox(_box));

  static ManualLocation? _loadFromBox(Box box) {
    final city = box.get('manualCity') as String?;
    final lat = box.get('manualLat') as double?;
    final lng = box.get('manualLng') as double?;
    if (city != null && lat != null && lng != null) {
      return ManualLocation(cityName: city, latitude: lat, longitude: lng);
    }
    return null;
  }

  void setLocation(String cityName, double latitude, double longitude) {
    _box.put('manualCity', cityName);
    _box.put('manualLat', latitude);
    _box.put('manualLng', longitude);
    state = ManualLocation(
      cityName: cityName,
      latitude: latitude,
      longitude: longitude,
    );
  }

  void clear() {
    _box.delete('manualCity');
    _box.delete('manualLat');
    _box.delete('manualLng');
    state = null;
  }
}

// --- Calculation method ---

final calculationMethodProvider =
    StateNotifierProvider<CalculationMethodNotifier, int>((ref) {
  final box = ref.read(settingsBoxProvider);
  return CalculationMethodNotifier(box);
});

class CalculationMethodNotifier extends StateNotifier<int> {
  final Box _box;

  CalculationMethodNotifier(this._box)
      : super(_box.get('calculationMethod', defaultValue: 3) as int);

  void setMethod(int method) {
    _box.put('calculationMethod', method);
    state = method;
  }
}
