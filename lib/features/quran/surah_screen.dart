import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../app/theme.dart';
import '../../l10n/app_localizations.dart';
import '../settings/settings_provider.dart';
import 'quran_provider.dart';

class SurahScreen extends ConsumerStatefulWidget {
  final int surahNumber;
  final String surahName;
  final int? initialAyah;

  const SurahScreen({
    super.key,
    required this.surahNumber,
    required this.surahName,
    this.initialAyah,
  });

  @override
  ConsumerState<SurahScreen> createState() => _SurahScreenState();
}

class _SurahScreenState extends ConsumerState<SurahScreen> {
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();

  void _saveBookmark(int ayahIndex) {
    ref.read(readingPositionProvider.notifier).save(
          widget.surahNumber,
          widget.surahName,
          ayahIndex,
        );
  }

  /// Find the ayah index of the first fully or mostly visible item.
  int _findVisibleAyahIndex() {
    final positions = _itemPositionsListener.itemPositions.value;
    if (positions.isEmpty) return 0;

    // Get the item closest to the top of the viewport
    final sorted = positions.toList()
      ..sort((a, b) => a.itemLeadingEdge.compareTo(b.itemLeadingEdge));
    final topItem = sorted.first;

    // Convert list index back to ayah index (offset by 1 if bismillah header)
    final listIndex = topItem.index;
    final hasBismillah = widget.surahNumber != 9;
    if (hasBismillah && listIndex == 0) return 0;
    return hasBismillah ? listIndex - 1 : listIndex;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider).languageCode;
    final param = SurahAyahsParam(widget.surahNumber, locale);
    final ayahsAsync = ref.watch(surahAyahsProvider(param));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.surahName),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_outline),
            tooltip: l10n.saveBookmark,
            onPressed: () {
              final position = _findVisibleAyahIndex();
              _saveBookmark(position);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.bookmarkSaved),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: ayahsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(l10n.errorLoading),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(surahAyahsProvider(param)),
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
        data: (ayahs) {
          final hasBismillah = widget.surahNumber != 9;
          final itemCount = ayahs.length + (hasBismillah ? 1 : 0);

          // Convert ayah index to list index (offset by 1 if bismillah)
          final initialIndex = widget.initialAyah != null
              ? widget.initialAyah! + (hasBismillah ? 1 : 0)
              : 0;

          return ScrollablePositionedList.builder(
            itemScrollController: _itemScrollController,
            itemPositionsListener: _itemPositionsListener,
            initialScrollIndex: initialIndex.clamp(0, itemCount - 1),
            padding: const EdgeInsets.all(20),
            itemCount: itemCount,
            itemBuilder: (context, index) {
              // Bismillah header (except for Surah At-Tawbah)
              if (hasBismillah && index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Text(
                    l10n.bismillah,
                    style: const TextStyle(
                      fontFamily: UmmatiTheme.fontFamilyArabic,
                      fontSize: 22,
                      color: UmmatiTheme.accentGold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              }

              final ayahIndex = hasBismillah ? index - 1 : index;
              final ayah = ayahs[ayahIndex];

              return Container(
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ayahIndex.isEven
                      ? UmmatiTheme.primaryGreen.withValues(alpha: 0.03)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Verse number badge
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: UmmatiTheme.primaryGreen
                                .withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${ayah.numberInSurah}',
                              style: const TextStyle(
                                color: UmmatiTheme.primaryGreen,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Arabic text
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: Text(
                        ayah.text,
                        style: const TextStyle(
                          fontFamily: UmmatiTheme.fontFamilyArabic,
                          fontSize: 24,
                          height: 2.0,
                          color: UmmatiTheme.darkText,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),

                    // Phonetic transliteration
                    if (ayah.phonetic != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        ayah.phonetic!,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          fontStyle: FontStyle.italic,
                          color: UmmatiTheme.primaryGreen.withValues(alpha: 0.7),
                        ),
                      ),
                    ],

                    // Translation (if available)
                    if (ayah.translation != null) ...[
                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      const SizedBox(height: 12),
                      Text(
                        ayah.translation!,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.6,
                          color: UmmatiTheme.darkText.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
