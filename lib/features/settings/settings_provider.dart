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
