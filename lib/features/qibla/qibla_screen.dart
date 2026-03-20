import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../app/theme.dart';
import '../../shared/widgets/islamic_card.dart';
import 'qibla_provider.dart';

class QiblaScreen extends ConsumerWidget {
  const QiblaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final qiblaAsync = ref.watch(qiblaProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.qiblaDirection),
      ),
      body: qiblaAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.location_off,
                    size: 64, color: UmmatiTheme.accentGold),
                const SizedBox(height: 16),
                Text(l10n.locationPermissionRequired,
                    textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () =>
                      ref.read(qiblaProvider.notifier).refresh(),
                  child: Text(l10n.retry),
                ),
              ],
            ),
          ),
        ),
        data: (qibla) => _QiblaCompass(
          qiblaBearing: qibla.bearing,
          distance: qibla.distance,
        ),
      ),
    );
  }
}

class _QiblaCompass extends StatelessWidget {
  final double qiblaBearing;
  final double distance;

  const _QiblaCompass({
    required this.qiblaBearing,
    required this.distance,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return StreamBuilder<CompassEvent>(
      stream: FlutterCompass.events,
      builder: (context, snapshot) {
        final heading = snapshot.data?.heading ?? 0;
        final qiblaRelative = qiblaBearing - heading;

        return Column(
          children: [
            const SizedBox(height: 24),
            IslamicCard(
              child: Column(
                children: [
                  Text(
                    l10n.degreesFromNorth(qiblaBearing.toStringAsFixed(1)),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: UmmatiTheme.primaryGreen,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${distance.toStringAsFixed(0)} km',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: Center(
                child: SizedBox(
                  width: 280,
                  height: 280,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Compass ring
                      Transform.rotate(
                        angle: -heading * (pi / 180),
                        child: Container(
                          width: 280,
                          height: 280,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: UmmatiTheme.primaryGreen.withValues(alpha: 0.2),
                              width: 3,
                            ),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // N indicator
                              const Positioned(
                                top: 8,
                                child: Text(
                                  'N',
                                  style: TextStyle(
                                    color: UmmatiTheme.primaryGreen,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              // Qibla needle
                              Transform.rotate(
                                angle: qiblaBearing * (pi / 180),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.mosque,
                                      color: UmmatiTheme.accentGold,
                                      size: 32,
                                    ),
                                    Container(
                                      width: 3,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            UmmatiTheme.accentGold,
                                            UmmatiTheme.accentGold
                                                .withValues(alpha: 0),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Center point
                      Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: UmmatiTheme.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                l10n.qiblaDescription,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        );
      },
    );
  }
}
