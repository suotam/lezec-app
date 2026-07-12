import 'package:chs_importer/chs_importer.dart';
import 'package:test/test.dart';

void main() {
  final fetchedAt = DateTime.utc(2026, 7, 12);

  RawChsSektor buildSektor({
    Map<String, String> iconFlags = const {'sportovni': 'Sportovní lezení'},
    String? rockText = 'žula',
    String? gradeSystemLabel = 'UIAA',
    double? latitude = 49.9,
    double? longitude = 15.5,
  }) {
    return RawChsSektor(
      id: 9001,
      name: 'Zkušební skály',
      sourceUrl: 'https://www.horosvaz.cz/skaly-sektor-9001/',
      fetchedAt: fetchedAt,
      breadcrumb: const RawChsBreadcrumb(
        regionId: 5,
        regionName: 'Testový kraj',
        oblastId: 300,
        oblastName: 'Testová skupina',
      ),
      descriptionParagraphs: const ['Popis oblasti.'],
      accessText: 'Od mostu po modré.',
      rockText: rockText,
      gradeSystemLabel: gradeSystemLabel,
      iconFlags: iconFlags,
      skalaIds: const [8001],
    )
      ..latitude = latitude
      ..longitude = longitude;
  }

  RawChsSkala buildSkala({List<RawChsCesta> routes = const []}) {
    return RawChsSkala(
      id: 8001,
      name: 'Velká stěna',
      sourceUrl: 'https://www.horosvaz.cz/skaly-skala-8001/',
      fetchedAt: fetchedAt,
      breadcrumb: const RawChsBreadcrumb(sektorId: 9001),
      routes: routes,
    );
  }

  test('builds a valid catalog from a sektor and its skála', () {
    final result = normalizeCatalog(
      sektory: [buildSektor()],
      skaly: [
        buildSkala(
          routes: const [
            RawChsCesta(
              id: 70001,
              name: 'Zkušební pilíř',
              gradeText: 'VI',
              iconFlags: {
                'sportovni': 'Sportovní lezení',
                'zajis_nyty': 'Fixní jištění',
                'nebezpeci': 'Nebezpečí',
              },
              description: 'Středem pilíře.',
              firstAscent: 'J. Novák, 1998',
            ),
          ],
        ),
      ],
      version: 2,
    );

    expect(validateCatalog(result.catalog).isValid, isTrue);

    final region = (result.catalog['regions'] as List).single as Map;
    expect(region['id'], 'chs-region-5');

    final area = (result.catalog['areas'] as List).single
        as Map<String, Object?>;
    expect(area['id'], 'chs-sektor-9001');
    expect(area['regionId'], 'chs-region-5');
    expect(area['rockType'], 'granite');
    expect(area['climbingTypes'], ['sport']);
    expect(area['summary'], contains('Testová skupina'));
    expect((area['access'] as Map)['description'], 'Od mostu po modré.');
    expect((area['meta'] as Map)['sourceUrl'], contains('sektor-9001'));

    final sector =
        (area['sectors'] as List).single as Map<String, Object?>;
    expect(sector['id'], 'chs-skala-8001');

    final route = (sector['routes'] as List).single as Map<String, Object?>;
    expect(route['id'], 'chs-cesta-70001');
    expect(route['grade'], {'system': 'uiaa', 'value': 'VI'});
    expect(route['type'], 'sport');
    expect(route['protection'], contains('kruhy, nýty'));
    expect(route['firstAscent'], 'J. Novák, 1998');
    expect(route['warnings'], ['Nebezpečí']);
  });

  test('maps sandstone grade systems and falls back with a warning', () {
    RawChsCesta cesta(int id) => RawChsCesta(id: id, name: 'Cesta $id');

    final saxon = normalizeCatalog(
      sektory: [buildSektor(gradeSystemLabel: 'Pískovec Sasko')],
      skaly: [buildSkala(routes: [cesta(1)])],
      version: 1,
    );
    final saxonRoute = _firstRoute(saxon.catalog);
    expect((saxonRoute['grade'] as Map)['system'], 'czechSandstone');
    expect(saxonRoute['type'], 'trad',
        reason: 'sandstone grading implies trad ethics');

    final unknown = normalizeCatalog(
      sektory: [buildSektor(gradeSystemLabel: 'Neznámá stupnice')],
      skaly: [buildSkala(routes: [cesta(1)])],
      version: 1,
    );
    expect((_firstRoute(unknown.catalog)['grade'] as Map)['system'], 'uiaa');
    expect(unknown.warnings.join(), contains('unknown grade system'));
  });

  test('missing grade is exported as "?" with a warning', () {
    final result = normalizeCatalog(
      sektory: [buildSektor()],
      skaly: [
        buildSkala(routes: const [RawChsCesta(id: 1, name: 'Bez klasifikace')]),
      ],
      version: 1,
    );
    expect((_firstRoute(result.catalog)['grade'] as Map)['value'], '?');
    expect(result.warnings.join(), contains('missing grade'));
  });

  test('closure icons become restrictions', () {
    final result = normalizeCatalog(
      sektory: [
        buildSektor(
          iconFlags: const {
            'sportovni': 'Sportovní lezení',
            'zakaz_hnizdeni': 'Zákaz kvůli hnízdění',
            'zakaz_cast_hnizdeni': 'Zákaz částí kvůli hnízdění',
          },
        ),
      ],
      skaly: [buildSkala()],
      version: 1,
    );
    final area = (result.catalog['areas'] as List).single as Map;
    final restrictions =
        (area['restrictions'] as List).cast<Map<String, Object?>>();
    expect(restrictions, hasLength(2));
    expect(restrictions.first['severity'], 'closure');
    expect(
      restrictions.map((r) => r['severity']),
      containsAll(['closure', 'warning']),
    );
  });

  test('sektor without GPS is skipped with a warning', () {
    final result = normalizeCatalog(
      sektory: [buildSektor(latitude: null, longitude: null)],
      skaly: [buildSkala()],
      version: 1,
    );
    expect(result.catalog['areas'], isEmpty);
    expect(result.warnings.join(), contains('no GPS'));
  });

  test('unmapped rock text becomes "other" with a warning', () {
    final result = normalizeCatalog(
      sektory: [buildSektor(rockText: 'amfibolit')],
      skaly: [buildSkala()],
      version: 1,
    );
    final area = (result.catalog['areas'] as List).single as Map;
    expect(area['rockType'], 'other');
    expect(result.warnings.join(), contains('unmapped rock'));
  });
}

Map<String, Object?> _firstRoute(Map<String, Object?> catalog) {
  final area = (catalog['areas'] as List).first as Map<String, Object?>;
  final sector = (area['sectors'] as List).first as Map<String, Object?>;
  return (sector['routes'] as List).first as Map<String, Object?>;
}
