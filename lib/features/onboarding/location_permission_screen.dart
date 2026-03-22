import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../l10n/app_localizations.dart';

class LocationPermissionScreen extends StatefulWidget {
  const LocationPermissionScreen({super.key});

  @override
  State<LocationPermissionScreen> createState() =>
      _LocationPermissionScreenState();
}

class _LocationPermissionScreenState extends State<LocationPermissionScreen> {
  bool _requesting = false;
  _PermissionStep _step = _PermissionStep.location;

  @override
  void initState() {
    super.initState();
    _checkInitialStep();
  }

  Future<void> _checkInitialStep() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      if (mounted) {
        setState(() => _step = _PermissionStep.notification);
      }
    }
  }

  Future<void> _requestLocationPermission() async {
    setState(() => _requesting = true);

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever && mounted) {
      await Geolocator.openAppSettings();
    }

    if (mounted) {
      setState(() {
        _requesting = false;
        _step = _PermissionStep.notification;
      });
    }
  }

  Future<void> _requestNotificationPermission() async {
    setState(() => _requesting = true);

    final plugin = FlutterLocalNotificationsPlugin();

    // Android 13+ (API 33) requires POST_NOTIFICATIONS permission
    final androidPlugin =
        plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
    }

    // iOS
    final iosPlugin =
        plugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    if (iosPlugin != null) {
      await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    if (mounted) {
      context.go('/prayer-times');
    }
  }

  void _skip() {
    if (_step == _PermissionStep.location) {
      setState(() => _step = _PermissionStep.notification);
    } else {
      context.go('/prayer-times');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final icon = _step == _PermissionStep.location
        ? Icons.location_on_rounded
        : Icons.notifications_active_rounded;
    final title = _step == _PermissionStep.location
        ? l10n.locationPermissionTitle
        : l10n.notificationPermissionTitle;
    final description = _step == _PermissionStep.location
        ? l10n.locationPermissionDescription
        : l10n.notificationPermissionDescription;
    final buttonLabel = _step == _PermissionStep.location
        ? l10n.allowLocation
        : l10n.allowNotifications;
    final onPressed = _step == _PermissionStep.location
        ? _requestLocationPermission
        : _requestNotificationPermission;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Step indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _StepDot(active: _step == _PermissionStep.location),
                  const SizedBox(width: 8),
                  _StepDot(active: _step == _PermissionStep.notification),
                ],
              ),

              const SizedBox(height: 32),

              // Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: UmmatiTheme.primaryGreen.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 56,
                  color: UmmatiTheme.primaryGreen,
                ),
              ),

              const SizedBox(height: 32),

              // Title
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: UmmatiTheme.darkText,
                    ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Description
              Text(
                description,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: UmmatiTheme.darkText.withValues(alpha: 0.7),
                      height: 1.5,
                    ),
                textAlign: TextAlign.center,
              ),

              const Spacer(flex: 3),

              // Allow button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _requesting ? null : onPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: UmmatiTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: _requesting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(buttonLabel),
                ),
              ),

              const SizedBox(height: 12),

              // Skip button
              TextButton(
                onPressed: _requesting ? null : _skip,
                child: Text(
                  l10n.skipForNow,
                  style: TextStyle(
                    color: UmmatiTheme.darkText.withValues(alpha: 0.5),
                    fontSize: 14,
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

enum _PermissionStep { location, notification }

class _StepDot extends StatelessWidget {
  final bool active;
  const _StepDot({required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: active ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: active ? UmmatiTheme.primaryGreen : Colors.grey[300],
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
