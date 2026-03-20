import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../app/theme.dart';
import 'quran_provider.dart';

class SurahScreen extends ConsumerWidget {
  final int surahNumber;
  final String surahName;

  const SurahScreen({
    super.key,
    required this.surahNumber,
    required this.surahName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final ayahsAsync = ref.watch(surahAyahsProvider(surahNumber));

    return Scaffold(
      appBar: AppBar(
        title: Text(surahName),
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
                onPressed: () =>
                    ref.invalidate(surahAyahsProvider(surahNumber)),
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
        data: (ayahs) => ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Bismillah header (except for Surah At-Tawbah)
            if (surahNumber != 9) ...[
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Text(
                    l10n.bismillah,
                    style: TextStyle(
                      fontFamily: UmmatiTheme.fontFamilyArabic,
                      fontSize: 22,
                      color: UmmatiTheme.accentGold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],

            // Ayahs displayed as rich text
            Directionality(
              textDirection: TextDirection.rtl,
              child: RichText(
                textAlign: TextAlign.justify,
                text: TextSpan(
                  style: TextStyle(
                    fontFamily: UmmatiTheme.fontFamilyArabic,
                    fontSize: 26,
                    height: 2.2,
                    color: UmmatiTheme.darkText,
                  ),
                  children: ayahs.map((ayah) {
                    return TextSpan(
                      children: [
                        TextSpan(text: ayah.text),
                        TextSpan(
                          text: ' \uFD3F${_toArabicNumber(ayah.numberInSurah)}\uFD3E ',
                          style: TextStyle(
                            color: UmmatiTheme.primaryGreen,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _toArabicNumber(int number) {
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return number
        .toString()
        .split('')
        .map((d) => arabicDigits[int.parse(d)])
        .join();
  }
}
