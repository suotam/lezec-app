import 'package:flutter_test/flutter_test.dart';
import 'package:lezec_app/features/climbing_areas/domain/area_filter.dart';
import 'package:lezec_app/features/climbing_areas/domain/climbing_area.dart';
import 'package:lezec_app/features/climbing_areas/domain/geo_point.dart';
import 'package:lezec_app/features/climbing_areas/domain/rock_type.dart';
import 'package:lezec_app/features/climbing_routes/domain/climbing_type.dart';

import '../helpers/test_helpers.dart';

void main() {
  final areas = [
    buildArea(
      id: 'a1',
      name: 'Sokolí věže',
      regionName: 'Východní Čechy',
      summary: 'Pískovcové věže',
      description: 'Tradiční lezení na pískovci.',
      climbingTypes: {ClimbingType.trad},
      rockType: RockType.sandstone,
    ),
    buildArea(
      id: 'a2',
      name: 'Bílý lom',
      regionName: 'Moravský kras',
      summary: 'Sportovní vápencový lom',
      description: 'Odjištěné sportovní cesty.',
      climbingTypes: {ClimbingType.sport},
      rockType: RockType.limestone,
    ),
    buildArea(
      id: 'a3',
      name: 'U Tří kamenů',
      regionName: 'Vysočina',
      summary: 'Žulové balvany',
      description: 'Bouldering v lese.',
      climbingTypes: {ClimbingType.boulder},
      rockType: RockType.granite,
    ),
  ];

  List<String> idsFor(AreaFilter filter) =>
      filterAreas(areas, filter).map((a) => a.id).toList();

  group('filterAreas', () {
    test('empty filter returns everything, name-sorted by default', () {
      expect(idsFor(const AreaFilter()), ['a2', 'a1', 'a3']);
    });

    test('searches by name', () {
      expect(idsFor(const AreaFilter(query: 'lom')), ['a2']);
    });

    test('searches by region', () {
      expect(idsFor(const AreaFilter(query: 'Vysočina')), ['a3']);
    });

    test('searches description text', () {
      expect(idsFor(const AreaFilter(query: 'bouldering')), ['a3']);
    });

    test('is case- and diacritics-insensitive', () {
      expect(idsFor(const AreaFilter(query: 'SOKOLI VEZE')), ['a1']);
    });

    test('all words must match', () {
      expect(idsFor(const AreaFilter(query: 'lom vápencový')), ['a2']);
      expect(idsFor(const AreaFilter(query: 'lom žula')), isEmpty);
    });

    test('filters by climbing type', () {
      expect(idsFor(const AreaFilter(climbingTypes: {ClimbingType.sport})), [
        'a2',
      ]);
      expect(
        idsFor(
          const AreaFilter(
            climbingTypes: {ClimbingType.sport, ClimbingType.boulder},
          ),
        ),
        ['a2', 'a3'],
      );
    });

    test('filters by rock type', () {
      expect(idsFor(const AreaFilter(rockTypes: {RockType.sandstone})), ['a1']);
    });

    test('filters by region', () {
      final regional = [
        buildArea(id: 'r1', regionId: 'region-a'),
        buildArea(id: 'r2', regionId: 'region-b'),
        buildArea(id: 'r3', regionId: 'region-a'),
      ];
      expect(
        filterAreas(
          regional,
          const AreaFilter(regionIds: {'region-a'}),
        ).map((a) => a.id),
        ['r1', 'r3'],
      );
      expect(
        filterAreas(
          regional,
          const AreaFilter(regionIds: {'region-a', 'region-b'}),
        ),
        hasLength(3),
      );
    });

    test('combines query and filters', () {
      expect(
        idsFor(
          const AreaFilter(query: 'lezení', climbingTypes: {ClimbingType.trad}),
        ),
        ['a1'],
      );
      expect(
        idsFor(
          const AreaFilter(
            query: 'lezení',
            climbingTypes: {ClimbingType.sport},
          ),
        ),
        isEmpty,
      );
    });
  });

  group('sortAreas', () {
    final unsorted = [
      buildArea(
        id: 'praha',
        name: 'Šutry u Prahy',
        routeCount: 5,
        location: const GeoPoint(latitude: 50.08, longitude: 14.43),
      ),
      buildArea(
        id: 'brno',
        name: 'Brněnské stěny',
        routeCount: 20,
        location: const GeoPoint(latitude: 49.19, longitude: 16.61),
      ),
      buildArea(
        id: 'ostrava',
        name: 'Ostravské bloky',
        routeCount: 10,
        location: const GeoPoint(latitude: 49.82, longitude: 18.26),
      ),
    ];

    List<String> ids(List<ClimbingArea> areas) =>
        areas.map((a) => a.id).toList();

    test('by name uses diacritics-insensitive alphabet', () {
      expect(ids(sortAreas(unsorted, AreaSort.name)), [
        'brno',
        'ostrava',
        'praha',
      ]);
    });

    test('by route count descending', () {
      expect(ids(sortAreas(unsorted, AreaSort.routeCount)), [
        'brno',
        'ostrava',
        'praha',
      ]);
      expect(sortAreas(unsorted, AreaSort.routeCount).first.routeCount, 20);
    });

    test('by distance from the origin, nearest first', () {
      // Origin near Olomouc: Brno ~60 km, Ostrava ~90 km, Praha ~200 km.
      const olomouc = GeoPoint(latitude: 49.59, longitude: 17.25);
      expect(ids(sortAreas(unsorted, AreaSort.distance, origin: olomouc)), [
        'brno',
        'ostrava',
        'praha',
      ]);
      // Origin near Prague flips the order.
      const praha = GeoPoint(latitude: 50.07, longitude: 14.44);
      expect(
        ids(sortAreas(unsorted, AreaSort.distance, origin: praha)).first,
        'praha',
      );
    });

    test('by distance without an origin falls back to name order', () {
      expect(
        ids(sortAreas(unsorted, AreaSort.distance)),
        ids(sortAreas(unsorted, AreaSort.name)),
      );
    });
  });

  group('GeoPoint.distanceInKmTo', () {
    test('Praha–Brno is roughly 185 km', () {
      const praha = GeoPoint(latitude: 50.0755, longitude: 14.4378);
      const brno = GeoPoint(latitude: 49.1951, longitude: 16.6068);
      final km = praha.distanceInKmTo(brno);
      expect(km, greaterThan(170));
      expect(km, lessThan(200));
      expect(praha.distanceInKmTo(praha), closeTo(0, 0.001));
    });
  });
}
