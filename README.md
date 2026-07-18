# Crux CZ

Crux CZ is a mobile climbing guide for Czech rock climbers, built with
Flutter for Android and iOS. This repository currently contains **Stage 0
(project foundation)** and the **first part of Stage 1**: browsing climbing
areas, sectors, rocks and routes using bundled demo data.

> ⚠️ All climbing areas in the app are **fictional demo data** created for
> development. Real Czech climbing data will be imported in a later stage.

## What works today

- Discover screen with featured areas, recently viewed areas, personal
  stats (projects / favorites) and active restriction highlights.
- Searchable and filterable area list (name, region, description; climbing
  type, rock type and region filters, diacritics-insensitive search).
- Catalog-wide search: one query matches areas, sectors, rocks and
  individual routes (~104k routes searched via a SQL index, grouped
  results with direct navigation).
- Map of areas (OpenStreetMap): list/map toggle on the Areas tab,
  markers follow the active search and filters, tapping a marker shows
  the area card; area details include a static mini-map with parking
  spots. Map tiles are the one online part of the app.
- Area detail: description, access, parking, restrictions, sector list and
  external map navigation for the area and each parking location.
- Sector detail: rocks/towers with their routes plus routes assigned
  directly to a sector, with guidebook / name / grade sorting.
- Route detail: original grade with its grading system, type, length,
  protection, first ascent, warnings, and persistent **favorite** and
  **project** toggles.
- Czech UI (English strings prepared), light and dark theme.

## Prerequisites

- Flutter **3.44+** (stable channel) with Dart 3.12+
- Android SDK (for Android builds) and/or Xcode (for iOS builds)
- A device or emulator

Verify your setup with `flutter doctor`.

## Install dependencies

```bash
flutter pub get
```

Localizations are generated automatically during build; to generate them
manually run:

```bash
flutter gen-l10n
```

## Run on Android

```bash
flutter run          # uses the connected device/emulator
flutter run -d <id>  # pick a specific device from `flutter devices`
```

### Map tiles

Without configuration the map uses OpenStreetMap tiles. For the Czech
tourist map (recommended), get a free API key at
<https://developer.mapy.com> and pass it at build time:

```bash
flutter run --dart-define=MAPY_API_KEY=<your-key>
flutter build apk --dart-define=MAPY_API_KEY=<your-key>
```

The app then uses the Mapy.com "outdoor" tile set (hiking trails,
terrain). Before a public release, review the Mapy.com API terms
(attribution incl. logo placement).

The code is cross-platform; `flutter run` on an iOS simulator works the
same way.

## Run tests

```bash
flutter analyze   # static analysis (must be clean)
flutter test      # unit + widget tests
```

## How catalog data works

The whole catalog lives in a single gzipped JSON asset:

```
assets/demo_data/climbing_catalog.json.gz
```

Since catalog version 3 it contains the full ČHS rock database — 16
regions, 951 areas and ~104,000 routes (5 MB gzipped), produced by the
importer below. On first launch the app imports it into its local
SQLite database (~1.5 s on desktop); later starts skip the import
entirely unless the asset changes. To refresh the data, run the
importer, review its report and replace the asset with a bumped
`version`.

The asset is parsed defensively in the data layer
(`lib/features/climbing_areas/data/demo_catalog_parser.dart`). A malformed
document raises a `DemoDataFormatException` with the JSON path of the
problem, and the UI shows an error state with a retry action instead of
crashing. To extend the demo data, edit the JSON and bump its `version` —
the app reimports the catalog into its local database on the next launch.
The format is specified in [docs/CATALOG_FORMAT.md](docs/CATALOG_FORMAT.md)
and the parser test suite (`test/unit/demo_catalog_parser_test.dart`)
validates the bundled asset on every test run.

All local state lives in a Drift (SQLite) database behind repository
interfaces: the imported catalog, favorite/project route IDs, recently
viewed areas and the climbing diary (logged ascents with style, date and
note).

## ČHS importer

Real data will come from the ČHS rock database via a standalone CLI in
[importer/](importer/) — it fetches pages into reviewable snapshots
(rate-limited, with source bookkeeping) and produces catalogs in the
exchange format above, validated before export. See
[importer/README.md](importer/README.md). The app itself contains no
scraping code.

## Current limitations

- Offline snapshot of the ČHS database (~96 % of skály; the rest failed
  on a server outage and will be refetched) — no backend, no
  synchronization, data ages until the next import.
- Community and Profile tabs are "coming soon" placeholders.
- No photos on ascents, no diary calendar view.
- No comments, maps or weather.
- Grades are displayed in their original system; no conversion yet.
- The UI language is pinned to Czech (English strings exist but there is
  no language switcher yet).

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for the technical design
and [docs/IMPLEMENTATION_STATUS.md](docs/IMPLEMENTATION_STATUS.md) for a
detailed status and the recommended next steps.
