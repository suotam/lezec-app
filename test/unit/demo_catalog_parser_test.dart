import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lezec_app/core/errors/demo_data_format_exception.dart';
import 'package:lezec_app/features/climbing_areas/data/demo_catalog_parser.dart';
import 'package:lezec_app/features/climbing_routes/domain/route_grade.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('parseDemoCatalog', () {
    test('parses the bundled catalog asset', () {
      final raw = utf8.decode(
        gzip.decode(
          File(
            'assets/demo_data/climbing_catalog.json.gz',
          ).readAsBytesSync(),
        ),
      );

      final catalog = parseDemoCatalog(raw);

      expect(catalog.version, greaterThanOrEqualTo(3));
      expect(catalog.regions, isNotEmpty);
      expect(catalog.areas, isNotEmpty);
      // Every area must resolve its region and contain routes.
      for (final area in catalog.areas) {
        expect(area.regionName, isNotEmpty);
        expect(area.routeCount, greaterThan(0));
        expect(area.sectorCount, greaterThan(0));
      }
    });

    test('supports both sector shapes (rock routes and direct routes)', () {
      final catalog = parseDemoCatalog(testCatalogJson);

      final sandstone = catalog.areas.first;
      expect(sandstone.sectors.first.rocks, isNotEmpty);
      expect(sandstone.sectors.first.routes, isEmpty);
      expect(sandstone.routeCount, 1);

      final sportArea = catalog.areas.last;
      expect(sportArea.sectors.first.rocks, isEmpty);
      expect(sportArea.sectors.first.routes, hasLength(2));

      final route = sportArea.sectors.first.routes.first;
      expect(
        route.grade,
        const RouteGrade(system: GradingSystem.french, value: '6b+'),
      );
      expect(route.lengthMeters, 15);
    });

    test('rejects invalid JSON', () {
      expect(
        () => parseDemoCatalog('{not json'),
        throwsA(isA<DemoDataFormatException>()),
      );
    });

    test('rejects a missing or invalid format version', () {
      final withoutVersion =
          json.decode(testCatalogJson) as Map<String, Object?>;
      withoutVersion.remove('version');

      expect(
        () => parseDemoCatalog(json.encode(withoutVersion)),
        throwsA(
          isA<DemoDataFormatException>().having(
            (e) => e.message,
            'message',
            contains('version'),
          ),
        ),
      );
    });

    test('rejects a missing required field with a path in the message', () {
      final broken = json.decode(testCatalogJson) as Map<String, Object?>;
      ((broken['areas'] as List).first as Map<String, Object?>).remove('name');

      expect(
        () => parseDemoCatalog(json.encode(broken)),
        throwsA(
          isA<DemoDataFormatException>().having(
            (e) => e.message,
            'message',
            contains('areas[0].name'),
          ),
        ),
      );
    });

    test('rejects unknown enum values', () {
      final broken = testCatalogJson.replaceFirst(
        '"sandstone"',
        '"kryptonite"',
      );
      expect(
        () => parseDemoCatalog(broken),
        throwsA(isA<DemoDataFormatException>()),
      );
    });

    test('rejects unknown region references', () {
      final broken = testCatalogJson.replaceFirst('"region-a"', '"region-x"');
      expect(
        () => parseDemoCatalog(broken),
        throwsA(isA<DemoDataFormatException>()),
      );
    });

    test('rejects duplicate route ids', () {
      final broken = testCatalogJson.replaceAll('route-plotna', 'route-hrana');
      expect(
        () => parseDemoCatalog(broken),
        throwsA(
          isA<DemoDataFormatException>().having(
            (e) => e.message,
            'message',
            contains('route-hrana'),
          ),
        ),
      );
    });
  });
}
