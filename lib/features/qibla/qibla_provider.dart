import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/location_service.dart';
import '../../core/utils/qibla_calculator.dart';
import '../prayer_times/prayer_times_provider.dart';

class QiblaState {
  final double bearing;
  final double distance;

  const QiblaState({required this.bearing, required this.distance});
}

final qiblaProvider = AsyncNotifierProvider<QiblaNotifier, QiblaState>(
  QiblaNotifier.new,
);

class QiblaNotifier extends AsyncNotifier<QiblaState> {
  @override
  Future<QiblaState> build() async {
    return _calculateQibla();
  }

  Future<QiblaState> _calculateQibla() async {
    final locationService = ref.read(locationServiceProvider);
    final position = await locationService.getCurrentPosition();

    final bearing =
        QiblaCalculator.calculate(position.latitude, position.longitude);
    final distance = QiblaCalculator.distanceToKaaba(
        position.latitude, position.longitude);

    return QiblaState(bearing: bearing, distance: distance);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_calculateQibla);
  }
}
