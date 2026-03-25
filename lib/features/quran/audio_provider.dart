import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/models/surah.dart';

/// State for the Quran audio player.
class QuranAudioState {
  /// All ayahs with audio URLs for the current surah.
  final List<Ayah> ayahs;

  /// Index of the currently playing/selected ayah (-1 = none).
  final int currentAyahIndex;

  /// Whether audio is currently playing.
  final bool isPlaying;

  /// Whether audio is loading/buffering.
  final bool isLoading;

  /// Repeat count for each verse (0 = no repeat, 1 = play once extra, etc.).
  final int repeatCount;

  /// Current repeat iteration (0-based).
  final int currentRepeat;

  /// Loop range: start index (inclusive). Null = no range loop.
  final int? loopStart;

  /// Loop range: end index (inclusive).
  final int? loopEnd;

  /// Whether range loop is active.
  final bool isLooping;

  const QuranAudioState({
    this.ayahs = const [],
    this.currentAyahIndex = -1,
    this.isPlaying = false,
    this.isLoading = false,
    this.repeatCount = 0,
    this.currentRepeat = 0,
    this.loopStart,
    this.loopEnd,
    this.isLooping = false,
  });

  QuranAudioState copyWith({
    List<Ayah>? ayahs,
    int? currentAyahIndex,
    bool? isPlaying,
    bool? isLoading,
    int? repeatCount,
    int? currentRepeat,
    int? Function()? loopStart,
    int? Function()? loopEnd,
    bool? isLooping,
  }) {
    return QuranAudioState(
      ayahs: ayahs ?? this.ayahs,
      currentAyahIndex: currentAyahIndex ?? this.currentAyahIndex,
      isPlaying: isPlaying ?? this.isPlaying,
      isLoading: isLoading ?? this.isLoading,
      repeatCount: repeatCount ?? this.repeatCount,
      currentRepeat: currentRepeat ?? this.currentRepeat,
      loopStart: loopStart != null ? loopStart() : this.loopStart,
      loopEnd: loopEnd != null ? loopEnd() : this.loopEnd,
      isLooping: isLooping ?? this.isLooping,
    );
  }
}

final quranAudioProvider =
    StateNotifierProvider<QuranAudioNotifier, QuranAudioState>((ref) {
  final notifier = QuranAudioNotifier();
  ref.onDispose(() => notifier.dispose());
  return notifier;
});

class QuranAudioNotifier extends StateNotifier<QuranAudioState> {
  final AudioPlayer _player = AudioPlayer();

  QuranAudioNotifier() : super(const QuranAudioState()) {
    _player.playerStateStream.listen((playerState) {
      if (!mounted) return;
      if (playerState.processingState == ProcessingState.completed) {
        _onAyahCompleted();
      }
    });
  }

  /// Load ayahs for a surah.
  void loadAyahs(List<Ayah> ayahs) {
    _player.stop();
    state = QuranAudioState(ayahs: ayahs);
  }

  /// Play a specific ayah by index.
  Future<void> playAyah(int index) async {
    if (index < 0 || index >= state.ayahs.length) return;
    final ayah = state.ayahs[index];
    if (ayah.audioUrl == null) return;

    state = state.copyWith(
      currentAyahIndex: index,
      isPlaying: true,
      isLoading: true,
      currentRepeat: 0,
    );

    try {
      final source = await _audioSource(ayah);
      await _player.setAudioSource(source);
      state = state.copyWith(isLoading: false);
      await _player.play();
    } catch (e) {
      debugPrint('Audio play error: $e');
      state = state.copyWith(isPlaying: false, isLoading: false);
    }
  }

  /// Toggle play/pause for the current ayah.
  Future<void> togglePlayPause() async {
    if (state.isPlaying) {
      await _player.pause();
      state = state.copyWith(isPlaying: false);
    } else if (state.currentAyahIndex >= 0) {
      await _player.play();
      state = state.copyWith(isPlaying: true);
    }
  }

  /// Stop playback and reset.
  Future<void> stop() async {
    await _player.stop();
    state = state.copyWith(
      isPlaying: false,
      isLoading: false,
      currentAyahIndex: -1,
      currentRepeat: 0,
    );
  }

  /// Play all ayahs starting from [startIndex].
  Future<void> playFrom(int startIndex) async {
    await playAyah(startIndex);
  }

  /// Set repeat count (0 = play once, 1 = repeat once, etc.).
  void setRepeatCount(int count) {
    state = state.copyWith(repeatCount: count);
  }

  /// Set loop range (inclusive start and end ayah indices).
  void setLoopRange(int start, int end) {
    state = state.copyWith(
      loopStart: () => start,
      loopEnd: () => end,
      isLooping: true,
    );
  }

  /// Clear loop range.
  void clearLoopRange() {
    state = state.copyWith(
      loopStart: () => null,
      loopEnd: () => null,
      isLooping: false,
    );
  }

  /// Skip to next ayah.
  Future<void> next() async {
    final nextIndex = state.currentAyahIndex + 1;
    if (nextIndex < state.ayahs.length) {
      await playAyah(nextIndex);
    } else {
      await stop();
    }
  }

  /// Skip to previous ayah.
  Future<void> previous() async {
    final prevIndex = state.currentAyahIndex - 1;
    if (prevIndex >= 0) {
      await playAyah(prevIndex);
    }
  }

  /// Called when an ayah finishes playing.
  Future<void> _onAyahCompleted() async {
    // Handle repeat
    if (state.currentRepeat < state.repeatCount) {
      state = state.copyWith(currentRepeat: state.currentRepeat + 1);
      await _player.seek(Duration.zero);
      await _player.play();
      return;
    }

    // Handle range loop
    if (state.isLooping && state.loopStart != null && state.loopEnd != null) {
      final nextIndex = state.currentAyahIndex + 1;
      if (nextIndex <= state.loopEnd!) {
        await playAyah(nextIndex);
      } else {
        // Loop back to start
        await playAyah(state.loopStart!);
      }
      return;
    }

    // Play next ayah
    await next();
  }

  /// Get the audio source for an ayah (local file if downloaded, else URL).
  Future<AudioSource> _audioSource(Ayah ayah) async {
    final localFile = await _localFilePath(ayah);
    if (localFile != null && await File(localFile).exists()) {
      return AudioSource.file(localFile);
    }
    return AudioSource.uri(Uri.parse(ayah.audioUrl!));
  }

  /// Get local file path for a downloaded ayah audio.
  Future<String?> _localFilePath(Ayah ayah) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/quran_audio/${ayah.number}.mp3');
      if (await file.exists()) return file.path;
    } catch (_) {}
    return null;
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}

/// Provider to check/manage downloaded audio for a surah.
final surahAudioDownloadProvider = StateNotifierProvider.family<
    SurahAudioDownloadNotifier, SurahDownloadState, int>((ref, surahNumber) {
  return SurahAudioDownloadNotifier(surahNumber);
});

class SurahDownloadState {
  final bool isDownloaded;
  final bool isDownloading;
  final double progress;

  const SurahDownloadState({
    this.isDownloaded = false,
    this.isDownloading = false,
    this.progress = 0,
  });

  SurahDownloadState copyWith({
    bool? isDownloaded,
    bool? isDownloading,
    double? progress,
  }) {
    return SurahDownloadState(
      isDownloaded: isDownloaded ?? this.isDownloaded,
      isDownloading: isDownloading ?? this.isDownloading,
      progress: progress ?? this.progress,
    );
  }
}

class SurahAudioDownloadNotifier extends StateNotifier<SurahDownloadState> {
  final int surahNumber;

  SurahAudioDownloadNotifier(this.surahNumber)
      : super(const SurahDownloadState()) {
    _checkDownloaded();
  }

  Future<void> _checkDownloaded() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final surahDir = Directory('${dir.path}/quran_audio');
      if (!await surahDir.exists()) return;
      // We consider it downloaded if the directory exists and has files
      // A more robust check would verify all ayah files exist
      state = state.copyWith(isDownloaded: false);
    } catch (_) {}
  }

  /// Download all ayah audio files for the surah.
  Future<void> download(List<Ayah> ayahs) async {
    if (state.isDownloading) return;
    state = state.copyWith(isDownloading: true, progress: 0);

    try {
      final dir = await getApplicationDocumentsDirectory();
      final audioDir = Directory('${dir.path}/quran_audio');
      if (!await audioDir.exists()) {
        await audioDir.create(recursive: true);
      }

      final client = HttpClient();
      for (var i = 0; i < ayahs.length; i++) {
        final ayah = ayahs[i];
        if (ayah.audioUrl == null) continue;

        final file = File('${audioDir.path}/${ayah.number}.mp3');
        if (await file.exists()) {
          state = state.copyWith(progress: (i + 1) / ayahs.length);
          continue;
        }

        final request = await client.getUrl(Uri.parse(ayah.audioUrl!));
        final response = await request.close();
        await response.pipe(file.openWrite());

        if (!mounted) return;
        state = state.copyWith(progress: (i + 1) / ayahs.length);
      }
      client.close();

      state = state.copyWith(isDownloaded: true, isDownloading: false);
    } catch (e) {
      debugPrint('Download error: $e');
      state = state.copyWith(isDownloading: false);
    }
  }
}
