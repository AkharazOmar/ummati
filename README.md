# Ummati

Application islamique Flutter — gratuite, sans publicite, open source.

## Fonctionnalites

### Horaires de priere
- Calcul base sur la geolocalisation (API Aladhan)
- 15 methodes de calcul dont **Maroc (Ministere des Habous)** et **UOIF (France)**
- Tableau mensuel sur 30 jours avec navigation par mois
- Affichage de la ville, date gregorienne et date hijri
- Prochaine priere mise en evidence avec compte a rebours
- **Widget Android** sur l'ecran d'accueil avec les 5 horaires, ville et date

### Coran
- Liste des 114 sourates
- Affichage verset par verset avec texte arabe
- Traduction dans la langue de l'utilisateur (francais, anglais)
- Marque-page avec sauvegarde et reprise de lecture

### Qibla
- Boussole avec calcul geodesique
- Indication de l'alignement avec la Qibla

### Notifications
- Son configurable par priere : desactive, bip, ou adhan
- Plusieurs adhans disponibles (Makkah, Madinah, Al-Aqsa, etc.)
- Ecoute de chaque adhan avant selection
- Delai configurable : a l'heure, 5/10/15/20/30 min avant
- Ajout dynamique d'adhans via le dossier `assets/sounds/adhan/`

### Parametres
- Multi-langue : Francais, English, Arabe (RTL)
- Localisation automatique (GPS) ou manuelle (45+ villes)
- Methode de calcul des horaires configurable

## Stack technique

| Composant | Choix |
|-----------|-------|
| Framework | Flutter 3.41+ / Dart |
| State management | Riverpod |
| Navigation | GoRouter |
| HTTP | Dio |
| Cache local | Hive |
| Notifications | flutter_local_notifications + timezone |
| Audio | just_audio |
| Localisation | geolocator + geocoding |
| Boussole | flutter_compass |
| Widget ecran d'accueil | home_widget |
| Polices | Amiri (arabe), Nunito (latin) |

## Demarrage rapide

### Prerequis
- Flutter 3.41+ (channel stable)
- Android SDK 36+ avec Java 17
- Pour iOS : macOS + Xcode

### Installation

```bash
# Cloner et installer les dependances
git clone <repo-url>
cd ummati
flutter pub get

# Lancer sur un appareil connecte
flutter run

# Construire un APK release
flutter build apk --release

# Construire pour iOS
flutter build ios --release --no-codesign
```

### Ajouter un adhan

1. Deposer le fichier MP3 dans `assets/sounds/adhan/` (ex: `mishary.mp3`)
2. Lancer le script de synchronisation :
   ```bash
   ./scripts/sync_adhan.sh
   ```
3. Le son apparait automatiquement dans les parametres de l'application

Le script genere `assets/data/adhan_list.json` et copie les fichiers dans `android/app/src/main/res/raw/` pour les notifications Android.

## Structure du projet

```
lib/
├── main.dart                 # Point d'entree, initialisation Hive
├── app/
│   ├── app.dart              # MaterialApp, theme, locales
│   ├── routes.dart           # GoRouter, navigation, onboarding
│   └── theme.dart            # Couleurs, typographie
├── core/
│   ├── models/               # PrayerTime, DailyPrayerTimes, Surah, Ayah
│   ├── services/
│   │   ├── prayer_api_service.dart    # API Aladhan + Quran
│   │   ├── location_service.dart      # GPS avec fallback
│   │   └── notification_service.dart  # zonedSchedule, sons custom
│   └── utils/
│       └── date_utils.dart   # Conversion hijri, formatage
├── features/
│   ├── onboarding/           # Ecran de permissions (localisation + notifications)
│   ├── prayer_times/         # Horaires du jour + tableau mensuel
│   ├── qibla/                # Boussole Qibla
│   ├── quran/                # Liste sourates, lecture, marque-page
│   └── settings/             # Langue, localisation, notifications, methode calcul
├── shared/
│   └── widgets/              # Bottom nav bar, Islamic card
└── l10n/                     # Traductions FR/EN/AR (.arb + genere)

assets/
├── data/                     # adhan_list.json, surahs.json
├── fonts/                    # Amiri, Nunito
├── images/
└── sounds/
    ├── beep.mp3              # Son de notification court
    └── adhan/                # Fichiers adhan (MP3)

scripts/
└── sync_adhan.sh             # Genere le manifeste adhan + sync Android raw

android/.../kotlin/
└── PrayerTimesWidget.kt      # AppWidgetProvider natif (Kotlin)

android/.../res/
├── layout/prayer_widget.xml  # Layout du widget ecran d'accueil
├── xml/prayer_widget_info.xml # Configuration du widget
└── drawable/widget_background.xml
```

## CI/CD

GitHub Actions (`.github/workflows/ci.yml`) :

```
analyze-and-test (ubuntu)
    ├── build-android (ubuntu)  → APK debug + artifact
    └── build-ios (macos)       → Build iOS (no codesign)
```

## APIs utilisees

- **[Aladhan](https://aladhan.com/prayer-times-api)** — Horaires de priere, calendrier mensuel, date hijri
- **[Al Quran Cloud](https://alquran.cloud/api)** — Texte arabe des sourates, traductions

## Licence

Ce projet est sous licence [GNU Affero General Public License v3.0](LICENSE).
