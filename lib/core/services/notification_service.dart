import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

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
    final tzInfo = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(tzInfo.identifier));

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

    // Request permissions on Android
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
      await androidPlugin.requestExactAlarmsPermission();
    }

    _initialized = true;
  }

  /// Schedule a prayer notification via the OS alarm system.
  /// Persists even if the app is killed.
  Future<void> schedulePrayerNotification({
    required int id,
    required String prayerName,
    required DateTime scheduledTime,
    required NotificationSound sound,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'prayer_${sound.id}',
      'Prayer Times',
      channelDescription: 'Prayer time notifications',
      importance: Importance.high,
      priority: Priority.high,
      playSound: sound.androidRaw != null,
      sound: sound.androidRaw != null
          ? RawResourceAndroidNotificationSound(sound.androidRaw!)
          : null,
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

    final tzTime = tz.TZDateTime.from(scheduledTime, tz.local);

    debugPrint('zonedSchedule: id=$id, prayer=$prayerName, '
        'scheduledTime=$scheduledTime, tzTime=$tzTime, '
        'tzLocal=${tz.local.name}');

    await _plugin.zonedSchedule(
      id: id,
      title: '🕌 $prayerName',
      body: "It's time for $prayerName prayer",
      scheduledDate: tzTime,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );

    debugPrint('zonedSchedule: id=$id scheduled OK');
  }

  /// Show a prayer notification immediately.
  Future<void> showPrayerNotification({
    required int id,
    required String prayerName,
    required NotificationSound sound,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'prayer_${sound.id}',
      'Prayer Times',
      channelDescription: 'Prayer time notifications',
      importance: Importance.high,
      priority: Priority.high,
      playSound: sound.androidRaw != null,
      sound: sound.androidRaw != null
          ? RawResourceAndroidNotificationSound(sound.androidRaw!)
          : null,
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
}
