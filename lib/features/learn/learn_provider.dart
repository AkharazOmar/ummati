import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../settings/settings_provider.dart';

// --- Data models ---

class LearnLevel {
  final String id;
  final String titleEn;
  final String titleFr;
  final String titleAr;
  final String descEn;
  final String descFr;
  final String descAr;
  final String icon;
  final List<Lesson> lessons;

  const LearnLevel({
    required this.id,
    required this.titleEn,
    required this.titleFr,
    required this.titleAr,
    required this.descEn,
    required this.descFr,
    required this.descAr,
    required this.icon,
    required this.lessons,
  });

  String title(String locale) {
    switch (locale) {
      case 'fr':
        return titleFr;
      case 'ar':
        return titleAr;
      default:
        return titleEn;
    }
  }

  String desc(String locale) {
    switch (locale) {
      case 'fr':
        return descFr;
      case 'ar':
        return descAr;
      default:
        return descEn;
    }
  }

  factory LearnLevel.fromJson(Map<String, dynamic> json) {
    return LearnLevel(
      id: json['id'] as String,
      titleEn: json['titleEn'] as String,
      titleFr: json['titleFr'] as String,
      titleAr: json['titleAr'] as String,
      descEn: json['descEn'] as String,
      descFr: json['descFr'] as String,
      descAr: json['descAr'] as String,
      icon: json['icon'] as String,
      lessons: (json['lessons'] as List)
          .map((l) => Lesson.fromJson(l as Map<String, dynamic>))
          .toList(),
    );
  }
}

class Lesson {
  final String id;
  final String titleEn;
  final String titleFr;
  final String titleAr;
  final List<LessonItem> items;
  final List<QuizQuestion> quiz;

  const Lesson({
    required this.id,
    required this.titleEn,
    required this.titleFr,
    required this.titleAr,
    required this.items,
    required this.quiz,
  });

  String title(String locale) {
    switch (locale) {
      case 'fr':
        return titleFr;
      case 'ar':
        return titleAr;
      default:
        return titleEn;
    }
  }

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'] as String,
      titleEn: json['titleEn'] as String,
      titleFr: json['titleFr'] as String,
      titleAr: json['titleAr'] as String,
      items: (json['items'] as List)
          .map((i) => LessonItem.fromJson(i as Map<String, dynamic>))
          .toList(),
      quiz: (json['quiz'] as List)
          .map((q) => QuizQuestion.fromJson(q as Map<String, dynamic>))
          .toList(),
    );
  }
}

class LessonItem {
  final String letter;
  final String name;
  final String nameAr;
  final String phonetic;
  final String? isolated;
  final String? initial;
  final String? medial;
  final String? finalForm;
  final String example;
  final String exampleMeaning;
  final String exampleMeaningFr;
  final String audio;

  const LessonItem({
    required this.letter,
    required this.name,
    required this.nameAr,
    required this.phonetic,
    this.isolated,
    this.initial,
    this.medial,
    this.finalForm,
    required this.example,
    required this.exampleMeaning,
    required this.exampleMeaningFr,
    required this.audio,
  });

  String meaning(String locale) {
    return locale == 'fr' ? exampleMeaningFr : exampleMeaning;
  }

  factory LessonItem.fromJson(Map<String, dynamic> json) {
    return LessonItem(
      letter: json['letter'] as String,
      name: json['name'] as String,
      nameAr: json['nameAr'] as String,
      phonetic: json['phonetic'] as String,
      isolated: json['isolated'] as String?,
      initial: json['initial'] as String?,
      medial: json['medial'] as String?,
      finalForm: json['final'] as String?,
      example: json['example'] as String,
      exampleMeaning: json['exampleMeaning'] as String,
      exampleMeaningFr: json['exampleMeaningFr'] as String,
      audio: json['audio'] as String,
    );
  }
}

class QuizQuestion {
  final String type;
  final String question;
  final List<String> options;
  final int answer;

  const QuizQuestion({
    required this.type,
    required this.question,
    required this.options,
    required this.answer,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      type: json['type'] as String,
      question: json['question'] as String,
      options:
          (json['options'] as List).map((o) => o as String).toList(),
      answer: json['answer'] as int,
    );
  }
}

// --- Providers ---

/// Loads all learning levels from JSON asset.
final learnLevelsProvider = FutureProvider<List<LearnLevel>>((ref) async {
  final jsonStr =
      await rootBundle.loadString('assets/data/learn_arabic.json');
  final data = json.decode(jsonStr) as Map<String, dynamic>;
  final levels = (data['levels'] as List)
      .map((l) => LearnLevel.fromJson(l as Map<String, dynamic>))
      .toList();
  return levels;
});

/// Tracks lesson completion progress in Hive.
final learnProgressProvider =
    StateNotifierProvider<LearnProgressNotifier, Map<String, bool>>((ref) {
  final box = ref.read(settingsBoxProvider);
  return LearnProgressNotifier(box);
});

class LearnProgressNotifier extends StateNotifier<Map<String, bool>> {
  final Box _box;

  LearnProgressNotifier(this._box) : super(_load(_box));

  static Map<String, bool> _load(Box box) {
    final raw = box.get('learnProgress');
    if (raw is Map) {
      return Map<String, bool>.from(raw);
    }
    return {};
  }

  bool isCompleted(String lessonId) => state[lessonId] == true;

  void complete(String lessonId) {
    state = {...state, lessonId: true};
    _box.put('learnProgress', state);
  }

  /// Check if a level is unlocked (previous level's lessons all completed,
  /// or it's the first level).
  bool isLevelUnlocked(List<LearnLevel> levels, int levelIndex) {
    if (levelIndex == 0) return true;
    final prevLevel = levels[levelIndex - 1];
    return prevLevel.lessons.every((l) => isCompleted(l.id));
  }

  /// Check if a lesson is unlocked within a level.
  bool isLessonUnlocked(LearnLevel level, int lessonIndex) {
    if (lessonIndex == 0) return true;
    return isCompleted(level.lessons[lessonIndex - 1].id);
  }
}

/// TTS provider for Arabic pronunciation.
final arabicTtsProvider = Provider<FlutterTts>((ref) {
  final tts = FlutterTts();
  tts.setLanguage('ar');
  tts.setSpeechRate(0.4);
  tts.setPitch(1.0);
  ref.onDispose(() => tts.stop());
  return tts;
});
