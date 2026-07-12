# Architecture

Crux CZ is a feature-first Flutter application with a strict dependency
direction: **presentation → domain ← data**. The UI never touches JSON,
assets or the database directly; everything goes through repository
interfaces defined in the domain layer.

## Folder structure

```text
lib/
├── main.dart                     # entry point, delegates to bootstrap()
├── app/
│   ├── app.dart                  # CruxApp: MaterialApp.router, themes, l10n
│   ├── bootstrap/bootstrap.dart  # async init (Drift DB, legacy migration)
│   └── router/
│       ├── app_router.dart       # GoRouter config + AppRoutes path helpers
│       └── app_shell.dart        # bottom NavigationBar shell
├── core/
│   ├── constants/                # AppSpacing, AppRadii design tokens
│   ├── database/                 # CruxDatabase (Drift), databaseProvider,
│   │                             # legacy SharedPreferences migration
│   ├── errors/                   # DemoDataFormatException
│   ├── localization/             # ARB files + generated AppLocalizations
│   ├── theme/                    # AppTheme (M3 light/dark), CruxColors ext.
│   └── utilities/                # ExternalNavigationService, newUniqueId
├── features/
│   ├── discover/presentation/    # dashboard screen
│   ├── climbing_areas/
│   │   ├── data/                 # catalog parser, asset data source,
│   │   │                         # DriftCatalogStore, Drift repo impls
│   │   ├── domain/               # models, filters, repository interfaces
│   │   └── presentation/         # areas list, area & sector detail, providers
│   ├── climbing_routes/
│   │   ├── data/                 # route lookup via the catalog route index
│   │   ├── domain/               # ClimbingRoute, RouteGrade, sorting, repo
│   │   └── presentation/         # route detail screen, route list tile
│   ├── diary/
│   │   ├── data/                 # DriftDiaryRepository
│   │   ├── domain/               # Ascent, AscentStyle, DiaryRepository
│   │   └── presentation/         # diary screen, log-ascent sheet, providers
│   └── projects/
│       ├── data/                 # Drift favorites/projects repo
│       ├── domain/               # UserRouteStateRepository interface
│       └── presentation/         # UserRouteStateNotifier (favorites/projects)
└── shared/
    ├── extensions/               # localized labels for enums, date format
    └── widgets/                  # cards, badges, empty/error/loading states
```

## Dependency direction

- `domain` contains immutable models and abstract repository interfaces.
  It has no Flutter UI or storage imports (only `foundation` for
  `@immutable`).
- `data` implements the domain interfaces on top of concrete sources
  (bundled JSON asset, SharedPreferences). Parsing and validation live
  here — the rest of the app only ever sees valid domain objects.
- `presentation` consumes repositories through Riverpod providers.
  Widgets read state; all mutations go through notifier methods.
- `core` holds cross-cutting infrastructure (theme, l10n, tokens) and must
  not depend on features. The one exception is
  `core/utilities/external_navigation.dart`, which uses the `GeoPoint`
  value object.
- `shared` holds visual building blocks reused by several features.

## Domain model

```text
ClimbingRegion
ClimbingArea      (regionId, climbingTypes, rockType, location, parking[],
                   access?, restrictions[], sectors[])
ClimbingSector    (rocks[], routes[])      # routes may live on rocks OR
ClimbingRock      (routes[])               # directly under the sector
ClimbingRoute     (grade, type, lengthMeters?, protection?, firstAscent?,…)
RouteGrade        (GradingSystem system, String value)
GeoPoint, ParkingLocation, AccessInformation, ClimbingRestriction
Ascent            (routeId + denormalized route/area display fields,
                   AscentStyle, date, note?, createdAt)
```

Both hierarchy shapes are first-class: `Area → Sector → Rock → Route` and
`Area → Sector → Route`. All entities use stable string IDs suitable for
later backend synchronization.

`RouteGrade` preserves the original grading system (UIAA, French, Saxon,
Fontainebleau, V-scale, YDS, British) and exposes a per-system
`sortOrdinal` used only for sorting inside one list. Cross-system grade
conversion is intentionally not implemented; when it arrives it will be a
pure function over `RouteGrade` without model changes.

## State management (Riverpod 3)

- Repositories are plain `Provider`s (`climbingAreaRepositoryProvider`,
  `userRouteStateRepositoryProvider`, …), so tests and future backend
  implementations swap them with overrides.
- Catalog reads are `FutureProvider`s (`areasProvider`,
  `areaByIdProvider`, `sectorProvider`, `routeContextProvider`), surfacing
  loading/error states as `AsyncValue` handled by the shared
  `AsyncValueView` widget.
- `AreaFilterController extends Notifier<AreaFilter>` holds the search
  query and filters; `filteredAreasProvider` combines it with
  `areasProvider` using the pure `filterAreas()` function (unit tested).
- `UserRouteStateNotifier extends AsyncNotifier<UserRouteState>` loads
  favorites/projects once and writes every toggle through the repository —
  nothing is kept only in memory.
- `DiaryNotifier extends AsyncNotifier<List<Ascent>>` follows the same
  write-through pattern; `routeAscentsProvider` derives one route's
  ascents for the route detail screen.
- `CruxDatabase` is created in `bootstrap()` and injected via a
  `databaseProvider` override; tests override it with an in-memory
  database.

## Routing (GoRouter)

`StatefulShellRoute.indexedStack` provides the five-tab shell with
per-branch navigation stacks:

```text
/                                → Discover
/areas                           → area list
/areas/:areaId                   → area detail
/areas/:areaId/sectors/:sectorId → sector detail
/routes/:routeId                 → route detail (pushed, id-addressable)
/diary                           → diary (logged ascents)
/community /profile              → "coming soon" screens
```

Area and sector details are nested routes, so Android back pops the
hierarchy naturally. Route details are addressed by route ID only —
independent of the browsing path — which keeps deep links stable when the
catalog hierarchy changes.

## Local persistence (Drift/SQLite)

`CruxDatabase` (`core/database/`) holds all local state:

- **User route flags** — one row per route with `isFavorite`/`isProject`
  booleans (`DriftUserRouteStateRepository`).
- **Recent area views** — one row per area with a microsecond timestamp,
  capped at 10 (`DriftRecentlyViewedRepository`).
- **Ascents** — the diary (`DriftDiaryRepository`). Route name, grade,
  area and sector names are denormalized into the row on purpose: a diary
  entry must stay readable after the catalog is replaced by a newer
  import that renames or removes the route.
- **Catalog tables** — see below.

`bootstrap()` runs `migrateLegacyPreferences()`, a one-time import of the
SharedPreferences-era favorites/projects/recently-viewed lists; the legacy
keys are deleted afterwards, so it is a no-op on later launches.

### Catalog store

`DriftCatalogStore` imports the bundled catalog JSON into the database:
regions as columns, each area as **one JSON document row** (its whole
sector/rock/route subtree), plus a `route id → area id` index table and a
metadata table with the imported format version. Deliberately
document-oriented rather than fully relational: the parser remains the
single mapping layer, and full relational normalization is deferred until
something needs cross-catalog queries (e.g. global route search).

Reads go through `DriftClimbingAreaRepository` /
`DriftClimbingRouteRepository`, which call `ensureSeeded()` first. Opening
an area or a route parses only that area's document; only the areas list
screen still materializes all areas (its repository interface returns full
models). The store reimports only when the asset's `version` differs from
the imported one, so a shipped catalog update reaches devices on the next
launch. The exchange format is specified in `docs/CATALOG_FORMAT.md`.

## How a backend fits in later

The catalog is seeded from a bundled asset by `DemoCatalogDataSource` +
`DriftCatalogStore` behind `ClimbingAreaRepository` /
`ClimbingRouteRepository`. A backend stage adds e.g. an API-backed catalog
source feeding the same store (or a caching repository composing API +
local database) and changes one provider binding. Domain models already
use stable string IDs and denormalized display fields (`regionName`) so
list screens don't require joins.

User state repositories follow the same pattern: the future sync logic
(last-write-wins or per-item journal) lives behind
`UserRouteStateRepository` without touching a single widget.

## The future ČHS importer stays separate

The mobile app deliberately knows nothing about ČHS website structures,
HTML or scraping. The importer will be a separate tool (server-side or
CLI) that transforms source data into the app's normalized catalog format,
specified in `docs/CATALOG_FORMAT.md` — the same shape as
`assets/demo_data/climbing_catalog.json`. The app consumes only that
normalized model, so importer changes never ripple into the mobile
codebase, and the demo JSON doubles as the contract fixture for the
importer's output. Producers bump the root `version` on every content
change; that is what triggers the on-device reimport.

## Localization

Czech is the template language (`lib/core/localization/arb/app_cs.arb`);
English (`app_en.arb`) is fully populated. Flutter's built-in `gen-l10n`
generates `AppLocalizations` (no third-party codegen). All UI strings,
including plurals (`sectorsCount`, `routesCount`), go through it — no
hardcoded strings in widgets. The app currently pins `locale: cs`; adding
a language switcher later only requires removing that pin and persisting
the user's choice.

## Design system

`AppTheme` builds Material 3 light/dark themes from a signal-orange seed
with a graphite/sandstone neutral base. Semantic colors that M3 lacks
(restriction severities info/warning/closure, favorite, project) live in
the `CruxColors` ThemeExtension. Spacing and radii come from `AppSpacing`
/ `AppRadii`. Shared visual atoms: `GradeBadge`, `SeverityBadge`,
`RestrictionCard`, `WarningBanner`, `SectionHeader`, `EmptyStateView`,
`ErrorStateView`.
