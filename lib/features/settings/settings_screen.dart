import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import '../../app/theme.dart';
import '../../core/services/notification_service.dart';
import '../../l10n/app_localizations.dart';
import 'settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const _calculationMethods = {
    99: '🇲🇦 Maroc (Ministère des Habous)',
    12: '🇫🇷 Union Organization Islamic de France',
    4: '🇸🇦 Umm Al-Qura University, Makkah',
    5: '🇪🇬 Egyptian General Authority of Survey',
    3: 'Muslim World League (MWL)',
    2: 'Islamic Society of North America (ISNA)',
    1: 'University of Islamic Sciences, Karachi',
    7: 'Institute of Geophysics, University of Tehran',
    8: 'Gulf Region',
    9: 'Kuwait',
    10: 'Qatar',
    11: 'Majlis Ugama Islam Singapura',
    13: 'Diyanet İşleri Başkanlığı, Turkey',
    14: 'Spiritual Administration of Muslims of Russia',
    15: 'Moonsighting Committee Worldwide',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider);
    final notifSettings = ref.watch(prayerNotificationSettingsProvider);
    final notifOffsets = ref.watch(prayerNotificationOffsetsProvider);
    final availableSounds = ref.watch(availableSoundsProvider);
    final calculationMethod = ref.watch(calculationMethodProvider);
    final locationMode = ref.watch(locationModeProvider);
    final manualLocation = ref.watch(manualLocationProvider);

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
            onTap: () => ref.read(localeProvider.notifier).setLocale('fr'),
          ),
          _LanguageTile(
            label: 'English',
            flag: '🇬🇧',
            selected: locale.languageCode == 'en',
            onTap: () => ref.read(localeProvider.notifier).setLocale('en'),
          ),
          _LanguageTile(
            label: 'العربية',
            flag: '🇸🇦',
            selected: locale.languageCode == 'ar',
            onTap: () => ref.read(localeProvider.notifier).setLocale('ar'),
          ),
          const Divider(),

          // --- Location ---
          _SectionHeader(title: l10n.location),
          RadioListTile<String>(
            title: Text(l10n.locationAuto),
            subtitle: Text(l10n.locationAutoDesc),
            value: 'auto',
            groupValue: locationMode,
            activeColor: Theme.of(context).colorScheme.primary,
            onChanged: (value) {
              if (value != null) {
                ref.read(locationModeProvider.notifier).setMode(value);
              }
            },
          ),
          RadioListTile<String>(
            title: Text(l10n.locationManual),
            subtitle: Text(l10n.locationManualDesc),
            value: 'manual',
            groupValue: locationMode,
            activeColor: Theme.of(context).colorScheme.primary,
            onChanged: (value) {
              if (value != null) {
                ref.read(locationModeProvider.notifier).setMode(value);
              }
            },
          ),
          if (locationMode == 'manual') ...[
            ListTile(
              leading: const Icon(Icons.location_city),
              title: Text(manualLocation != null
                  ? l10n.currentCity(manualLocation.cityName)
                  : l10n.noCitySelected),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showCityPicker(context, ref, l10n),
            ),
          ],
          const Divider(),

          // --- Notifications ---
          _SectionHeader(title: l10n.notifications),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              l10n.prayerNotificationsDesc,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          ...prayerKeys.map((prayer) {
            final soundId = notifSettings[prayer] ?? 'adhan_makkah';
            final offset = notifOffsets[prayer] ?? 0;
            final sounds = availableSounds.valueOrNull ?? [];
            return _PrayerNotificationTile(
              prayerName: _localizedPrayerName(l10n, prayer),
              soundId: soundId,
              offsetMinutes: offset,
              sounds: sounds,
              onSoundChanged: (newSoundId) {
                ref
                    .read(prayerNotificationSettingsProvider.notifier)
                    .setSound(prayer, newSoundId);
              },
              onOffsetChanged: (newOffset) {
                ref
                    .read(prayerNotificationOffsetsProvider.notifier)
                    .setOffset(prayer, newOffset);
              },
            );
          }),
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
                  ref.read(calculationMethodProvider.notifier).setMethod(value);
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
          // --- Debug (only in debug mode) ---
          if (kDebugMode) ...[
            const Divider(),
            _SectionHeader(title: 'Debug'),
            ListTile(
              leading: Icon(Icons.notifications_active, color: Colors.orange),
              title: const Text('Test notification (immediate)'),
              subtitle: const Text('Send a test prayer notification now'),
              onTap: () async {
                final notifSettings = ref.read(prayerNotificationSettingsProvider);
                final soundId = notifSettings['Maghrib'] ?? 'adhan_makkah';
                final sound = soundById(soundId);

                final service = NotificationService();
                await service.initialize();
                await service.showTestNotification(sound: sound);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notification envoyee')),
                  );
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.timer, color: Colors.orange),
              title: const Text('Test notification (10s)'),
              subtitle: const Text('Via background service delayed show()'),
              onTap: () async {
                final notifSettings = ref.read(prayerNotificationSettingsProvider);
                final soundId = notifSettings['Maghrib'] ?? 'adhan_makkah';
                final sound = soundById(soundId);

                final service = NotificationService();
                await service.initialize();
                Future.delayed(const Duration(seconds: 10), () {
                  service.showTestNotification(sound: sound);
                });

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notification dans 10 secondes...')),
                  );
                }
              },
            ),
          ],

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  String _localizedPrayerName(AppLocalizations l10n, String name) {
    switch (name) {
      case 'Fajr':
        return l10n.fajr;
      case 'Dhuhr':
        return l10n.dhuhr;
      case 'Asr':
        return l10n.asr;
      case 'Maghrib':
        return l10n.maghrib;
      case 'Isha':
        return l10n.isha;
      default:
        return name;
    }
  }

  void _showCityPicker(
      BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _CityPickerSheet(
        l10n: l10n,
        onCitySelected: (city) {
          ref.read(manualLocationProvider.notifier).setLocation(
                city.name,
                city.latitude,
                city.longitude,
              );
          Navigator.pop(context);
        },
      ),
    );
  }
}

class _City {
  final String name;
  final String country;
  final double latitude;
  final double longitude;

  const _City(this.name, this.country, this.latitude, this.longitude);
}

const _cities = [
  // France
  _City('Paris', '🇫🇷', 48.8566, 2.3522),
  _City('Lyon', '🇫🇷', 45.7640, 4.8357),
  _City('Marseille', '🇫🇷', 43.2965, 5.3698),
  _City('Toulouse', '🇫🇷', 43.6047, 1.4442),
  _City('Strasbourg', '🇫🇷', 48.5734, 7.7521),
  _City('Lille', '🇫🇷', 50.6292, 3.0573),
  _City('Bordeaux', '🇫🇷', 44.8378, -0.5792),
  _City('Nice', '🇫🇷', 43.7102, 7.2620),
  _City('Nantes', '🇫🇷', 47.2184, -1.5536),
  _City('Montpellier', '🇫🇷', 43.6108, 3.8767),
  // Maghreb
  _City('Casablanca', '🇲🇦', 33.5731, -7.5898),
  _City('Rabat', '🇲🇦', 34.0209, -6.8416),
  _City('Marrakech', '🇲🇦', 31.6295, -7.9811),
  _City('Fès', '🇲🇦', 34.0331, -5.0003),
  _City('Tanger', '🇲🇦', 35.7595, -5.8340),
  _City('Alger', '🇩🇿', 36.7538, 3.0588),
  _City('Oran', '🇩🇿', 35.6969, -0.6331),
  _City('Constantine', '🇩🇿', 36.3650, 6.6147),
  _City('Tunis', '🇹🇳', 36.8065, 10.1815),
  _City('Sfax', '🇹🇳', 34.7406, 10.7603),
  // Moyen-Orient
  _City('La Mecque', '🇸🇦', 21.3891, 39.8579),
  _City('Médine', '🇸🇦', 24.4539, 39.6142),
  _City('Riyad', '🇸🇦', 24.7136, 46.6753),
  _City('Djeddah', '🇸🇦', 21.5433, 39.1728),
  _City('Dubaï', '🇦🇪', 25.2048, 55.2708),
  _City('Abu Dhabi', '🇦🇪', 24.4539, 54.3773),
  _City('Doha', '🇶🇦', 25.2854, 51.5310),
  _City('Koweït', '🇰🇼', 29.3759, 47.9774),
  _City('Istanbul', '🇹🇷', 41.0082, 28.9784),
  _City('Ankara', '🇹🇷', 39.9334, 32.8597),
  _City('Le Caire', '🇪🇬', 30.0444, 31.2357),
  _City('Alexandrie', '🇪🇬', 31.2001, 29.9187),
  _City('Beyrouth', '🇱🇧', 33.8938, 35.5018),
  _City('Amman', '🇯🇴', 31.9454, 35.9284),
  _City('Bagdad', '🇮🇶', 33.3152, 44.3661),
  // Afrique
  _City('Dakar', '🇸🇳', 14.7167, -17.4677),
  _City('Abidjan', '🇨🇮', 5.3600, -4.0083),
  _City('Bamako', '🇲🇱', 12.6392, -8.0029),
  _City('Nouakchott', '🇲🇷', 18.0735, -15.9582),
  _City('Niamey', '🇳🇪', 13.5127, 2.1128),
  // Europe
  _City('Londres', '🇬🇧', 51.5074, -0.1278),
  _City('Bruxelles', '🇧🇪', 50.8503, 4.3517),
  _City('Berlin', '🇩🇪', 52.5200, 13.4050),
  _City('Amsterdam', '🇳🇱', 52.3676, 4.9041),
  _City('Genève', '🇨🇭', 46.2044, 6.1432),
  // Amérique
  _City('New York', '🇺🇸', 40.7128, -74.0060),
  _City('Montréal', '🇨🇦', 45.5017, -73.5673),
  _City('Toronto', '🇨🇦', 43.6532, -79.3832),
  // Asie
  _City('Jakarta', '🇮🇩', -6.2088, 106.8456),
  _City('Kuala Lumpur', '🇲🇾', 3.1390, 101.6869),
  _City('Islamabad', '🇵🇰', 33.6844, 73.0479),
  _City('Karachi', '🇵🇰', 24.8607, 67.0011),
  _City('Dhaka', '🇧🇩', 23.8103, 90.4125),
];

class _CityPickerSheet extends StatefulWidget {
  final AppLocalizations l10n;
  final ValueChanged<_City> onCitySelected;

  const _CityPickerSheet({
    required this.l10n,
    required this.onCitySelected,
  });

  @override
  State<_CityPickerSheet> createState() => _CityPickerSheetState();
}

class _CityPickerSheetState extends State<_CityPickerSheet> {
  String _search = '';

  List<_City> get _filteredCities {
    if (_search.isEmpty) return _cities;
    final query = _search.toLowerCase();
    return _cities
        .where((c) =>
            c.name.toLowerCase().contains(query) ||
            c.country.toLowerCase().contains(query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredCities;
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) => Column(
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              widget.l10n.selectCity,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              autofocus: true,
              decoration: InputDecoration(
                hintText: widget.l10n.searchCity,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: (value) => setState(() => _search = value),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final city = filtered[index];
                return ListTile(
                  leading: Text(city.country,
                      style: const TextStyle(fontSize: 24)),
                  title: Text(city.name),
                  onTap: () => widget.onCitySelected(city),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PrayerNotificationTile extends StatelessWidget {
  final String prayerName;
  final String soundId;
  final int offsetMinutes;
  final List<NotificationSound> sounds;
  final ValueChanged<String> onSoundChanged;
  final ValueChanged<int> onOffsetChanged;

  const _PrayerNotificationTile({
    required this.prayerName,
    required this.soundId,
    required this.offsetMinutes,
    required this.sounds,
    required this.onSoundChanged,
    required this.onOffsetChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final sound = soundById(soundId, sounds);
    final soundLabel = _displayLabel(l10n, sound);
    final offsetLabel = offsetMinutes == 0
        ? l10n.atPrayerTime
        : l10n.minutesBefore(offsetMinutes);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      title: Text(prayerName),
      subtitle: Text(
        sound.isSilent ? soundLabel : '$soundLabel · $offsetLabel',
        style: TextStyle(
          color: sound.isSilent
              ? UmmatiTheme.darkText.withValues(alpha: 0.4)
              : UmmatiTheme.primaryGreen,
          fontSize: 13,
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          builder: (ctx) => _SoundPickerSheet(
            currentSoundId: soundId,
            currentOffset: offsetMinutes,
            prayerName: prayerName,
            sounds: sounds,
            onSelected: (id) {
              onSoundChanged(id);
              Navigator.pop(ctx);
            },
            onOffsetChanged: (offset) {
              onOffsetChanged(offset);
            },
          ),
        );
      },
    );
  }

  /// Display label: use l10n for fixed sounds, displayName for adhans.
  static String _displayLabel(AppLocalizations l10n, NotificationSound sound) {
    if (sound.id == 'none') return l10n.notifOff;
    if (sound.id == 'beep') return l10n.notifBeep;
    if (sound.isAdhan) return '🕌 ${sound.displayName}';
    return sound.displayName;
  }
}

class _SoundPickerSheet extends StatefulWidget {
  final String currentSoundId;
  final int currentOffset;
  final String prayerName;
  final List<NotificationSound> sounds;
  final ValueChanged<String> onSelected;
  final ValueChanged<int> onOffsetChanged;

  const _SoundPickerSheet({
    required this.currentSoundId,
    required this.currentOffset,
    required this.prayerName,
    required this.sounds,
    required this.onSelected,
    required this.onOffsetChanged,
  });

  @override
  State<_SoundPickerSheet> createState() => _SoundPickerSheetState();
}

class _SoundPickerSheetState extends State<_SoundPickerSheet> {
  final AudioPlayer _player = AudioPlayer();
  String? _playingSoundId;
  late int _selectedOffset;

  @override
  void initState() {
    super.initState();
    _selectedOffset = widget.currentOffset;
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _playPreview(NotificationSound sound) async {
    if (sound.assetPath == null) return;

    if (_playingSoundId == sound.id) {
      await _player.stop();
      setState(() => _playingSoundId = null);
      return;
    }

    setState(() => _playingSoundId = sound.id);
    try {
      await _player.setAsset(sound.assetPath!);
      await _player.play();
      _player.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          if (mounted) setState(() => _playingSoundId = null);
        }
      });
    } catch (_) {
      if (mounted) setState(() => _playingSoundId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Separate fixed sounds and adhans
    final fixedSounds = widget.sounds.where((s) => !s.isAdhan).toList();
    final adhanSounds = widget.sounds.where((s) => s.isAdhan).toList();

    return SafeArea(
      child: DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.8,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                widget.prayerName,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Expanded(
              child: ListView(
                controller: scrollController,
                children: [
                  // Fixed sounds (Off, Beep)
                  ...fixedSounds.map((sound) => _buildSoundTile(l10n, sound)),

                  // Adhan section
                  if (adhanSounds.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text(
                        l10n.notifAdhanSection,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: UmmatiTheme.primaryGreen,
                        ),
                      ),
                    ),
                    ...adhanSounds
                        .map((sound) => _buildSoundTile(l10n, sound)),
                  ],

                  // Offset selector
                  if (widget.currentSoundId != 'none') ...[
                    const Divider(height: 24),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: Text(
                        l10n.notifyBefore,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: UmmatiTheme.primaryGreen,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Wrap(
                        spacing: 8,
                        children: notificationOffsetOptions.map((minutes) {
                          final isSelected = _selectedOffset == minutes;
                          final label = minutes == 0
                              ? l10n.atPrayerTime
                              : l10n.minutesBefore(minutes);
                          return ChoiceChip(
                            label: Text(label),
                            selected: isSelected,
                            selectedColor: UmmatiTheme.primaryGreen,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : UmmatiTheme.darkText,
                              fontSize: 13,
                            ),
                            onSelected: (_) {
                              setState(() => _selectedOffset = minutes);
                              widget.onOffsetChanged(minutes);
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSoundTile(AppLocalizations l10n, NotificationSound sound) {
    final isSelected = sound.id == widget.currentSoundId;
    final isPlaying = _playingSoundId == sound.id;
    final label = _PrayerNotificationTile._displayLabel(l10n, sound);

    return ListTile(
      leading: sound.assetPath != null
          ? IconButton(
              icon: Icon(
                isPlaying ? Icons.stop_circle : Icons.play_circle,
                color: UmmatiTheme.primaryGreen,
                size: 32,
              ),
              onPressed: () => _playPreview(sound),
            )
          : const SizedBox(
              width: 48,
              child: Icon(Icons.notifications_off, color: Colors.grey),
            ),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: UmmatiTheme.primaryGreen)
          : null,
      onTap: () {
        _player.stop();
        widget.onSelected(sound.id);
      },
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
