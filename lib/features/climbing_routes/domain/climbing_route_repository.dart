import 'route_context.dart';

/// Route lookup by stable ID, independent of how the user navigated there.
abstract interface class ClimbingRouteRepository {
  Future<RouteContext?> getRouteById(String id);
}
