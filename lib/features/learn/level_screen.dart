import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../l10n/app_localizations.dart';
import '../settings/settings_provider.dart';
import 'learn_provider.dart';

class LevelScreen extends ConsumerWidget {
  final String levelId;
  final String levelTitle;

  const LevelScreen({
    super.key,
    required this.levelId,
    required this.levelTitle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider).languageCode;
    final levelsAsync = ref.watch(learnLevelsProvider);
    final progress = ref.watch(learnProgressProvider);

    return Scaffold(
      appBar: AppBar(title: Text(levelTitle)),
      body: levelsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l10n.errorLoading)),
        data: (levels) {
          final level = levels.firstWhere((l) => l.id == levelId);
          final progressNotifier = ref.read(learnProgressProvider.notifier);

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: level.lessons.length,
            itemBuilder: (context, index) {
              final lesson = level.lessons[index];
              final isCompleted = progress[lesson.id] == true;
              final isUnlocked =
                  progressNotifier.isLessonUnlocked(level, index);

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: isUnlocked ? 1 : 0,
                color: isUnlocked ? Colors.white : Colors.grey.shade100,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: isCompleted
                      ? const BorderSide(
                          color: UmmatiTheme.accentGold, width: 1.5)
                      : BorderSide.none,
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? UmmatiTheme.accentGold.withValues(alpha: 0.15)
                          : isUnlocked
                              ? UmmatiTheme.primaryGreen
                                  .withValues(alpha: 0.1)
                              : Colors.grey.shade200,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: isCompleted
                          ? const Icon(Icons.check,
                              color: UmmatiTheme.accentGold, size: 22)
                          : isUnlocked
                              ? Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    color: UmmatiTheme.primaryGreen,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                )
                              : Icon(Icons.lock_outline,
                                  color: Colors.grey.shade400, size: 20),
                    ),
                  ),
                  title: Text(
                    lesson.title(locale),
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isUnlocked
                          ? UmmatiTheme.darkText
                          : Colors.grey.shade500,
                    ),
                  ),
                  subtitle: Text(
                    '${lesson.items.length} ${l10n.lessonItems}',
                    style: TextStyle(
                      fontSize: 13,
                      color: isUnlocked
                          ? UmmatiTheme.lightText
                          : Colors.grey.shade400,
                    ),
                  ),
                  trailing: isUnlocked
                      ? const Icon(Icons.chevron_right,
                          color: UmmatiTheme.lightText)
                      : null,
                  onTap: isUnlocked
                      ? () => context.go(
                          '/learn/level/$levelId/lesson/${lesson.id}?title=${Uri.encodeComponent(lesson.title(locale))}')
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
