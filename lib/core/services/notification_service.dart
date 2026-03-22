import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;

import '../../features/settings/settings_provider.dart';

@pragma('vm:entry-point')
void _onBackgroundNotificationResponse(NotificationResponse response) {}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {},
      onDidReceiveBackgroundNotificationResponse:
          _onBackgroundNotificationResponse,
    );

    // Request notification permission on Android 13+
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
    }

    _initialized = true;
  }

  /// Schedule a prayer notification using Future.delayed + show().
  Future<void> schedulePrayerNotification({
    required int id,
    required String prayerName,
    required DateTime scheduledTime,
    required NotificationSound sound,
  }) async {
    if (sound.isSilent) return;

    final now = DateTime.now();
    if (scheduledTime.isBefore(now)) return;

    final delay = scheduledTime.difference(now);

    Future.delayed(delay, () {
      _showPrayerNotification(
        id: id,
        prayerName: prayerName,
        sound: sound,
      );
    });
  }

  Future<void> _showPrayerNotification({
    required int id,
    required String prayerName,
    required NotificationSound sound,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'prayer_${sound.id}',
      'Prayer Times (${sound.id})',
      channelDescription: 'Prayer time notifications',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound(sound.androidRaw!),
      enableVibration: true,
      category: AndroidNotificationCategory.reminder,
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: sound.iosFile,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(
      id: id,
      title: '🕌 $prayerName',
      body: "It's time for $prayerName prayer",
      notificationDetails: details,
    );
  }

  /// Schedule notifications for all prayers.
  Future<void> scheduleAllPrayerNotifications({
    required Map<String, DateTime> prayerTimes,
    required PrayerNotificationSettings settings,
    required PrayerNotificationOffsets offsets,
  }) async {
    await cancelAll();

    const prayerIds = {
      'Fajr': 0,
      'Dhuhr': 1,
      'Asr': 2,
      'Maghrib': 3,
      'Isha': 4,
    };

    for (final entry in prayerIds.entries) {
      final soundId = settings[entry.key] ?? 'adhan_makkah';
      final sound = soundById(soundId);
      final time = prayerTimes[entry.key];
      if (time == null) continue;

      final offsetMinutes = offsets[entry.key] ?? 0;
      final scheduledTime = time.subtract(Duration(minutes: offsetMinutes));

      await schedulePrayerNotification(
        id: entry.value,
        prayerName: entry.key,
        scheduledTime: scheduledTime,
        sound: sound,
      );
    }
  }

  /// Show an immediate test notification (debug only).
  Future<void> showTestNotification({required NotificationSound sound}) async {
    final androidDetails = AndroidNotificationDetails(
      'prayer_test',
      'Prayer Times (test)',
      channelDescription: 'Test notification',
      importance: Importance.high,
      priority: Priority.high,
      playSound: sound.androidRaw != null,
      sound: sound.androidRaw != null
          ? RawResourceAndroidNotificationSound(sound.androidRaw!)
          : null,
      enableVibration: true,
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: sound.iosFile,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(
      id: 99,
      title: '🕌 Maghrib (test)',
      body: "It's time for Maghrib prayer",
      notificationDetails: details,
    );
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  Future<void> cancel(int id) async {
    await _plugin.cancel(id: id);
  }
}
