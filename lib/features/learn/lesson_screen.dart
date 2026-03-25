import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../l10n/app_localizations.dart';
import '../settings/settings_provider.dart';
import 'learn_provider.dart';

class LessonScreen extends ConsumerWidget {
  final String levelId;
  final String lessonId;
  final String lessonTitle;

  const LessonScreen({
    super.key,
    required this.levelId,
    required this.lessonId,
    required this.lessonTitle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider).languageCode;
    final levelsAsync = ref.watch(learnLevelsProvider);
    final tts = ref.read(arabicTtsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(lessonTitle)),
      body: levelsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l10n.errorLoading)),
        data: (levels) {
          final level = levels.firstWhere((l) => l.id == levelId);
          final lesson = level.lessons.firstWhere((l) => l.id == lessonId);

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: lesson.items.length,
                  itemBuilder: (context, index) {
                    final item = lesson.items[index];
                    return _LessonItemCard(
                      item: item,
                      locale: locale,
                      onPlayAudio: () => tts.speak(item.letter),
                    );
                  },
                ),
              ),
              // Start quiz button
              SafeArea(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.quiz),
                      label: Text(l10n.startQuiz),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () => context.go(
                          '/learn/level/$levelId/lesson/$lessonId/quiz?title=${Uri.encodeComponent(lessonTitle)}'),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LessonItemCard extends StatelessWidget {
  final LessonItem item;
  final String locale;
  final VoidCallback onPlayAudio;

  const _LessonItemCard({
    required this.item,
    required this.locale,
    required this.onPlayAudio,
  });

  @override
  Widget build(BuildContext context) {
    final hasForms =
        item.initial != null || item.medial != null || item.finalForm != null;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Letter + audio button
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.volume_up),
                  color: UmmatiTheme.primaryGreen,
                  iconSize: 28,
                  onPressed: onPlayAudio,
                ),
                const SizedBox(width: 8),
                Text(
                  item.letter,
                  style: const TextStyle(
                    fontFamily: UmmatiTheme.fontFamilyArabic,
                    fontSize: 56,
                    color: UmmatiTheme.darkText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Name and phonetic
            Text(
              item.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: UmmatiTheme.primaryGreen,
              ),
            ),
            Text(
              item.nameAr,
              style: const TextStyle(
                fontFamily: UmmatiTheme.fontFamilyArabic,
                fontSize: 16,
                color: UmmatiTheme.lightText,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              item.phonetic,
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: UmmatiTheme.primaryGreen.withValues(alpha: 0.7),
              ),
            ),

            // Letter forms (if alphabet level)
            if (hasForms) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (item.isolated != null)
                    _LetterForm(label: locale == 'fr' ? 'Isolée' : 'Isolated',
                        form: item.isolated!),
                  if (item.initial != null)
                    _LetterForm(label: locale == 'fr' ? 'Initiale' : 'Initial',
                        form: item.initial!),
                  if (item.medial != null)
                    _LetterForm(label: locale == 'fr' ? 'Médiane' : 'Medial',
                        form: item.medial!),
                  if (item.finalForm != null)
                    _LetterForm(label: locale == 'fr' ? 'Finale' : 'Final',
                        form: item.finalForm!),
                ],
              ),
            ],

            // Example word
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            Directionality(
              textDirection: TextDirection.rtl,
              child: Text(
                item.example,
                style: const TextStyle(
                  fontFamily: UmmatiTheme.fontFamilyArabic,
                  fontSize: 28,
                  color: UmmatiTheme.darkText,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              item.meaning(locale),
              style: const TextStyle(
                fontSize: 14,
                color: UmmatiTheme.lightText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LetterForm extends StatelessWidget {
  final String label;
  final String form;

  const _LetterForm({required this.label, required this.form});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          form,
          style: const TextStyle(
            fontFamily: UmmatiTheme.fontFamilyArabic,
            fontSize: 28,
            color: UmmatiTheme.darkText,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: UmmatiTheme.lightText,
          ),
        ),
      ],
    );
  }
}
