import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../app/theme.dart';
import '../../core/models/surah.dart';
import 'quran_provider.dart';

class QuranScreen extends ConsumerWidget {
  const QuranScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final surahListAsync = ref.watch(surahListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.surahList),
      ),
      body: surahListAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(l10n.errorLoading),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(surahListProvider),
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
        data: (surahs) => _SurahListView(surahs: surahs),
      ),
    );
  }
}

class _SurahListView extends StatelessWidget {
  final List<Surah> surahs;

  const _SurahListView({required this.surahs});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: surahs.length,
      separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
      itemBuilder: (context, index) {
        final surah = surahs[index];

        return ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: UmmatiTheme.primaryGreen.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${surah.number}',
                style: const TextStyle(
                  color: UmmatiTheme.primaryGreen,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      surah.nameEnglish,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      '${surah.nameTranslation} — ${l10n.verses(surah.versesCount)}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              Text(
                surah.nameArabic,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontFamily: UmmatiTheme.fontFamilyArabic,
                      color: UmmatiTheme.primaryGreen,
                    ),
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              surah.isMeccan ? l10n.meccan : l10n.medinan,
              style: TextStyle(
                fontSize: 12,
                color: UmmatiTheme.accentGold,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          onTap: () {
            context.go(
              '/quran/surah/${surah.number}?name=${Uri.encodeComponent(surah.nameEnglish)}',
            );
          },
        );
      },
    );
  }
}
