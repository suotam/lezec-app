import 'climbing_route.dart';

/// Sort orders offered on the sector screen. [guidebook] keeps the order
/// the routes are published in.
enum RouteSortOrder { guidebook, name, grade }

/// Returns a sorted copy of [routes]; the input list is never mutated.
List<ClimbingRoute> sortRoutes(
  List<ClimbingRoute> routes,
  RouteSortOrder order,
) {
  final sorted = [...routes];
  switch (order) {
    case RouteSortOrder.guidebook:
      break;
    case RouteSortOrder.name:
      sorted.sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );
    case RouteSortOrder.grade:
      sorted.sort((a, b) => a.grade.compareTo(b.grade));
  }
  return sorted;
}
