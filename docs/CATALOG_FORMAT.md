# Catalog exchange format

The normalized catalog JSON is the contract between the app and any data
producer (today the bundled demo asset, later the ČHS importer CLI). The
app never consumes source-specific data directly — a producer transforms
its source into this format, and the app imports it into the local
database.

`assets/demo_data/climbing_catalog.json` is the reference fixture: it must
always parse, and the importer's output must match its shape.
`parseDemoCatalog()` in
`lib/features/climbing_areas/data/demo_catalog_parser.dart` is the
authoritative validator; this document describes the same rules for
humans.

## Root document

```jsonc
{
  "version": 1,        // required, positive integer
  "regions": [ ... ],
  "areas": [ ... ]
}
```

`version` identifies the catalog content revision. The app stores the
imported version and reimports the catalog only when the shipped document
carries a different value — producers must bump it on every content
change, otherwise devices keep the previously imported data.

## Entities

Required string fields must be non-empty. Optional fields may be omitted
or `null`. Unknown enum values are rejected, not ignored.

### Region

| Field | Type | Notes |
|---|---|---|
| `id` | string | stable, unique |
| `name` | string | |
| `country` | string | e.g. `CZ` |

### Area

| Field | Type | Notes |
|---|---|---|
| `id` | string | stable, unique |
| `regionId` | string | must reference an existing region |
| `name`, `summary`, `description` | string | |
| `climbingTypes` | string[] | `sport`, `trad`, `boulder` |
| `rockType` | string | `sandstone`, `limestone`, `granite`, `gneiss`, `basalt`, `other` |
| `location` | geo point | `{ "latitude": num, "longitude": num }` |
| `parking` | parking[] | optional, defaults to empty |
| `access` | access? | `{ "description": string, "approachMinutes": int? }` |
| `restrictions` | restriction[] | optional |
| `sectors` | sector[] | |

### Sector

| Field | Type | Notes |
|---|---|---|
| `id`, `name` | string | |
| `description`, `accessNote` | string? | |
| `warnings` | string[] | optional |
| `rocks` | rock[] | optional |
| `routes` | route[] | optional; routes directly under the sector |

Both hierarchy shapes are first-class: `sector → rocks[] → routes[]` and
`sector → routes[]`.

### Rock

| Field | Type | Notes |
|---|---|---|
| `id`, `name` | string | |
| `description` | string? | |
| `routes` | route[] | |

### Route

| Field | Type | Notes |
|---|---|---|
| `id` | string | stable, unique across the whole catalog |
| `name` | string | |
| `grade` | object | `{ "system": string, "value": string }`; system one of `uiaa`, `french`, `czechSandstone`, `fontainebleau`, `vScale`, `yds`, `british`; value is the grade exactly as published |
| `type` | string | `sport`, `trad`, `boulder` |
| `lengthMeters` | int? | |
| `description`, `protection`, `firstAscent` | string? | |
| `warnings` | string[] | optional |

### Parking

| Field | Type | Notes |
|---|---|---|
| `id`, `name` | string | |
| `location` | geo point | |
| `note` | string? | |

### Restriction

| Field | Type | Notes |
|---|---|---|
| `id`, `title`, `description` | string | |
| `severity` | string | `info`, `warning`, `closure` |
| `seasonalNote` | string? | |

## Validation rules beyond field types

- Every `area.regionId` must reference a region in `regions`.
- Route IDs must be unique across the whole document.
- Producers must keep IDs stable between exports — the app keys user data
  (favorites, projects, diary entries) on route and area IDs.

## Optional producer metadata

Producers may attach a `meta` object to an area with bookkeeping fields
(the app ignores unknown keys). The ČHS importer writes:

```jsonc
"meta": {
  "sourceUrl": "https://www.horosvaz.cz/skaly-sektor-470/",
  "fetchedAt": "2026-07-12T14:00:00Z",
  "chsOblast": "Skály u Poličky"   // ČHS grouping level with no catalog counterpart
}
```

## The ČHS importer

The importer lives in `importer/` as a standalone Dart CLI (see
`importer/README.md`). It fetches pages into reviewable snapshots
(source URL + fetch date + content hash per page), normalizes them into
this format and validates the result before export. Its validator
mirrors the rules above; a catalog that passes it loads in the app.
