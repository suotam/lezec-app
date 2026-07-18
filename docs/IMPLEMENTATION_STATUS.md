# Implementation status

_Last updated: 2026-07-18 (Stage 0–2 + ČHS importer CLI + full-database
catalog)._

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

**Full-database catalog (bundled catalog v3)**
- The whole ČHS database was crawled (19,400 pages: all 145 oblasti,
  1,105+ sektory, 17,138 of 17,791 skal — 96.3 %; the rest failed on a
  server outage/block near the end and can be fetched later by
  re-running `fetch --all` on the same snapshot).
- `assets/demo_data/climbing_catalog.json.gz` now ships **16 regions,
  951 areas and 104,217 routes** (catalog version 3, 31 MB JSON → 5 MB
  gzip, built with `--drop-empty-areas`). Import report reviewed: 0
  validation errors, ~1,300 review notes (empty skály, missing grades on
  projects, unmapped rock types).
- Importer hardening from full-data findings: route names with quotes
  (broken `title` attributes), trailing `<n>m` length tokens parsed into
  `lengthMeters`, empty access texts dropped, empty route names exported
  as "(bez názvu)", validator checks `access.description`, compact JSON
  output, crash-tolerant crawling with fresh-connection retries and
  batched manifest writes.
- App scale work: per-area **summary documents** (no sector tree,
  precomputed counts) power `getAreas()`; the import is incremental with
  batch inserts; an asset byte-length fingerprint skips all decoding on
  unchanged starts; the catalog asset is gzipped. Measured on desktop:
  seed 1.5 s (one-time), areas list 80 ms, area/route detail 1–2 ms,
  warm start 2 ms. Database schema v2 with destructive catalog-table
  migration (user data untouched).
- Discover data notice updated: offline copy of the ČHS database,
  verify current conditions at the source.

**Catalog-wide search**
- Search-index table (`CatalogSearchEntries`, schema v3) written during
  catalog import: one row per sector, rock and route with normalized
  (lowercased, diacritics-stripped) names and denormalized navigation
  context (area/sector ids and names, route grade).
- `CatalogSearchRepository` runs multi-word SQL LIKE matching with prefix
  matches ranked first, capped at 20 rows per group; a blank/1-char query
  short-circuits.
- The areas screen shows grouped results below the area list: Sektory,
  Skály a věže, Cesty — sector and rock tiles open the sector screen,
  route tiles (with grade badge) open the route detail; a hint appears
  when a group hits the cap. Area filter chips keep constraining only the
  area section.

**Area discovery at country scale (roadmap §5 subset)**
- Region filter chips on the areas screen (16 regions from the catalog).
- Sorting: name (diacritics-insensitive, the default), route count,
  and nearest-first by distance from the device position (haversine on
  `GeoPoint`; pure `sortAreas()` function).
- `LocationService` abstraction over geolocator (permission flow,
  graceful null on denial — the UI keeps the current sort and explains);
  location permissions declared for Android and iOS.
- Discover restriction teasers capped at 4 (was: every restricted area
  in the catalog).
- Area cards show the distance when the list is sorted by proximity.

**Map of areas (roadmap §5 "na mapě" + §6 internal map)**
- `flutter_map` (OpenStreetMap tiles, no API key) behind a shared
  `CruxMap` widget with app-wide tile source, attribution and an
  injectable tile provider (`mapTileProviderFactoryProvider`) — widget
  tests run fully offline against a transparent fake tile.
- Areas tab list/map toggle (AppBar action, state survives tab
  switches). Markers follow the active search and filters; the camera
  refits when the filtered set changes; tapping a marker shows the area
  card, tapping the card opens the detail.
- Area detail mini-map: static (non-interactive) preview with the area
  marker and parking markers, camera fitted to include parking spots.
- Map tiles are the only online dependency of the app; everything else
  stays offline. Tiles are not persisted (offline map packages remain
  deferred per Etapa 4).

**Diary polish (Etapa 2 extras)**
- Ascent editing: `Ascent.copyWith`, `DiaryRepository.updateAscent`,
  edit action in the entry menu reusing the log sheet with prefilled
  values.
- Diary filters extended: climb-year chips and an area dropdown (with
  counts) on top of the style chips; all combine.
- App tests: 82 passing, importer tests: 26 passing, both analyzers
  clean.

## Intentionally deferred

Per the stage scope, none of the following exists (and no fake stubs
pretend it does): authentication, backend/API, Firebase/Supabase,
synchronization, diary calendar view, photos on ascents, comments/
social/community features, issue reporting, roles, payments/QR
donations, push notifications, weather, map tiles / offline maps,
complex grade conversion.

## Known limitations

- ~650 of 17,791 ČHS skály (3.7 %) are missing: the ČHS server stopped
  responding near the end of the crawl (site-wide, even for browsers).
  Re-run `fetch --all` on the existing snapshot in a few days, rebuild
  with version 4 and reship the asset.
- On-device timings are extrapolated from desktop measurements; verify
  the first-launch import (~1.5 s desktop) and list scrolling on a real
  phone.
- Imported areas have no parking coordinates and route lengths exist
  only where ČHS lists them, so those route-detail rows are simply
  absent.
- The gzip asset decodes via `dart:io`, so a web build of the catalog
  pipeline would need a different codec path (mobile/desktop only,
  matching the roadmap).
- Grade sorting uses a per-system heuristic ordinal (not a conversion
  table).
- UI language is pinned to Czech; no language switcher yet.
- Area-level favorites are not implemented (only route favorites).
- Diary filtering covers styles only (no date range or area filter yet);
  no calendar view.
- External navigation behavior on devices depends on installed map apps.
- Map markers are not clustered; at country zoom the 951 markers
  overlap visually (flutter_map culls off-screen markers, so
  performance is fine). Add `flutter_map_marker_cluster` if this
  bothers users.
- Map tiles require network; no tile caching beyond the in-memory one.
  Default style is OpenStreetMap; with `--dart-define=MAPY_API_KEY=…`
  the app switches to the Mapy.com outdoor (tourist) tile set. Google
  Maps was considered and rejected for now: it needs a billing-enabled
  API key and a separate widget stack (google_maps_flutter) that would
  replace flutter_map instead of plugging into it.
  flutter_map logs a debug warning because the application id is still
  `com.example.lezec_app` — set a real id before release.
- INTERNET permission was missing from the main Android manifest until
  2026-07-18 (debug builds mask this); release builds older than that
  show an empty map.

## Known importer limitations

- Route lengths and multi-pitch info are not exported (not present on
  the ČHS list pages; would require per-route page fetches).
- Restrictions are derived from closure icons only; their seasonal
  details ("Podmínky lezení" texts) still need manual review.
- Parking coordinates are not available on ČHS pages.
- Grade-system labels beyond the mapped set fall back to UIAA with a
  report note; extend the mapping table as new labels appear.

## Recommended next stage

1. Verify the app on a real Android device: first-launch import time,
   list scrolling with 951 areas, the location-permission flow for
   distance sorting, APK size.
2. Complete the crawl once the ČHS server recovers (re-run `fetch --all`
   on the existing snapshot, rebuild as version 4, reship the asset).
3. Importer follow-ups from the review report: restriction texts
   ("Podmínky lezení") via per-route fetches, extended grade-system
   mapping for the labels the report flags.
4. Optional diary polish: a simple performance chart (ascents per grade
   over time).

Suggested prompt for the next iteration:

> Continue the Crux CZ Flutter app with fixes from the physical-device
> test round, then per docs/IMPLEMENTATION_STATUS.md: catalog v4 once
> the ČHS server recovers, importer follow-ups (restriction texts).
> Do not add backend communication. Follow docs/ARCHITECTURE.md and
> keep repository boundaries unchanged.
