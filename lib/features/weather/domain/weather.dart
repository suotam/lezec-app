import '../../climbing_areas/domain/geo_point.dart';

/// One forecast hour (local time of the location).
typedef HourForecast = ({
  DateTime time,
  double temperatureC,
  double windKmh,
  double precipitationMm,
});

abstract interface class WeatherRepository {
  /// Hourly forecast for the next ~48 hours at [location].
  Future<List<HourForecast>> hourlyForecast(GeoPoint location);
}
