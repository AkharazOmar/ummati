import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app/app.dart';
import 'features/settings/settings_provider.dart';
import 'features/prayer_times/prayer_times_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();
  await initSettingsBox();
  await initPrayerCacheBox();

  runApp(
    const ProviderScope(
      child: UmmatiApp(),
    ),
  );
}
