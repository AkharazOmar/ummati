import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/prayer_times/prayer_times_screen.dart';
import '../features/qibla/qibla_screen.dart';
import '../features/quran/quran_screen.dart';
import '../features/quran/surah_screen.dart';
import '../features/settings/settings_screen.dart';
import '../shared/widgets/bottom_nav_bar.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/prayer-times',
  routes: [
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
                    return SurahScreen(
                      surahNumber: surahNumber,
                      surahName: surahName,
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
