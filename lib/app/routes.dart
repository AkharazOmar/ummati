import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

import '../features/onboarding/location_permission_screen.dart';
import '../features/prayer_times/monthly_prayer_times_screen.dart';
import '../features/prayer_times/prayer_times_screen.dart';
import '../features/qibla/qibla_screen.dart';
import '../features/quran/quran_screen.dart';
import '../features/quran/surah_screen.dart';
import '../features/settings/settings_screen.dart';
import '../shared/widgets/bottom_nav_bar.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/location-permission',
  redirect: (context, state) async {
    final onPermissionScreen =
        state.matchedLocation == '/location-permission';

    final permission = await Geolocator.checkPermission();
    final hasPermission = permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;

    // If already granted, skip the permission screen
    if (onPermissionScreen && hasPermission) {
      return '/prayer-times';
    }

    return null;
  },
  routes: [
    GoRoute(
      path: '/location-permission',
      builder: (context, state) => const LocationPermissionScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldWithNavBar(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/prayer-times',
              builder: (context, state) => const PrayerTimesScreen(),
              routes: [
                GoRoute(
                  path: 'monthly',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) =>
                      const MonthlyPrayerTimesScreen(),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/qibla',
              builder: (context, state) => const QiblaScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/quran',
              builder: (context, state) => const QuranScreen(),
              routes: [
                GoRoute(
                  path: 'surah/:surahNumber',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) {
                    final surahNumber =
                        int.parse(state.pathParameters['surahNumber']!);
                    final surahName =
                        state.uri.queryParameters['name'] ?? 'Surah';
                    final ayahParam = state.uri.queryParameters['ayah'];
                    final initialAyah =
                        ayahParam != null ? int.tryParse(ayahParam) : null;
                    return SurahScreen(
                      surahNumber: surahNumber,
                      surahName: surahName,
                      initialAyah: initialAyah,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
