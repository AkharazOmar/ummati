# 🕌 Ummati

Application islamique Flutter — gratuite, sans publicité.

## Features V1

- **Horaires de prière** — basés sur la géolocalisation (API Aladhan)
- **Qibla** — boussole avec calcul géodésique offline
- **Coran** — Juz' Amma bundlé offline, reste via quran.com API
- **Notifications** — rappels pour chaque prière
- **Multi-langue** — Français, English, العربية (RTL)

## Stack

| Composant | Choix |
|-----------|-------|
| Framework | Flutter / Dart |
| State | Riverpod |
| Navigation | GoRouter |
| HTTP | Dio |
| Cache | Hive |
| Notifications | flutter_local_notifications |

## Setup

```bash
flutter pub get
flutter run
```

## Structure

```
lib/
├── main.dart
├── app/          # App, routes, theme
├── core/         # Services, models, utils
├── features/     # Prayer times, Qibla, Quran, Settings
├── shared/       # Widgets réutilisables
└── l10n/         # Traductions (FR/EN/AR)
```

## Licence

À définir.
