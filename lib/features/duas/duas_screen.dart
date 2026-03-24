import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../core/models/dua.dart';
import '../../l10n/app_localizations.dart';
import '../settings/settings_provider.dart';
import 'duas_provider.dart';
import 'dua_detail_screen.dart';

class DuasScreen extends ConsumerWidget {
  const DuasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final categoriesAsync = ref.watch(duaCategoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.duas),
      ),
      body: categoriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(l10n.errorLoading),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(duaCategoriesProvider),
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
        data: (categories) => _CategoriesListView(
          categories: categories,
          locale: ref.watch(localeProvider).languageCode,
        ),
      ),
    );
  }
}

class _CategoriesListView extends StatefulWidget {
  final List<DuaCategory> categories;
  final String locale;

  const _CategoriesListView({
    required this.categories,
    required this.locale,
  });

  @override
  State<_CategoriesListView> createState() => _CategoriesListViewState();
}

class _CategoriesListViewState extends State<_CategoriesListView> {
  String _search = '';

  List<DuaCategory> get _filtered {
    if (_search.isEmpty) return widget.categories;
    final query = _search.toLowerCase();
    return widget.categories
        .where((c) =>
            c.title(widget.locale).toLowerCase().contains(query) ||
            c.titleEn.toLowerCase().contains(query) ||
            c.titleAr.contains(query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final filtered = _filtered;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: TextField(
            decoration: InputDecoration(
              hintText: l10n.searchDuas,
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            onChanged: (value) => setState(() => _search = value),
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 4),
            itemCount: filtered.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, indent: 16, endIndent: 16),
            itemBuilder: (context, index) {
              final category = filtered[index];
              return ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: UmmatiTheme.primaryGreen.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.menu_book,
                    color: UmmatiTheme.primaryGreen,
                    size: 20,
                  ),
                ),
                title: Text(
                  category.title(widget.locale),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                subtitle: Text(
                  '${category.duas.length} ${category.duas.length > 1 ? 'duas' : 'dua'}',
                  style: TextStyle(
                    fontSize: 12,
                    color: UmmatiTheme.darkText.withValues(alpha: 0.5),
                  ),
                ),
                trailing: const Icon(Icons.chevron_right, size: 20),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => DuaDetailScreen(category: category),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
