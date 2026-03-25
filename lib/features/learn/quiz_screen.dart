import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../l10n/app_localizations.dart';
import 'learn_provider.dart';

class QuizScreen extends ConsumerStatefulWidget {
  final String levelId;
  final String lessonId;
  final String quizTitle;

  const QuizScreen({
    super.key,
    required this.levelId,
    required this.lessonId,
    required this.quizTitle,
  });

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  int _currentIndex = 0;
  int _score = 0;
  int? _selectedAnswer;
  bool _answered = false;
  List<QuizQuestion> _questions = [];

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  void _loadQuestions() {
    final levels = ref.read(learnLevelsProvider).valueOrNull;
    if (levels == null) return;
    final level = levels.firstWhere((l) => l.id == widget.levelId);
    final lesson = level.lessons.firstWhere((l) => l.id == widget.lessonId);
    setState(() {
      _questions = List.from(lesson.quiz)..shuffle();
    });
  }

  void _selectAnswer(int index) {
    if (_answered) return;
    setState(() {
      _selectedAnswer = index;
      _answered = true;
      if (index == _questions[_currentIndex].answer) {
        _score++;
      }
    });
  }

  void _nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedAnswer = null;
        _answered = false;
      });
    } else {
      _showResults();
    }
  }

  void _showResults() {
    final l10n = AppLocalizations.of(context)!;
    final passed = _score >= (_questions.length * 0.7).ceil();

    if (passed) {
      ref.read(learnProgressProvider.notifier).complete(widget.lessonId);
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          passed ? l10n.quizPassed : l10n.quizFailed,
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              passed ? Icons.emoji_events : Icons.refresh,
              size: 64,
              color: passed ? UmmatiTheme.accentGold : UmmatiTheme.lightText,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.quizScore(_score, _questions.length),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              passed ? l10n.quizPassedDesc : l10n.quizFailedDesc,
              textAlign: TextAlign.center,
              style: const TextStyle(color: UmmatiTheme.lightText),
            ),
          ],
        ),
        actions: [
          if (!passed)
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                setState(() {
                  _currentIndex = 0;
                  _score = 0;
                  _selectedAnswer = null;
                  _answered = false;
                  _questions.shuffle();
                });
              },
              child: Text(l10n.retry),
            ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              // Go back to level screen
              context.go(
                  '/learn/level/${widget.levelId}?title=${Uri.encodeComponent(widget.quizTitle)}');
            },
            child: Text(passed ? l10n.continueText : l10n.back),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.quiz)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final question = _questions[_currentIndex];
    final progress = (_currentIndex + 1) / _questions.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.quiz),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                '${_currentIndex + 1}/${_questions.length}',
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey.shade200,
                  color: UmmatiTheme.primaryGreen,
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 32),

              // Question
              Text(
                l10n.identifyThis,
                style: const TextStyle(
                  fontSize: 16,
                  color: UmmatiTheme.lightText,
                ),
              ),
              const SizedBox(height: 16),
              Directionality(
                textDirection: TextDirection.rtl,
                child: Text(
                  question.question,
                  style: const TextStyle(
                    fontFamily: UmmatiTheme.fontFamilyArabic,
                    fontSize: 64,
                    color: UmmatiTheme.darkText,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Options
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 2.5,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: List.generate(question.options.length, (i) {
                    final isCorrect = i == question.answer;
                    final isSelected = _selectedAnswer == i;

                    Color bgColor;
                    Color borderColor;
                    Color textColor;

                    if (!_answered) {
                      bgColor = Colors.white;
                      borderColor = Colors.grey.shade300;
                      textColor = UmmatiTheme.darkText;
                    } else if (isCorrect) {
                      bgColor = Colors.green.shade50;
                      borderColor = Colors.green;
                      textColor = Colors.green.shade800;
                    } else if (isSelected) {
                      bgColor = Colors.red.shade50;
                      borderColor = Colors.red;
                      textColor = Colors.red.shade800;
                    } else {
                      bgColor = Colors.grey.shade50;
                      borderColor = Colors.grey.shade200;
                      textColor = Colors.grey.shade400;
                    }

                    return GestureDetector(
                      onTap: () => _selectAnswer(i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: borderColor, width: 2),
                        ),
                        child: Center(
                          child: Text(
                            question.options[i],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),

              // Next button
              if (_answered)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _nextQuestion,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      _currentIndex < _questions.length - 1
                          ? l10n.nextQuestion
                          : l10n.seeResults,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
