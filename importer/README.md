# ČHS importer (chs_importer)

Standalone Dart CLI that imports the ČHS rock database
(www.horosvaz.cz, "Skály ČR") and produces catalogs in the Crux CZ
exchange format (`../docs/CATALOG_FORMAT.md`). It is deliberately
separate from the Flutter app — the app only ever consumes the
normalized JSON output.

## Pipeline

```text
fetch  →  snapshot directory (raw HTML + manifest.json with source URL,
          fetch time, sha256 per page)
build  →  parse snapshots → raw ČHS models → normalize → validate
          → catalog JSON + review report
```

Level mapping (ČHS → catalog): region → region, **sektor → area**,
**skála → sector** (routes directly on the sector), cesta → route. The
ČHS "oblast" grouping has no catalog counterpart; its name is kept in
the area summary and `meta.chsOblast`. GPS comes from the sektor's
`?action=map-code` endpoint; grade systems from the page's histogram
tooltip (`Klasifikace (…)`).

## Usage

```bash
cd importer
dart pub get

# Fetch one sektor (or a whole oblast) into a local snapshot:
dart run chs_importer fetch --sektor 470 --snapshot snapshots/sektor-470
dart run chs_importer fetch --oblast 161 --snapshot snapshots/oblast-161

# Build + validate a catalog from the snapshot:
dart run chs_importer build --snapshot snapshots/sektor-470 \
    --out out/catalog.json --version 2

# Re-validate any catalog file:
dart run chs_importer validate --catalog out/catalog.json
```

`build` writes the catalog plus a `*.report.txt` with validation errors,
warnings and normalization notes (unknown grade systems, missing GPS,
unmapped rock types…). Review the report before shipping a catalog; a
failed validation exits non-zero and the catalog must not ship.

## Being a good citizen

- Requests are rate-limited (default 2 s, the CLI refuses < 1 s) and
  sent with an identifying User-Agent.
- `fetch` is resumable: pages already in the snapshot are skipped
  (`--force` refetches and reports content changes via hash).
- Snapshots and generated catalogs stay local (`snapshots/`, `out/` are
  gitignored) — ČHS content is not committed to this repository.
- Only structured text data is imported: no photos, no topos, no user
  content (per the product roadmap).

## Tests

```bash
dart test
```

Parser tests run against synthetic fixture pages in `test/fixtures/`
that replicate the ČHS markup with fictional content. If the site
changes markup, refetch a page, compare against the fixtures and update
both.
