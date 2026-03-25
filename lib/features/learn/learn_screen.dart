import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../l10n/app_localizations.dart';
import '../settings/settings_provider.dart';
import 'learn_provider.dart';

class LearnScreen extends ConsumerWidget {
  const LearnScreen({super.key});

  static const _levelIcons = {
    'abc': Icons.abc,
    'edit_note': Icons.edit_note,
    'link': Icons.link,
    'auto_fix_high': Icons.auto_fix_high,
    'stars': Icons.stars,
    'auto_stories': Icons.auto_stories,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider).languageCode;
    final levelsAsync = ref.watch(learnLevelsProvider);
    final progress = ref.watch(learnProgressProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.learn)),
      body: levelsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l10n.errorLoading)),
        data: (levels) {
          final progressNotifier = ref.read(learnProgressProvider.notifier);
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: levels.length,
            itemBuilder: (context, levelIndex) {
              final level = levels[levelIndex];
              final isUnlocked =
                  progressNotifier.isLevelUnlocked(levels, levelIndex);

              // Count completed lessons
              final completedCount =
                  level.lessons.where((l) => progress[l.id] == true).length;

              return _LevelCard(
                level: level,
                locale: locale,
                isUnlocked: isUnlocked,
                completedCount: completedCount,
                icon: _levelIcons[level.icon] ?? Icons.school,
                onTap: isUnlocked
                    ? () => context.go(
                        '/learn/level/${level.id}?title=${Uri.encodeComponent(level.title(locale))}')
                    : null,
              );
            },
          );
        },
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  final LearnLevel level;
  final String locale;
  final bool isUnlocked;
  final int completedCount;
  final IconData icon;
  final VoidCallback? onTap;

  const _LevelCard({
    required this.level,
    required this.locale,
    required this.isUnlocked,
    required this.completedCount,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final totalLessons = level.lessons.length;
    final progressFraction =
        totalLessons > 0 ? completedCount / totalLessons : 0.0;
    final isComplete = completedCount == totalLessons;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isUnlocked ? 2 : 0,
      color: isUnlocked ? Colors.white : Colors.grey.shade100,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isComplete
            ? const BorderSide(color: UmmatiTheme.accentGold, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Level icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: isUnlocked
                      ? UmmatiTheme.primaryGreen.withValues(alpha: 0.1)
                      : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isUnlocked ? icon : Icons.lock_outline,
                  color: isUnlocked
                      ? UmmatiTheme.primaryGreen
                      : Colors.grey.shade400,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      level.title(locale),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isUnlocked
                            ? UmmatiTheme.darkText
                            : Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      level.desc(locale),
                      style: TextStyle(
                        fontSize: 13,
                        color: isUnlocked
                            ? UmmatiTheme.lightText
                            : Colors.grey.shade400,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Progress bar
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progressFraction,
                              backgroundColor: Colors.grey.shade200,
                              color: isComplete
                                  ? UmmatiTheme.accentGold
                                  : UmmatiTheme.primaryGreen,
                              minHeight: 6,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$completedCount/$totalLessons',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isUnlocked
                                ? UmmatiTheme.primaryGreen
                                : Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (isUnlocked && !isComplete)
                const Icon(Icons.chevron_right, color: UmmatiTheme.lightText),
              if (isComplete)
                const Icon(Icons.check_circle, color: UmmatiTheme.accentGold),
            ],
          ),
        ),
      ),
    );
  }
}
