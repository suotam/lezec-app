import 'package:drift/drift.dart';

part 'crux_database.g.dart';

/// Per-route personal flags. A row exists only while at least one flag is
/// set; clearing both flags deletes the row.
class UserRouteFlags extends Table {
  TextColumn get routeId => text()();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  BoolColumn get isProject => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {routeId};
}

/// History of opened areas. One row per area; re-opening bumps the
/// timestamp. Microseconds keep ordering stable for rapid successive views.
class RecentAreaViews extends Table {
  TextColumn get areaId => text()();
  IntColumn get viewedAtMicros => integer()();

  @override
  Set<Column> get primaryKey => {areaId};
}

/// Key/value metadata about the imported catalog (format version, import
/// timestamp), used to decide whether the bundled catalog must be reseeded.
class CatalogMeta extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

class CatalogRegions extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get country => text()();

  @override
  Set<Column> get primaryKey => {id};
}

/// One area per row with its whole subtree (sectors, rocks, routes) stored
/// as the original catalog JSON document. Detail screens parse a single
/// area instead of the whole catalog.
class CatalogAreas extends Table {
  TextColumn get id => text()();
  TextColumn get regionId => text()();
  TextColumn get document => text()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Route-id → area-id index so a route can be resolved by parsing only the
/// area document it lives in.
class CatalogRouteIndex extends Table {
  TextColumn get routeId => text()();
  TextColumn get areaId => text()();

  @override
  Set<Column> get primaryKey => {routeId};
}

/// Logged ascents. Route/area display fields are denormalized on purpose:
/// a diary entry must stay readable even after the catalog is replaced by
/// a newer import that renames or removes the route.
@DataClassName('AscentRow')
class Ascents extends Table {
  TextColumn get id => text()();
  TextColumn get routeId => text()();
  TextColumn get routeName => text()();
  TextColumn get gradeValue => text()();
  TextColumn get gradeSystem => text()();
  TextColumn get areaId => text()();
  TextColumn get areaName => text()();
  TextColumn get sectorName => text()();
  TextColumn get style => text()();
  DateTimeColumn get climbedOn => dateTime()();
  TextColumn get note => text().nullable()();
  IntColumn get createdAtMicros => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    UserRouteFlags,
    RecentAreaViews,
    CatalogMeta,
    CatalogRegions,
    CatalogAreas,
    CatalogRouteIndex,
    Ascents,
  ],
)
class CruxDatabase extends _$CruxDatabase {
  CruxDatabase(super.e);

  @override
  int get schemaVersion => 1;
}
