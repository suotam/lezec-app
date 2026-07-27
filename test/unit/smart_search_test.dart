import 'package:flutter_test/flutter_test.dart';
import 'package:lezec_app/features/climbing_areas/domain/geo_point.dart';
import 'package:lezec_app/features/climbing_areas/domain/smart_search.dart';
import 'package:lezec_app/features/climbing_routes/domain/climbing_type.dart';

import '../helpers/test_helpers.dart';

void main() {
  // Bands are indices into routeGradeBandLabels; 8 ≈ 6a, 14 ≈ 7a.
  final sportEasy = buildArea(
    id: 'sport-easy',
    name: 'Sportovní nízké',
    climbingTypes: const {ClimbingType.sport},
    location: const GeoPoint(latitude: 50.0, longitude: 15.8), // by Pardubice
    routeCount: 40,
    routeGradeMinBand: 4,
    routeGradeMaxBand: 9,
  );
  final sportHard = buildArea(
    id: 'sport-hard',
    name: 'Sportovní těžké',
    climbingTypes: const {ClimbingType.sport},
    location: const GeoPoint(latitude: 49.2, longitude: 16.6), // Brno-ish
    routeCount: 200,
    routeGradeMinBand: 12,
    routeGradeMaxBand: 20,
  );
  final tradArea = buildArea(
    id: 'trad',
    name: 'Pískovec',
    climbingTypes: const {ClimbingType.trad},
    location: const GeoPoint(latitude: 50.6, longitude: 14.2),
    routeCount: 120,
    routeGradeMinBand: 5,
    routeGradeMaxBand: 11,
  );
  final boulderArea = buildArea(
    id: 'boulder',
    name: 'Balvany',
    climbingTypes: const {ClimbingType.boulder},
    location: const GeoPoint(latitude: 49.4, longitude: 15.6),
    routeCount: 60,
    boulderGradeMinBand: 3,
    boulderGradeMaxBand: 10,
  );
  final areas = [sportEasy, sportHard, tradArea, boulderArea];

  List<String> ids(SmartSearchQuery q) =>
      smartSearchAreas(areas, q).map((r) => r.area.id).toList();

  test('discipline routes excludes boulder-only areas', () {
    final result = ids(const SmartSearchQuery());
    expect(result, containsAll(['sport-easy', 'sport-hard', 'trad']));
    expect(result, isNot(contains('boulder')));
  });

  test('route type narrows to sport or trad', () {
    expect(ids(const SmartSearchQuery(routeTypes: {ClimbingType.trad})), [
      'trad',
    ]);
    expect(
      ids(const SmartSearchQuery(routeTypes: {ClimbingType.sport})),
      containsAll(['sport-easy', 'sport-hard']),
    );
  });

  test('grade band range keeps only overlapping areas', () {
    // Around band 8 (~6a): easy sport and trad overlap, hard sport does not.
    final result = ids(const SmartSearchQuery(minBand: 7, maxBand: 9));
    expect(result, containsAll(['sport-easy', 'trad']));
    expect(result, isNot(contains('sport-hard')));
  });

  test('no grade filter keeps areas with unknown grades', () {
    final noGrades = buildArea(
      id: 'no-grades',
      climbingTypes: const {ClimbingType.sport},
    );
    expect(
      smartSearchAreas([
        noGrades,
      ], const SmartSearchQuery()).map((r) => r.area.id),
      ['no-grades'],
    );
    // But a grade filter drops it (can't confirm a match).
    expect(
      smartSearchAreas([noGrades], const SmartSearchQuery(minBand: 5)),
      isEmpty,
    );
  });

  test('boulder discipline uses the boulder scale and area', () {
    final result = smartSearchAreas(
      areas,
      const SmartSearchQuery(
        discipline: SmartDiscipline.boulders,
        minBand: 4,
        maxBand: 6,
      ),
    );
    expect(result.map((r) => r.area.id), ['boulder']);
  });

  test('origin + radius filters by distance and sorts nearest first', () {
    const pardubice = SmartOrigin(
      label: 'Pardubice',
      point: GeoPoint(latitude: 50.038, longitude: 15.779),
    );
    final near = smartSearchAreas(
      areas,
      const SmartSearchQuery(origin: pardubice, radiusKm: 30),
    );
    // Only the area next to Pardubice is within 30 km.
    expect(near.map((r) => r.area.id), ['sport-easy']);
    expect(near.single.distanceKm, isNotNull);
    expect(near.single.distanceKm!, lessThan(30));
  });

  test('without an origin results rank by route count', () {
    final result = ids(const SmartSearchQuery());
    // sport-hard (200) before trad (120) before sport-easy (40).
    expect(result, ['sport-hard', 'trad', 'sport-easy']);
  });
}
