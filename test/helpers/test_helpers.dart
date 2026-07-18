import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lezec_app/core/database/crux_database.dart';
import 'package:lezec_app/core/database/database_provider.dart';
import 'package:lezec_app/core/localization/l10n.dart';
import 'package:lezec_app/core/theme/app_theme.dart';
import 'package:lezec_app/features/climbing_areas/data/demo_catalog_data_source.dart';
import 'package:lezec_app/features/climbing_areas/domain/climbing_area.dart';
import 'package:lezec_app/features/climbing_areas/domain/geo_point.dart';
import 'package:lezec_app/features/climbing_areas/domain/rock_type.dart';
import 'package:lezec_app/features/climbing_areas/presentation/climbing_areas_providers.dart';
import 'package:lezec_app/features/climbing_routes/domain/climbing_type.dart';

/// Serves [json] for any asset path so tests never touch the real bundle.
class FakeAssetBundle extends CachingAssetBundle {
  FakeAssetBundle(this.json);

  final String json;

  @override
  Future<ByteData> load(String key) async =>
      ByteData.sublistView(Uint8List.fromList(utf8.encode(json)));
}

/// Two-area catalog exercising both hierarchy shapes: a rock-based sandstone
/// area and a sport area with routes directly under the sector.
const testCatalogJson = '''
{
  "version": 1,
  "regions": [
    {"id": "region-a", "name": "Testový region A", "country": "CZ"},
    {"id": "region-b", "name": "Testový region B", "country": "CZ"}
  ],
  "areas": [
    {
      "id": "area-piskovce",
      "regionId": "region-a",
      "name": "Testové věže",
      "summary": "Pískovcové věže na testování.",
      "description": "Dlouhý popis pískovcové oblasti.",
      "climbingTypes": ["trad"],
      "rockType": "sandstone",
      "location": {"latitude": 50.1, "longitude": 15.1},
      "parking": [
        {
          "id": "parking-1",
          "name": "Parkoviště Test",
          "location": {"latitude": 50.0, "longitude": 15.0}
        }
      ],
      "access": {"description": "Po zelené značce.", "approachMinutes": 15},
      "restrictions": [
        {
          "id": "restriction-1",
          "title": "Hnízdění",
          "description": "Sektor uzavřen.",
          "severity": "closure",
          "seasonalNote": "1. 3. – 30. 6."
        }
      ],
      "sectors": [
        {
          "id": "sector-veze",
          "name": "Věže",
          "description": "Sektor s věžemi.",
          "rocks": [
            {
              "id": "rock-vez",
              "name": "Hlavní věž",
              "routes": [
                {
                  "id": "route-spara",
                  "name": "Testová spára",
                  "grade": {"system": "czechSandstone", "value": "VIIb"},
                  "type": "trad",
                  "lengthMeters": 30,
                  "description": "Pěkná spára."
                }
              ]
            }
          ],
          "routes": []
        }
      ]
    },
    {
      "id": "area-lom",
      "regionId": "region-b",
      "name": "Testový lom",
      "summary": "Sportovní lom na testování.",
      "description": "Dlouhý popis lomu.",
      "climbingTypes": ["sport"],
      "rockType": "limestone",
      "location": {"latitude": 49.1, "longitude": 16.1},
      "parking": [],
      "access": {"description": "Z návsi pěšky."},
      "restrictions": [],
      "sectors": [
        {
          "id": "sector-stena",
          "name": "Stěna",
          "rocks": [],
          "routes": [
            {
              "id": "route-hrana",
              "name": "Testová hrana",
              "grade": {"system": "french", "value": "6b+"},
              "type": "sport",
              "lengthMeters": 15
            },
            {
              "id": "route-plotna",
              "name": "Testová plotna",
              "grade": {"system": "french", "value": "5c"},
              "type": "sport"
            }
          ]
        }
      ]
    }
  ]
}
''';

/// In-memory database closed automatically when the test ends.
CruxDatabase createTestDatabase() {
  final db = CruxDatabase(NativeDatabase.memory());
  addTearDown(db.close);
  return db;
}

/// Provider overrides wiring the fake bundle and an in-memory database.
///
/// Pass [database] to share one database across several widget trees
/// (e.g. to simulate an app restart).
Future<List<Override>> testOverrides({
  String? catalogJson,
  CruxDatabase? database,
}) async {
  return [
    databaseProvider.overrideWithValue(database ?? createTestDatabase()),
    demoCatalogDataSourceProvider.overrideWithValue(
      DemoCatalogDataSource(
        bundle: FakeAssetBundle(catalogJson ?? testCatalogJson),
      ),
    ),
  ];
}

/// Pumps [home] inside a Czech-localized MaterialApp and a ProviderScope.
Widget wrapScreen(Widget home, List<Override> overrides) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      theme: AppTheme.light(),
      locale: const Locale('cs'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: home,
    ),
  );
}

/// Builds a minimal [ClimbingArea] for pure filter tests.
ClimbingArea buildArea({
  String id = 'area-test',
  String name = 'Testová oblast',
  String regionId = 'region-test',
  String regionName = 'Testový region',
  String summary = 'Souhrn.',
  String description = 'Popis.',
  Set<ClimbingType> climbingTypes = const {ClimbingType.sport},
  RockType rockType = RockType.limestone,
  GeoPoint location = const GeoPoint(latitude: 50, longitude: 15),
  int? routeCount,
}) {
  return ClimbingArea(
    id: id,
    regionId: regionId,
    regionName: regionName,
    name: name,
    summary: summary,
    description: description,
    climbingTypes: climbingTypes,
    rockType: rockType,
    location: location,
    routeCount: routeCount,
  );
}
