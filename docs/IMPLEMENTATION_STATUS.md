# Implementation status

_Last updated: 2026-07-15 (Stage 0–2 + ČHS importer CLI + real data
sample)._

## Completed

**Foundation (Stage 0)**
- Feature-first project structure with domain/data/presentation layers.
- Riverpod 3 for state management and dependency injection.
- GoRouter with a five-tab `StatefulShellRoute` shell and hierarchical
  back navigation.
- Material 3 design system (Crux CZ identity, light + dark theme, spacing
  and radius tokens, `CruxColors` semantic extension).
- Czech-first localization via `gen-l10n` (Czech and English ARB files
  fully populated, app pinned to Czech for now).

**Browsing flow (Stage 1, part 1)**
- Normalized domain model: regions, areas, sectors, rocks, routes,
  grades (7 grading systems preserved verbatim), geo points, parking,
  access info, restrictions. Supports sector→rock→route and
  sector→route shapes.
- Demo catalog asset with 3 fictional areas parsed defensively with
  path-aware error messages and an error/retry UI state.
- Discover dashboard, areas search/filters, area detail, sector detail,
  route detail with favorite and project toggles, external map
  navigation (geo:/Apple Maps/Google Maps fallbacks).

**Local data foundation + diary (Stage 1, part 2)**
- Drift (SQLite) database (`CruxDatabase`) replaces SharedPreferences
  behind the unchanged repository interfaces:
  `UserRouteStateRepository`, `RecentlyViewedAreasRepository`.
- One-time migration of legacy SharedPreferences data (favorites,
  projects, recently viewed) into Drift on first launch.
- Local catalog store: the bundled catalog is imported into the database
  (one JSON document per area + route-id index + regions + metadata).
  Area/route detail reads parse a single area document instead of the
  whole catalog. Reimport happens only when the catalog `version`
  changes.
- Versioned catalog exchange format documented in
  `docs/CATALOG_FORMAT.md` as the contract for the future ČHS importer;
  the parser validates `version` and the demo asset is the reference
  fixture.
- Ascent logging (Etapa 2 core): `Ascent` domain model (8 styles: OS,
  Flash, RP, PP, AF, TR, solo, attempt; date; note), `DiaryRepository`
  with Drift implementation, denormalized route/area display fields so
  entries survive catalog updates.
- Diary tab UI: chronological list (newest first) with grade badge,
  style, date, location and note; entry count; delete via menu; tap
  navigates to the route detail; empty state.
- Logging UI: "Zapsat přelez" button on the route detail opens a bottom
  sheet (style chips, date picker, note); the route detail shows a
  "Moje přelezy" section with the user's ascents of that route.
- Tests: 58 passing (parser incl. malformed data and version validation,
  area filtering, grade ordering, Drift user-state/recently-viewed
  repositories, legacy preferences migration, catalog store seeding +
  version-driven reseeding + route index lookup, diary repository
  ordering/roundtrip/delete, widget tests for areas search/filter, full
  discover→route navigation, favorite/project persistence incl.
  simulated restart, log-ascent flow into the diary and entry deletion).
  `flutter analyze` is clean.

**ČHS importer CLI (Stage 3 core)**
- Standalone Dart package in `importer/` (no Flutter dependency), see
  `importer/README.md`.
- `fetch`: rate-limited (min 1 s, default 2 s), resumable download of
  ČHS pages into snapshot directories; `manifest.json` records source
  URL, fetch time and sha256 per page (change detection on refetch).
- `build`: parses snapshots (defensive HTML parsing of sektor/skála
  pages, GPS from the `map-code` endpoint, grade system from histogram
  tooltips), normalizes to the exchange format (ČHS sektor → area,
  skála → sector, cesta → route; grade-system/rock-type mapping; closure
  icons → restrictions; source bookkeeping in `meta`) and validates.
  Output: catalog JSON + plain-text review report.
- `validate`: standalone format validation of any catalog file.
- Tests: 24 passing (parser against synthetic markup fixtures,
  normalizer incl. fallback warnings, validator rules, snapshot/build
  integration, empty-area dropping). End-to-end verified against a real
  sektor (Bohuňovské skály, 72 routes) and the output loads through the
  app's parser.

**Diary statistics + filtering (Stage 2 completion)**
- `DiaryStats` (total, this-year, distinct routes, counts per style) and
  `DiaryFilter` as pure, unit-tested domain functions.
- Diary screen: stats card, per-style filter chips with counts
  (multi-select), filtered count, empty-filter state with a clear
  action.
- Routes with at least one logged ascent show a "climbed" check mark in
  sector route lists (`climbedRouteIdsProvider`).

**Real data sample (bundled catalog v2)**
- `assets/demo_data/climbing_catalog.json` now contains a real imported
  sample from the ČHS database: oblasti Skály u Poličky, Okolí
  Jimramova and Pelhřimovsko → 3 areas (Bohuňovské skály, Vápenka
  Jimramov, Želiv), 107 routes, catalog version 2, built with
  `--drop-empty-areas` (Senožaty had no routes). Import report reviewed:
  0 validation errors.
- Discover data notice replaced by a ČHS attribution
  (`discoverDataSourceTitle/Body`); the unused demo badge string was
  removed.
- App tests: 66 passing, `flutter analyze` clean.

## Intentionally deferred

Per the stage scope, none of the following exists (and no fake stubs
pretend it does): authentication, backend/API, Firebase/Supabase,
synchronization, diary calendar view, photos on ascents, comments/
social/community features, issue reporting, roles, payments/QR
donations, push notifications, weather, map tiles / offline maps,
complex grade conversion.

## Known limitations

- Catalog is a small real sample (3 areas, 107 routes); list
  virtualization with thousands of routes is untested. The areas list
  still parses all area documents (the repository interface returns
  full models); switch to summary projections when full data volumes
  arrive.
- Imported areas have no parking coordinates and often no route lengths
  (not available on ČHS list pages), so those route-detail rows are
  simply absent.
- Grade sorting uses a per-system heuristic ordinal (not a conversion
  table).
- UI language is pinned to Czech; no language switcher yet.
- Area-level favorites are not implemented (only route favorites).
- Diary filtering covers styles only (no date range or area filter yet);
  no calendar view.
- External navigation behavior on devices depends on installed map apps.
- No map view of areas (deliberately deferred; no map dependency yet).

## Known importer limitations

- Route lengths and multi-pitch info are not exported (not present on
  the ČHS list pages; would require per-route page fetches).
- Restrictions are derived from closure icons only; their seasonal
  details ("Podmínky lezení" texts) still need manual review.
- Parking coordinates are not available on ČHS pages.
- Grade-system labels beyond the mapped set fall back to UIAA with a
  report note; extend the mapping table as new labels appear.

## Recommended next stage

**Stage 4 start — offline-ready data at scale + importer hardening:**

1. Scale the catalog: import one or two full regions with the importer,
   check list performance with thousands of routes, and introduce
   area-summary projections in `ClimbingAreaRepository` if the areas
   list gets slow (interface change confined to data + presentation
   providers).
2. Importer hardening driven by the review report: per-route page
   fetches for lengths and restriction texts ("Podmínky lezení"),
   extended grade-system mapping.
3. Diary polish: date-range/area filters or a simple performance chart
   (roadmap Etapa 2 extras), plus an ascent edit flow.

Suggested prompt for the next iteration:

> Continue the Crux CZ Flutter app. Import one or two full regions with
> importer/ (review the report, bump the catalog version), verify list
> performance with thousands of routes and add area-summary projections
> if needed. Harden the importer where the report shows gaps (route
> lengths, restriction texts). Do not add backend communication. Follow
> docs/ARCHITECTURE.md and keep repository boundaries unchanged.
