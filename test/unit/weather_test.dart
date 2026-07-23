import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:lezec_app/features/climbing_areas/domain/geo_point.dart';
import 'package:lezec_app/features/weather/data/open_meteo_repository.dart';

void main() {
  test('parses the Open-Meteo hourly payload', () async {
    Uri? requested;
    final repository = OpenMeteoRepository(
      fetcher: (uri) async {
        requested = uri;
        return Uint8List.fromList(
          utf8.encode(
            json.encode({
              'hourly': {
                'time': ['2026-07-23T10:00', '2026-07-23T11:00'],
                'temperature_2m': [21.4, 22.9],
                'precipitation': [0.0, 0.3],
                'wind_speed_10m': [11.5, 14.2],
              },
            }),
          ),
        );
      },
    );

    final hours = await repository.hourlyForecast(
      const GeoPoint(latitude: 50.1234, longitude: 15.5678),
    );

    expect(requested!.host, 'api.open-meteo.com');
    expect(requested!.queryParameters['latitude'], '50.1234');
    expect(hours, hasLength(2));
    expect(hours.first.temperatureC, 21.4);
    expect(hours.last.windKmh, 14.2);
    expect(hours.last.precipitationMm, 0.3);
    expect(hours.first.time, DateTime(2026, 7, 23, 10));
  });

  test('null gaps in the series are skipped', () async {
    final repository = OpenMeteoRepository(
      fetcher: (uri) async => Uint8List.fromList(
        utf8.encode(
          json.encode({
            'hourly': {
              'time': ['2026-07-23T10:00', '2026-07-23T11:00'],
              'temperature_2m': [21.4, null],
              'precipitation': [0.0, null],
              'wind_speed_10m': [11.5, null],
            },
          }),
        ),
      ),
    );

    final hours = await repository.hourlyForecast(
      const GeoPoint(latitude: 50, longitude: 15),
    );
    expect(hours, hasLength(1));
  });

  test('malformed payloads throw a FormatException', () async {
    final repository = OpenMeteoRepository(
      fetcher: (uri) async => Uint8List.fromList(utf8.encode('[]')),
    );
    expect(
      () => repository.hourlyForecast(const GeoPoint(latitude: 50, longitude: 15)),
      throwsFormatException,
    );
  });
}
