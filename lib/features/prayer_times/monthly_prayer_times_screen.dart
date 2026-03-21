import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../core/models/prayer_time.dart';
import '../../core/utils/date_utils.dart';
import '../../l10n/app_localizations.dart';
import 'prayer_times_provider.dart';

class MonthlyPrayerTimesScreen extends ConsumerStatefulWidget {
  const MonthlyPrayerTimesScreen({super.key});

  @override
  ConsumerState<MonthlyPrayerTimesScreen> createState() =>
      _MonthlyPrayerTimesScreenState();
}

class _MonthlyPrayerTimesScreenState
    extends ConsumerState<MonthlyPrayerTimesScreen> {
  late int _year;
  late int _month;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _year = now.year;
    _month = now.month;
  }

  void _previousMonth() {
    setState(() {
      _month--;
      if (_month < 1) {
        _month = 12;
        _year--;
      }
    });
  }

  void _nextMonth() {
    setState(() {
      _month++;
      if (_month > 12) {
        _month = 1;
        _year++;
      }
    });
  }

  String _monthName(AppLocalizations l10n, int month) {
    const months = [
      'january', 'february', 'march', 'april',
      'may', 'june', 'july', 'august',
      'september', 'october', 'november', 'december',
    ];
    return l10n.monthName(months[month - 1]);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final param = MonthlyParam(_year, _month);
    final monthlyAsync = ref.watch(monthlyPrayerTimesProvider(param));
    final today = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.monthlySchedule),
      ),
      body: Column(
        children: [
          // Month navigation
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: _previousMonth,
                  icon: const Icon(Icons.chevron_left),
                ),
                Text(
                  '${_monthName(l10n, _month)} $_year',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                IconButton(
                  onPressed: _nextMonth,
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
          ),

          // Table
          Expanded(
            child: monthlyAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(l10n.errorLoading),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.invalidate(
                          monthlyPrayerTimesProvider(param)),
                      child: Text(l10n.retry),
                    ),
                  ],
                ),
              ),
              data: (days) => _buildTable(context, l10n, days, today),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTable(BuildContext context, AppLocalizations l10n,
      List<DailyPrayerTimes> days, DateTime today) {
    const headerStyle = TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w700,
      color: Colors.white,
    );
    const cellStyle = TextStyle(
      fontSize: 11,
      color: UmmatiTheme.darkText,
    );

    return SingleChildScrollView(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(UmmatiTheme.primaryGreen),
          dataRowMinHeight: 40,
          dataRowMaxHeight: 40,
          headingRowHeight: 44,
          horizontalMargin: 12,
          columnSpacing: 14,
          columns: [
            DataColumn(label: Text(l10n.dayColumn, style: headerStyle)),
            DataColumn(label: Text(l10n.fajr, style: headerStyle)),
            DataColumn(label: Text(l10n.sunrise, style: headerStyle)),
            DataColumn(label: Text(l10n.dhuhr, style: headerStyle)),
            DataColumn(label: Text(l10n.asr, style: headerStyle)),
            DataColumn(label: Text(l10n.maghrib, style: headerStyle)),
            DataColumn(label: Text(l10n.isha, style: headerStyle)),
          ],
          rows: days.map((day) {
            final isToday = day.date.year == today.year &&
                day.date.month == today.month &&
                day.date.day == today.day;

            final rowColor = isToday
                ? WidgetStateProperty.all(
                    UmmatiTheme.primaryGreen.withValues(alpha: 0.1))
                : null;

            final dayCellStyle = isToday
                ? cellStyle.copyWith(
                    fontWeight: FontWeight.w700,
                    color: UmmatiTheme.primaryGreen,
                  )
                : cellStyle;

            final label =
                '${day.date.day.toString().padLeft(2, '0')}/${day.date.month.toString().padLeft(2, '0')}';

            return DataRow(
              color: rowColor,
              cells: [
                DataCell(Text(label, style: dayCellStyle)),
                DataCell(Text(HijriDateUtils.formatTime(day.fajr.time),
                    style: cellStyle)),
                DataCell(Text(HijriDateUtils.formatTime(day.sunrise.time),
                    style: cellStyle)),
                DataCell(Text(HijriDateUtils.formatTime(day.dhuhr.time),
                    style: cellStyle)),
                DataCell(Text(HijriDateUtils.formatTime(day.asr.time),
                    style: cellStyle)),
                DataCell(Text(HijriDateUtils.formatTime(day.maghrib.time),
                    style: cellStyle)),
                DataCell(Text(HijriDateUtils.formatTime(day.isha.time),
                    style: cellStyle)),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
