import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../core/models/prayer_time.dart';
import '../../core/utils/date_utils.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/islamic_card.dart';
import 'prayer_times_provider.dart';

class PrayerTimesScreen extends ConsumerWidget {
  const PrayerTimesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final prayerTimesAsync = ref.watch(prayerTimesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.prayerTimes),
      ),
      body: prayerTimesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _buildError(context, ref, l10n, error),
        data: (prayerTimes) => _buildContent(context, ref, l10n, prayerTimes),
      ),
    );
  }

  Widget _buildError(BuildContext context, WidgetRef ref, AppLocalizations l10n,
      Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: UmmatiTheme.accentGold,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.errorLoading,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => ref.read(prayerTimesProvider.notifier).refresh(),
              icon: const Icon(Icons.refresh),
              label: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref,
      AppLocalizations l10n, DailyPrayerTimes data) {
    final next = data.nextPrayer;

    return RefreshIndicator(
      color: UmmatiTheme.primaryGreen,
      onRefresh: () => ref.read(prayerTimesProvider.notifier).refresh(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Hijri date header
          IslamicCard(
            child: Column(
              children: [
                Text(
                  l10n.today,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  data.hijriDate,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontFamily: UmmatiTheme.fontFamilyArabic,
                        color: UmmatiTheme.primaryGreen,
                      ),
                ),
              ],
            ),
          ),

          // Next prayer highlight
          if (next != null) ...[
            const SizedBox(height: 8),
            IslamicCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    l10n.nextPrayer,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _localizedPrayerName(l10n, next.name),
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: UmmatiTheme.primaryGreen,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.inTime(HijriDateUtils.timeUntil(next.time)),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: UmmatiTheme.accentGold,
                        ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),

          // All prayer times
          ...data.all.map(
            (prayer) => _buildPrayerRow(context, l10n, prayer, next),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerRow(BuildContext context, AppLocalizations l10n,
      PrayerTime prayer, PrayerTime? nextPrayer) {
    final isNext = nextPrayer != null && prayer.name == nextPrayer.name;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: isNext
            ? UmmatiTheme.primaryGreen.withValues(alpha: 0.08)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isNext
            ? Border.all(color: UmmatiTheme.primaryGreen, width: 1.5)
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (isNext)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: UmmatiTheme.accentGold,
                  ),
                ),
              Text(
                _localizedPrayerName(l10n, prayer.name),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: isNext ? FontWeight.bold : FontWeight.w500,
                      color: isNext
                          ? UmmatiTheme.primaryGreen
                          : UmmatiTheme.darkText,
                    ),
              ),
            ],
          ),
          Text(
            HijriDateUtils.formatTime(prayer.time),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: isNext ? FontWeight.bold : FontWeight.w500,
                  color:
                      isNext ? UmmatiTheme.primaryGreen : UmmatiTheme.darkText,
                ),
          ),
        ],
      ),
    );
  }

  String _localizedPrayerName(AppLocalizations l10n, String name) {
    switch (name) {
      case 'Fajr':
        return l10n.fajr;
      case 'Sunrise':
        return l10n.sunrise;
      case 'Dhuhr':
        return l10n.dhuhr;
      case 'Asr':
        return l10n.asr;
      case 'Maghrib':
        return l10n.maghrib;
      case 'Isha':
        return l10n.isha;
      default:
        return name;
    }
  }
}
