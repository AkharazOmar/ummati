import 'package:flutter/material.dart';
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

// --- Notifications toggle ---

final notificationsEnabledProvider =
    StateNotifierProvider<NotificationsNotifier, bool>((ref) {
  final box = ref.read(settingsBoxProvider);
  return NotificationsNotifier(box);
});

class NotificationsNotifier extends StateNotifier<bool> {
  final Box _box;

  NotificationsNotifier(this._box)
      : super(_box.get('notifications', defaultValue: true) as bool);

  void toggle() {
    state = !state;
    _box.put('notifications', state);
  }
}

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
      : super(_box.get('calculationMethod', defaultValue: 2) as int);

  void setMethod(int method) {
    _box.put('calculationMethod', method);
    state = method;
  }
}
