import 'package:chs_importer/chs_importer.dart';
import 'package:test/test.dart';

Map<String, Object?> validCatalog() => {
      'version': 1,
      'regions': [
        {'id': 'r1', 'name': 'Region', 'country': 'CZ'},
      ],
      'areas': [
        {
          'id': 'a1',
          'regionId': 'r1',
          'name': 'Oblast',
          'summary': 'Souhrn.',
          'description': 'Popis.',
          'climbingTypes': ['sport'],
          'rockType': 'granite',
          'location': {'latitude': 49.9, 'longitude': 15.5},
          'restrictions': <Object?>[],
          'sectors': [
            {
              'id': 's1',
              'name': 'Sektor',
              'rocks': <Object?>[],
              'routes': <Map<String, Object?>>[
                {
                  'id': 'c1',
                  'name': 'Cesta',
                  'grade': {'system': 'uiaa', 'value': 'VI'},
                  'type': 'sport',
                },
              ],
            },
          ],
        },
      ],
    };

void main() {
  test('accepts a well-formed catalog', () {
    final result = validateCatalog(validCatalog());
    expect(result.errors, isEmpty);
    expect(result.isValid, isTrue);
  });

  test('rejects a missing version', () {
    final catalog = validCatalog()..remove('version');
    expect(
      validateCatalog(catalog).errors.join(),
      contains('version'),
    );
  });

  test('rejects an unknown region reference', () {
    final catalog = validCatalog();
    ((catalog['areas'] as List).first as Map)['regionId'] = 'missing';
    expect(
      validateCatalog(catalog).errors.join(),
      contains('unknown region'),
    );
  });

  test('rejects duplicate route ids across areas', () {
    final catalog = validCatalog();
    final area = (catalog['areas'] as List).first as Map<String, Object?>;
    final sector = (area['sectors'] as List).first as Map<String, Object?>;
    final routes = sector['routes'] as List;
    routes.add(Map<String, Object?>.from(routes.first as Map));
    expect(
      validateCatalog(catalog).errors.join(),
      contains('duplicate route id'),
    );
  });

  test('rejects an unknown grade system', () {
    final catalog = validCatalog();
    final area = (catalog['areas'] as List).first as Map<String, Object?>;
    final sector = (area['sectors'] as List).first as Map<String, Object?>;
    final route = (sector['routes'] as List).first as Map<String, Object?>;
    route['grade'] = {'system': 'elbsandstein', 'value': 'VIIb'};
    expect(validateCatalog(catalog).errors.join(), contains('grade'));
  });

  test('warns about areas without sectors and routes', () {
    final catalog = validCatalog();
    final area = (catalog['areas'] as List).first as Map<String, Object?>;
    area['sectors'] = <Object?>[];
    final result = validateCatalog(catalog);
    expect(result.isValid, isTrue);
    expect(result.warnings.join(), contains('no sectors'));
  });
}
