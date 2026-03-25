import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../app/theme.dart';
import '../../l10n/app_localizations.dart';
import '../settings/settings_provider.dart';
import 'audio_provider.dart';
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

  @override
  void dispose() {
    // Stop audio when leaving the screen
    ref.read(quranAudioProvider.notifier).stop();
    super.dispose();
  }

  void _saveBookmark(int ayahIndex) {
    ref.read(readingPositionProvider.notifier).save(
          widget.surahNumber,
          widget.surahName,
          ayahIndex,
        );
  }

  int _findVisibleAyahIndex() {
    final positions = _itemPositionsListener.itemPositions.value;
    if (positions.isEmpty) return 0;

    final sorted = positions.toList()
      ..sort((a, b) => a.itemLeadingEdge.compareTo(b.itemLeadingEdge));
    final topItem = sorted.first;

    final listIndex = topItem.index;
    final hasBismillah = widget.surahNumber != 9;
    if (hasBismillah && listIndex == 0) return 0;
    return hasBismillah ? listIndex - 1 : listIndex;
  }

  void _scrollToAyah(int ayahIndex) {
    final hasBismillah = widget.surahNumber != 9;
    final listIndex = ayahIndex + (hasBismillah ? 1 : 0);
    _itemScrollController.scrollTo(
      index: listIndex,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider).languageCode;
    final param = SurahAyahsParam(widget.surahNumber, locale);
    final ayahsAsync = ref.watch(surahAyahsProvider(param));
    final audioState = ref.watch(quranAudioProvider);

    // Auto-scroll to currently playing ayah
    ref.listen<QuranAudioState>(quranAudioProvider, (prev, next) {
      if (prev?.currentAyahIndex != next.currentAyahIndex &&
          next.currentAyahIndex >= 0 &&
          next.isPlaying) {
        _scrollToAyah(next.currentAyahIndex);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.surahName),
        actions: [
          // Download button
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: l10n.downloadAudio,
            onPressed: () => _showDownloadDialog(context, l10n),
          ),
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
          // Load ayahs into audio provider
          if (audioState.ayahs.length != ayahs.length) {
            Future.microtask(
                () => ref.read(quranAudioProvider.notifier).loadAyahs(ayahs));
          }

          final hasBismillah = widget.surahNumber != 9;
          final itemCount = ayahs.length + (hasBismillah ? 1 : 0);

          final initialIndex = widget.initialAyah != null
              ? widget.initialAyah! + (hasBismillah ? 1 : 0)
              : 0;

          return Column(
            children: [
              Expanded(
                child: ScrollablePositionedList.builder(
                  itemScrollController: _itemScrollController,
                  itemPositionsListener: _itemPositionsListener,
                  initialScrollIndex: initialIndex.clamp(0, itemCount - 1),
                  padding: const EdgeInsets.all(20),
                  itemCount: itemCount,
                  itemBuilder: (context, index) {
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
                    final isCurrentAyah =
                        audioState.currentAyahIndex == ayahIndex;
                    final isInLoop = audioState.isLooping &&
                        audioState.loopStart != null &&
                        audioState.loopEnd != null &&
                        ayahIndex >= audioState.loopStart! &&
                        ayahIndex <= audioState.loopEnd!;

                    return _AyahTile(
                      ayah: ayah,
                      ayahIndex: ayahIndex,
                      isCurrentAyah: isCurrentAyah,
                      isPlaying: isCurrentAyah && audioState.isPlaying,
                      isInLoop: isInLoop,
                      l10n: l10n,
                    );
                  },
                ),
              ),
              // Bottom audio control bar
              if (audioState.currentAyahIndex >= 0)
                _AudioControlBar(l10n: l10n),
            ],
          );
        },
      ),
    );
  }

  void _showDownloadDialog(BuildContext context, AppLocalizations l10n) {
    final downloadState =
        ref.read(surahAudioDownloadProvider(widget.surahNumber));
    if (downloadState.isDownloaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.audioDownloaded)),
      );
      return;
    }

    final locale = ref.read(localeProvider).languageCode;
    final param = SurahAyahsParam(widget.surahNumber, locale);
    final ayahs = ref.read(surahAyahsProvider(param)).valueOrNull;
    if (ayahs == null) return;

    ref
        .read(surahAudioDownloadProvider(widget.surahNumber).notifier)
        .download(ayahs);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.downloading)),
    );
  }
}

/// Individual ayah tile with play button.
class _AyahTile extends ConsumerWidget {
  final dynamic ayah;
  final int ayahIndex;
  final bool isCurrentAyah;
  final bool isPlaying;
  final bool isInLoop;
  final AppLocalizations l10n;

  const _AyahTile({
    required this.ayah,
    required this.ayahIndex,
    required this.isCurrentAyah,
    required this.isPlaying,
    required this.isInLoop,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCurrentAyah
            ? UmmatiTheme.accentGold.withValues(alpha: 0.1)
            : isInLoop
                ? UmmatiTheme.primaryGreen.withValues(alpha: 0.06)
                : ayahIndex.isEven
                    ? UmmatiTheme.primaryGreen.withValues(alpha: 0.03)
                    : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isCurrentAyah
            ? Border.all(color: UmmatiTheme.accentGold, width: 1.5)
            : isInLoop
                ? Border.all(
                    color: UmmatiTheme.primaryGreen.withValues(alpha: 0.3))
                : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Verse number badge + play button
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: UmmatiTheme.primaryGreen.withValues(alpha: 0.1),
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
              const Spacer(),
              // Play/pause button for this ayah
              if (ayah.audioUrl != null)
                _AyahPlayButton(
                  ayahIndex: ayahIndex,
                  isCurrentAyah: isCurrentAyah,
                  isPlaying: isPlaying,
                ),
              // Loop controls
              if (ayah.audioUrl != null)
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    size: 20,
                    color: UmmatiTheme.lightText,
                  ),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'loop_start',
                      child: Text(l10n.setLoopStart),
                    ),
                    PopupMenuItem(
                      value: 'loop_end',
                      child: Text(l10n.setLoopEnd),
                    ),
                  ],
                  onSelected: (value) {
                    final audio = ref.read(quranAudioProvider);
                    final notifier = ref.read(quranAudioProvider.notifier);
                    if (value == 'loop_start') {
                      final end = audio.loopEnd ?? ayahIndex;
                      notifier.setLoopRange(ayahIndex, end);
                    } else if (value == 'loop_end') {
                      final start = audio.loopStart ?? ayahIndex;
                      notifier.setLoopRange(start, ayahIndex);
                    }
                  },
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

          // Translation
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
  }
}

/// Small play/pause button next to each ayah.
class _AyahPlayButton extends ConsumerWidget {
  final int ayahIndex;
  final bool isCurrentAyah;
  final bool isPlaying;

  const _AyahPlayButton({
    required this.ayahIndex,
    required this.isCurrentAyah,
    required this.isPlaying,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: 36,
      height: 36,
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(
          isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
          color: isCurrentAyah
              ? UmmatiTheme.accentGold
              : UmmatiTheme.primaryGreen,
          size: 32,
        ),
        onPressed: () {
          final notifier = ref.read(quranAudioProvider.notifier);
          if (isCurrentAyah && isPlaying) {
            notifier.togglePlayPause();
          } else {
            notifier.playAyah(ayahIndex);
          }
        },
      ),
    );
  }
}

/// Bottom control bar for audio playback.
class _AudioControlBar extends ConsumerWidget {
  final AppLocalizations l10n;

  const _AudioControlBar({required this.l10n});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioState = ref.watch(quranAudioProvider);
    final notifier = ref.read(quranAudioProvider.notifier);
    final currentAyah = audioState.currentAyahIndex >= 0 &&
            audioState.currentAyahIndex < audioState.ayahs.length
        ? audioState.ayahs[audioState.currentAyahIndex]
        : null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Loop range indicator
            if (audioState.isLooping &&
                audioState.loopStart != null &&
                audioState.loopEnd != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.repeat,
                        size: 14, color: UmmatiTheme.primaryGreen),
                    const SizedBox(width: 4),
                    Text(
                      l10n.loopFrom(
                          audioState.loopStart! + 1, audioState.loopEnd! + 1),
                      style: const TextStyle(
                          fontSize: 12, color: UmmatiTheme.primaryGreen),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => notifier.clearLoopRange(),
                      child: const Icon(Icons.close,
                          size: 14, color: UmmatiTheme.lightText),
                    ),
                  ],
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Previous
                IconButton(
                  icon: const Icon(Icons.skip_previous),
                  color: UmmatiTheme.primaryGreen,
                  onPressed: () => notifier.previous(),
                ),
                // Play/Pause
                IconButton(
                  icon: Icon(
                    audioState.isPlaying
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_filled,
                    size: 44,
                  ),
                  color: UmmatiTheme.primaryGreen,
                  onPressed: () => notifier.togglePlayPause(),
                ),
                // Next
                IconButton(
                  icon: const Icon(Icons.skip_next),
                  color: UmmatiTheme.primaryGreen,
                  onPressed: () => notifier.next(),
                ),
                const SizedBox(width: 8),
                // Verse info
                if (currentAyah != null)
                  Text(
                    l10n.verseNumber(currentAyah.numberInSurah),
                    style: const TextStyle(
                      fontSize: 13,
                      color: UmmatiTheme.darkText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                const Spacer(),
                // Repeat button
                _RepeatButton(l10n: l10n),
                // Stop
                IconButton(
                  icon: const Icon(Icons.stop),
                  color: UmmatiTheme.lightText,
                  onPressed: () => notifier.stop(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Repeat count selector button.
class _RepeatButton extends ConsumerWidget {
  final AppLocalizations l10n;

  const _RepeatButton({required this.l10n});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repeatCount = ref.watch(quranAudioProvider).repeatCount;

    return PopupMenuButton<int>(
      icon: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.repeat,
            color: repeatCount > 0
                ? UmmatiTheme.primaryGreen
                : UmmatiTheme.lightText,
          ),
          if (repeatCount > 0)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: UmmatiTheme.accentGold,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$repeatCount',
                  style: const TextStyle(
                    fontSize: 9,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
      itemBuilder: (context) => [
        PopupMenuItem(value: 0, child: Text(l10n.noRepeat)),
        PopupMenuItem(value: 1, child: Text(l10n.repeatNTimes(2))),
        PopupMenuItem(value: 2, child: Text(l10n.repeatNTimes(3))),
        PopupMenuItem(value: 4, child: Text(l10n.repeatNTimes(5))),
        PopupMenuItem(value: 9, child: Text(l10n.repeatNTimes(10))),
      ],
      onSelected: (value) {
        ref.read(quranAudioProvider.notifier).setRepeatCount(value);
      },
    );
  }
}
