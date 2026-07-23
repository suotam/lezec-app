import 'dart:convert';
import 'dart:typed_data';

import '../../../core/utilities/http_bytes.dart';
import '../../climbing_areas/domain/geo_point.dart';
import '../domain/weather.dart';

typedef WeatherFetcher = Future<Uint8List> Function(Uri uri);

/// [WeatherRepository] over the free Open-Meteo API (no key; attribution
/// required — the UI shows "Data: Open-Meteo.com").
class OpenMeteoRepository implements WeatherRepository {
  OpenMeteoRepository({WeatherFetcher? fetcher})
    : _fetch = fetcher ?? fetchBytes;

  final WeatherFetcher _fetch;

  @override
  Future<List<HourForecast>> hourlyForecast(GeoPoint location) async {
    final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
      'latitude': location.latitude.toStringAsFixed(4),
      'longitude': location.longitude.toStringAsFixed(4),
      'hourly': 'temperature_2m,precipitation,wind_speed_10m',
      'forecast_days': '2',
      'timezone': 'auto',
    });
    final decoded = json.decode(utf8.decode(await _fetch(uri)));
    if (decoded is! Map<String, Object?>) {
      throw const FormatException('unexpected weather payload');
    }
    final hourly = decoded['hourly'];
    if (hourly is! Map<String, Object?>) {
      throw const FormatException('missing hourly block');
    }
    final times = hourly['time'];
    final temps = hourly['temperature_2m'];
    final precip = hourly['precipitation'];
    final wind = hourly['wind_speed_10m'];
    if (times is! List || temps is! List || precip is! List || wind is! List) {
      throw const FormatException('malformed hourly series');
    }
    return [
      for (var i = 0; i < times.length; i++)
        if (temps[i] != null && precip[i] != null && wind[i] != null)
          (
            time: DateTime.parse(times[i] as String),
            temperatureC: (temps[i] as num).toDouble(),
            windKmh: (wind[i] as num).toDouble(),
            precipitationMm: (precip[i] as num).toDouble(),
          ),
    ];
  }
}
