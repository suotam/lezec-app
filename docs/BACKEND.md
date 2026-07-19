# Backend (Supabase) — setup and design

Stage 5 uses [Supabase](https://supabase.com) (managed PostgreSQL +
auth + storage). The choice is deliberately reversible: it is plain
Postgres behind the app's existing repository interfaces, so a later
move to a self-hosted server would not touch the presentation layer.

## One-time setup (project owner)

1. **Create the project**: supabase.com → *New project*
   - Organization: personal, plan Free.
   - Region: **Central EU (Frankfurt)** — latency + GDPR.
   - Database password: generate a strong one and store it in your
     password manager (needed only for admin/SQL access).
2. **Apply the schema**: Dashboard → *SQL Editor* → paste the contents
   of [`supabase/migrations/00001_init.sql`](../supabase/migrations/00001_init.sql)
   → *Run*. It creates the tables (`profiles`, `ascents`,
   `user_route_flags`, `recent_area_views`) with Row-Level Security.
3. **Catalog bucket**: Dashboard → *Storage* → *New bucket* named
   `catalog`, **public**. The importer's versioned
   `climbing_catalog.json.gz` files will be uploaded here so app
   updates and data updates decouple.
4. **Auth provider**: Dashboard → *Authentication* → *Providers* →
   enable **Email** (Google/Apple sign-in can come later).
5. **Keys**: Dashboard → *Project Settings* → *API*:
   - **Project URL** (`https://<ref>.supabase.co`)
   - **anon public** key
   Hand both to development. The anon key is safe to embed in the app
   (RLS protects all data). **Never share or commit the
   `service_role` key.**
6. **Keep-alive secrets**: GitHub repo → *Settings* → *Secrets and
   variables* → *Actions* → add `SUPABASE_URL` and
   `SUPABASE_ANON_KEY`. The workflow
   `.github/workflows/supabase-keepalive.yml` then pings the API every
   3 days so the free-tier project never pauses (verify once via
   *Actions* → *Supabase keep-alive* → *Run workflow*).

## App integration design (implemented next)

- The app receives the URL and anon key at build time
  (`--dart-define=SUPABASE_URL=… --dart-define=SUPABASE_ANON_KEY=…`),
  same pattern as `MAPY_API_KEY`.
- **Offline-first stays.** Local Drift remains the source of truth;
  a sync engine pushes local changes (per-row `updated_at`, soft
  deletes) and pulls remote ones, last-write-wins per row. Everything
  keeps working with no account or no connection.
- Sync-enabled repositories wrap the existing Drift implementations
  behind the unchanged domain interfaces (`DiaryRepository`,
  `UserRouteStateRepository`, `RecentlyViewedAreasRepository`).
- Login (Etapa 6) uses Supabase Auth via `supabase_flutter`; the
  Profile tab gains sign-in/out and sync status.
- Catalog updates: the app compares the bundled catalog version with
  `catalog/latest` in Storage and downloads a newer one into the local
  database — no app release needed for data updates.
