import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

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

    await _plugin.initialize(settings);
    _initialized = true;
  }

  Future<void> schedulePrayerNotification({
    required int id,
    required String prayerName,
    required DateTime scheduledTime,
  }) async {
    // Schedule exact notification
    // Note: on Android 12+, exact alarms require SCHEDULE_EXACT_ALARM permission
    final androidDetails = AndroidNotificationDetails(
      'prayer_times',
      'Prayer Times',
      channelDescription: 'Notifications for prayer times',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      category: AndroidNotificationCategory.reminder,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Use show() for immediate testing; for production, use zonedSchedule()
    // with the timezone package for exact scheduling.
    final now = DateTime.now();
    final delay = scheduledTime.difference(now);

    if (delay.isNegative) return;

    // For V1, we schedule via Future.delayed + show
    // TODO: migrate to zonedSchedule with timezone package for reliability
    Future.delayed(delay, () {
      _plugin.show(
        id,
        '🕌 $prayerName',
        'It\'s time for $prayerName prayer',
        details,
      );
    });
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  Future<void> cancel(int id) async {
    await _plugin.cancel(id);
  }
}
