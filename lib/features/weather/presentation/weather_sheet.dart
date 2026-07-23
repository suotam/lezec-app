import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/localization/l10n.dart';
import '../../../shared/extensions/date_formatting.dart';
import '../../climbing_areas/domain/geo_point.dart';
import '../data/open_meteo_repository.dart';
import '../domain/weather.dart';

final weatherRepositoryProvider = Provider<WeatherRepository>(
  (ref) => OpenMeteoRepository(),
);

/// Forecast keyed by rounded coordinates so nearby lookups share one
/// request per session.
final hourlyForecastProvider =
    FutureProvider.family<List<HourForecast>, ({double lat, double lng})>((
      ref,
      key,
    ) {
      return ref
          .watch(weatherRepositoryProvider)
          .hourlyForecast(GeoPoint(latitude: key.lat, longitude: key.lng));
    });

/// Bottom sheet with the next 24 hours of temperature, wind and
/// precipitation for an area.
class WeatherSheet extends ConsumerWidget {
  const WeatherSheet({super.key, required this.title, required this.location});

  final String title;
  final GeoPoint location;

  static Future<void> show(
    BuildContext context, {
    required String title,
    required GeoPoint location,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => WeatherSheet(title: title, location: location),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final key = (
      lat: double.parse(location.latitude.toStringAsFixed(3)),
      lng: double.parse(location.longitude.toStringAsFixed(3)),
    );
    final forecast = ref.watch(hourlyForecastProvider(key));

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${l10n.weatherTitle} · $title',
              style: theme.textTheme.titleMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.sm),
            Flexible(
              child: switch (forecast) {
                AsyncData(:final value) => _HourList(
                  hours: _next24Hours(value),
                ),
                AsyncError() => Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Row(
                    children: [
                      Expanded(child: Text(l10n.weatherLoadFailed)),
                      TextButton(
                        onPressed: () =>
                            ref.invalidate(hourlyForecastProvider(key)),
                        child: Text(l10n.commonRetry),
                      ),
                    ],
                  ),
                ),
                _ => const Padding(
                  padding: EdgeInsets.all(AppSpacing.xl),
                  child: Center(child: CircularProgressIndicator()),
                ),
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              // Attribution required by the Open-Meteo license (CC BY).
              'Data: Open-Meteo.com',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static List<HourForecast> _next24Hours(List<HourForecast> all) {
    final now = DateTime.now();
    final startIndex = all.indexWhere(
      (hour) =>
          !hour.time.isBefore(DateTime(now.year, now.month, now.day, now.hour)),
    );
    if (startIndex < 0) return all.take(24).toList();
    return all.skip(startIndex).take(24).toList();
  }
}

class _HourList extends StatelessWidget {
  const _HourList({required this.hours});

  final List<HourForecast> hours;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView.builder(
      shrinkWrap: true,
      itemCount: hours.length,
      itemBuilder: (context, index) {
        final hour = hours[index];
        final hasRain = hour.precipitationMm >= 0.1;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Row(
            children: [
              SizedBox(
                width: 56,
                child: Text(
                  formatTime(context, hour.time),
                  style: theme.textTheme.titleSmall,
                ),
              ),
              SizedBox(
                width: 56,
                child: Text(
                  '${hour.temperatureC.round()}°',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              Icon(
                Icons.air,
                size: 14,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: AppSpacing.xs),
              SizedBox(
                width: 72,
                child: Text(
                  '${hour.windKmh.round()} km/h',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              Icon(
                hasRain ? Icons.water_drop : Icons.water_drop_outlined,
                size: 14,
                color: hasRain
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                '${hour.precipitationMm.toStringAsFixed(1)} mm',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: hasRain ? null : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
