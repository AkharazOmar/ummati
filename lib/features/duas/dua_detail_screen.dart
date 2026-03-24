import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../core/models/dua.dart';
import '../settings/settings_provider.dart';

class DuaDetailScreen extends ConsumerWidget {
  final DuaCategory category;

  const DuaDetailScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider).languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          category.title(locale),
          style: const TextStyle(fontSize: 16),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: category.duas.length,
        itemBuilder: (context, index) {
          final dua = category.duas[index];
          final translation = dua.translation(locale);
          return Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: index.isEven
                  ? UmmatiTheme.primaryGreen.withValues(alpha: 0.03)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: UmmatiTheme.primaryGreen.withValues(alpha: 0.1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Dua number
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color:
                            UmmatiTheme.primaryGreen.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
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
                const SizedBox(height: 16),

                // Arabic text
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: Text(
                    dua.arabic,
                    style: const TextStyle(
                      fontFamily: UmmatiTheme.fontFamilyArabic,
                      fontSize: 22,
                      height: 2.0,
                      color: UmmatiTheme.darkText,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),

                // Phonetic transliteration
                if (dua.phonetic.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    dua.phonetic,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      fontStyle: FontStyle.italic,
                      color: UmmatiTheme.primaryGreen.withValues(alpha: 0.7),
                    ),
                  ),
                ],

                // Translation (hidden for Arabic users)
                if (translation != null) ...[
                  const SizedBox(height: 14),
                  const Divider(height: 1),
                  const SizedBox(height: 14),
                  Text(
                    translation,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: UmmatiTheme.darkText.withValues(alpha: 0.7),
                    ),
                  ),
                ],

                // Reference
                if (dua.reference.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    dua.reference,
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: UmmatiTheme.accentGold.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
