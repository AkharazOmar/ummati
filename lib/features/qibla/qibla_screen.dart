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
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.read(qiblaProvider.notifier).refresh(),
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

class _QiblaCompass extends StatefulWidget {
  final double qiblaBearing;
  final double distance;

  const _QiblaCompass({
    required this.qiblaBearing,
    required this.distance,
  });

  @override
  State<_QiblaCompass> createState() => _QiblaCompassState();
}

class _QiblaCompassState extends State<_QiblaCompass>
    with SingleTickerProviderStateMixin {
  double _currentHeading = 0;
  double _previousHeading = 0;
  bool _hasCompass = true;

  @override
  void initState() {
    super.initState();
    _checkCompass();
  }

  Future<void> _checkCompass() async {
    // FlutterCompass.events will be null if no sensor
    final event = await FlutterCompass.events?.first;
    if (event == null || event.heading == null) {
      setState(() => _hasCompass = false);
    }
  }

  /// Smoothly interpolate heading to avoid jumps around 0°/360°.
  double _smoothHeading(double newHeading) {
    double diff = newHeading - _previousHeading;
    // Normalize to [-180, 180]
    if (diff > 180) diff -= 360;
    if (diff < -180) diff += 360;
    _previousHeading = _previousHeading + diff;
    return _previousHeading;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (!_hasCompass) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.sensors_off, size: 64, color: UmmatiTheme.accentGold),
              const SizedBox(height: 16),
              Text(
                l10n.noCompass,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              IslamicCard(
                child: Column(
                  children: [
                    Text(
                      l10n.degreesFromNorth(
                          widget.qiblaBearing.toStringAsFixed(1)),
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: UmmatiTheme.primaryGreen,
                              ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.distance.toStringAsFixed(0)} km',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return StreamBuilder<CompassEvent>(
      stream: FlutterCompass.events,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data?.heading == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final rawHeading = snapshot.data!.heading!;
        _currentHeading = _smoothHeading(rawHeading);
        final accuracy = snapshot.data!.accuracy ?? 0;
        final lowAccuracy = accuracy > 15 || accuracy < 0;

        // Qibla relative to phone orientation
        final qiblaRelative = widget.qiblaBearing - _currentHeading;
        // Check if phone is pointing towards Qibla (±5°)
        final normalizedRelative = ((qiblaRelative % 360) + 360) % 360;
        final isAligned =
            normalizedRelative < 5 || normalizedRelative > 355;

        return Column(
          children: [
            const SizedBox(height: 16),

            // Info card
            IslamicCard(
              child: Column(
                children: [
                  Text(
                    l10n.degreesFromNorth(
                        widget.qiblaBearing.toStringAsFixed(1)),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: UmmatiTheme.primaryGreen,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.distance.toStringAsFixed(0)} km',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),

            // Calibration warning
            if (lowAccuracy) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.warning_amber,
                        size: 16, color: UmmatiTheme.accentGold),
                    const SizedBox(width: 6),
                    Text(
                      l10n.calibrateCompass,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: UmmatiTheme.accentGold,
                          ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Compass
            Expanded(
              child: Center(
                child: SizedBox(
                  width: 300,
                  height: 300,
                  child: AnimatedRotation(
                    turns: -_currentHeading / 360,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Compass circle
                        Container(
                          width: 280,
                          height: 280,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: UmmatiTheme.primaryGreen
                                  .withValues(alpha: 0.15),
                              width: 3,
                            ),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: UmmatiTheme.primaryGreen
                                    .withValues(alpha: 0.08),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),

                        // Cardinal directions
                        ..._buildCardinalDirections(),

                        // Degree ticks
                        ..._buildDegreeTicks(),

                        // Qibla needle
                        Transform.rotate(
                          angle: widget.qiblaBearing * (pi / 180),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.mosque,
                                color: isAligned
                                    ? UmmatiTheme.primaryGreen
                                    : UmmatiTheme.accentGold,
                                size: 36,
                              ),
                              Container(
                                width: 3,
                                height: 80,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(2),
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      isAligned
                                          ? UmmatiTheme.primaryGreen
                                          : UmmatiTheme.accentGold,
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Center dot
                        Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isAligned
                                ? UmmatiTheme.primaryGreen
                                : UmmatiTheme.accentGold,
                            boxShadow: [
                              BoxShadow(
                                color: (isAligned
                                        ? UmmatiTheme.primaryGreen
                                        : UmmatiTheme.accentGold)
                                    .withValues(alpha: 0.4),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Status text
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  isAligned ? l10n.qiblaAligned : l10n.qiblaDescription,
                  key: ValueKey(isAligned),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isAligned
                            ? UmmatiTheme.primaryGreen
                            : null,
                        fontWeight:
                            isAligned ? FontWeight.w600 : null,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _buildCardinalDirections() {
    const directions = [
      (0.0, 'N'),
      (90.0, 'E'),
      (180.0, 'S'),
      (270.0, 'W'),
    ];

    return directions.map((d) {
      return Transform.rotate(
        angle: d.$1 * (pi / 180),
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 14),
            child: Transform.rotate(
              angle: -d.$1 * (pi / 180),
              child: Text(
                d.$2,
                style: TextStyle(
                  color: d.$2 == 'N'
                      ? UmmatiTheme.primaryGreen
                      : UmmatiTheme.lightText,
                  fontWeight:
                      d.$2 == 'N' ? FontWeight.bold : FontWeight.w500,
                  fontSize: d.$2 == 'N' ? 18 : 14,
                ),
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  List<Widget> _buildDegreeTicks() {
    final ticks = <Widget>[];
    for (var i = 0; i < 360; i += 30) {
      if (i % 90 == 0) continue; // Skip cardinal positions
      ticks.add(
        Transform.rotate(
          angle: i * (pi / 180),
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Container(
                width: 2,
                height: 12,
                decoration: BoxDecoration(
                  color: UmmatiTheme.lightText.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ),
          ),
        ),
      );
    }
    return ticks;
  }
}
