import 'package:flutter_test/flutter_test.dart';
import 'package:lezec_app/features/climbing_areas/domain/area_filter.dart';
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
    test('empty filter returns everything', () {
      expect(idsFor(const AreaFilter()), ['a1', 'a2', 'a3']);
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
}
