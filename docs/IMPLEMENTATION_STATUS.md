# Implementation status

_Last updated: 2026-07-10 (Stage 0 + Stage 1 + local diary)._

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

## Intentionally deferred

Per the stage scope, none of the following exists (and no fake stubs
pretend it does): authentication, backend/API, Firebase/Supabase,
synchronization, ČHS scraper/importer CLI, diary statistics/calendar/
filters, photos on ascents, comments/social/community features, issue
reporting, roles, payments/QR donations, push notifications, weather,
map tiles / offline maps, complex grade conversion.

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

## Recommended next stage

**Stage 2 completion + Stage 3 start — diary statistics and the ČHS
importer:**

1. Diary enhancements: basic statistics (counts by style/grade/area,
   simple performance overview), filtering, and showing logged routes as
   "climbed" in route lists.
2. Build the separate importer CLI (outside the Flutter app) that outputs
   `docs/CATALOG_FORMAT.md`-conformant JSON: fetch ČHS structures with
   rate limiting, normalize grades, keep source URL + import date,
   detect duplicates, produce a validation report.
3. Replace the demo asset with a real imported sample (bump the catalog
   `version`; the app reseeds automatically).

Suggested prompt for the next iteration:

> Continue the Crux CZ Flutter app. Add diary statistics and filtering
> (Etapa 2 completion) per docs/PRODUCT_ROADMAP.md, then start the
> separate ČHS importer CLI (Etapa 3) producing catalogs conforming to
> docs/CATALOG_FORMAT.md, including source-URL/import-date bookkeeping
> and a validation report. Do not add backend communication. Follow
> docs/ARCHITECTURE.md and keep repository boundaries unchanged.
