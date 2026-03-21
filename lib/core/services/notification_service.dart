import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../features/settings/settings_provider.dart';

@pragma('vm:entry-point')
void _onBackgroundNotificationResponse(NotificationResponse response) {
  // Handle background notification tap
}

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
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // TODO: handle notification tap
      },
      onDidReceiveBackgroundNotificationResponse:
          _onBackgroundNotificationResponse,
    );
    _initialized = true;
  }

  /// Schedule a prayer notification with the chosen sound.
  Future<void> schedulePrayerNotification({
    required int id,
    required String prayerName,
    required DateTime scheduledTime,
    required NotificationSound sound,
  }) async {
    if (sound.isSilent) return;

    final now = DateTime.now();
    if (scheduledTime.isBefore(now)) return;

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

    final tzScheduledTime = tz.TZDateTime.from(scheduledTime, tz.local);

    await _plugin.zonedSchedule(
      id: id,
      title: '🕌 $prayerName',
      body: "It's time for $prayerName prayer",
      scheduledDate: tzScheduledTime,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  /// Schedule notifications for all prayers based on per-prayer settings.
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

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  Future<void> cancel(int id) async {
    await _plugin.cancel(id: id);
  }
}
