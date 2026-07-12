# Implementation status

_Last updated: 2026-07-12 (Stage 0 + Stage 1 + local diary + ČHS
importer CLI)._

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
- Tests: 23 passing (parser against synthetic markup fixtures,
  normalizer incl. fallback warnings, validator rules, snapshot/build
  integration). End-to-end verified against a real sektor (Bohuňovské
  skály, 72 routes) and the output loads through the app's parser.

## Intentionally deferred

Per the stage scope, none of the following exists (and no fake stubs
pretend it does): authentication, backend/API, Firebase/Supabase,
synchronization, diary statistics/calendar/filters, photos on ascents,
comments/social/community features, issue reporting, roles, payments/QR
donations, push notifications, weather, map tiles / offline maps,
complex grade conversion.

## Known limitations

- Catalog is fictional demo data; list virtualization with thousands of
  routes is untested. The areas list still parses all area documents
  (the repository interface returns full models); switch to summary
  projections when real data volumes arrive.
- Grade sorting uses a per-system heuristic ordinal (not a conversion
  table).
- UI language is pinned to Czech; no language switcher yet.
- Area-level favorites are not implemented (only route favorites).
- Diary has no statistics, filtering or calendar yet — only the
  chronological list.
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

**Stage 2 completion + real data sample:**

1. Diary enhancements: basic statistics (counts by style/grade/area,
   simple performance overview), filtering, and showing logged routes as
   "climbed" in route lists.
2. Replace the demo asset with a real imported sample: fetch one or two
   whole oblasti with the importer, review the report, bump the catalog
   `version` and ship it as the bundled asset (the app reseeds
   automatically). Decide how to attribute the ČHS source in the UI
   (the data-source notice on Discover should reference ČHS instead of
   the demo disclaimer).
3. Optional importer hardening: per-route page fetches for lengths and
   restriction texts where the review report shows gaps.

Suggested prompt for the next iteration:

> Continue the Crux CZ Flutter app. Add diary statistics and filtering
> (Etapa 2 completion) per docs/PRODUCT_ROADMAP.md. Then produce a real
> catalog sample with importer/ (one or two oblasti), review the report,
> and replace assets/demo_data/climbing_catalog.json with it, updating
> the demo-data notices to a ČHS attribution. Do not add backend
> communication. Follow docs/ARCHITECTURE.md and keep repository
> boundaries unchanged.
