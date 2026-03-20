import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const _calculationMethods = {
    1: 'University of Islamic Sciences, Karachi',
    2: 'Islamic Society of North America (ISNA)',
    3: 'Muslim World League (MWL)',
    4: 'Umm Al-Qura University, Makkah',
    5: 'Egyptian General Authority of Survey',
    7: 'Institute of Geophysics, University of Tehran',
    8: 'Gulf Region',
    9: 'Kuwait',
    10: 'Qatar',
    11: 'Majlis Ugama Islam Singapura',
    12: 'Union Organization Islamic de France',
    13: 'Diyanet İşleri Başkanlığı, Turkey',
    14: 'Spiritual Administration of Muslims of Russia',
    15: 'Moonsighting Committee Worldwide',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider);
    final notificationsEnabled = ref.watch(notificationsEnabledProvider);
    final calculationMethod = ref.watch(calculationMethodProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // --- Language ---
          _SectionHeader(title: l10n.language),
          _LanguageTile(
            label: 'Français',
            flag: '🇫🇷',
            selected: locale.languageCode == 'fr',
            onTap: () =>
                ref.read(localeProvider.notifier).setLocale('fr'),
          ),
          _LanguageTile(
            label: 'English',
            flag: '🇬🇧',
            selected: locale.languageCode == 'en',
            onTap: () =>
                ref.read(localeProvider.notifier).setLocale('en'),
          ),
          _LanguageTile(
            label: 'العربية',
            flag: '🇸🇦',
            selected: locale.languageCode == 'ar',
            onTap: () =>
                ref.read(localeProvider.notifier).setLocale('ar'),
          ),
          const Divider(),

          // --- Notifications ---
          _SectionHeader(title: l10n.notifications),
          SwitchListTile(
            title: Text(l10n.prayerNotifications),
            subtitle: Text(l10n.prayerNotificationsDesc),
            value: notificationsEnabled,
            activeColor: Theme.of(context).colorScheme.primary,
            onChanged: (_) =>
                ref.read(notificationsEnabledProvider.notifier).toggle(),
          ),
          const Divider(),

          // --- Calculation Method ---
          _SectionHeader(title: l10n.calculationMethod),
          ..._calculationMethods.entries.map(
            (entry) => RadioListTile<int>(
              title: Text(
                entry.value,
                style: const TextStyle(fontSize: 14),
              ),
              value: entry.key,
              groupValue: calculationMethod,
              activeColor: Theme.of(context).colorScheme.primary,
              onChanged: (value) {
                if (value != null) {
                  ref
                      .read(calculationMethodProvider.notifier)
                      .setMethod(value);
                }
              },
            ),
          ),
          const Divider(),

          // --- About ---
          _SectionHeader(title: l10n.about),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Ummati'),
            subtitle: Text(l10n.aboutDesc),
          ),
          ListTile(
            leading: const Icon(Icons.code),
            title: Text(l10n.version('1.0.0')),
            subtitle: const Text('1.0.0'),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final String label;
  final String flag;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageTile({
    required this.label,
    required this.flag,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Text(flag, style: const TextStyle(fontSize: 24)),
      title: Text(label),
      trailing: selected
          ? Icon(Icons.check_circle,
              color: Theme.of(context).colorScheme.primary)
          : null,
      onTap: onTap,
    );
  }
}
