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
   **Recommended:** turn off *Confirm email* (in the Email provider
   settings) — with it on, every tester must click a confirmation link
   that redirects to the project's Site URL (localhost by default),
   which is confusing. The app handles both modes, but sign-up without
   confirmation is one step instead of three.
   _Note: a leftover unconfirmed smoke-test user
   (`crux.smoke.test.2026@gmail.com`) can be deleted in
   Authentication → Users._
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

## App integration (implemented)

- The publishable key and URL are baked into
  `lib/core/backend/supabase_config.dart` (safe: RLS protects data) and
  overridable via `--dart-define=SUPABASE_URL=…`/`SUPABASE_ANON_KEY=…`.
- **Offline-first stays.** Local Drift remains the source of truth
  (schema v4 added `updated_at` and soft-delete tombstones to user
  tables). `SyncService` pulls, merges with last-write-wins per row
  (pure `mergeByKey`, unit-tested with a two-device simulation) and
  pushes what is newer locally. Everything works with no account or no
  connection.
- Sign in/out lives on the Profile tab (email + password); sync runs on
  login/app start, debounced after every local mutation, and manually
  via the "Synchronizovat" button.
- Server `updated_at` triggers bump timestamps on update; a push is
  followed by one harmless self-echo on the next pull (documented in
  `SupabaseSyncBackend`).

## Not yet implemented

- Catalog updates from Storage (`catalog/latest` version check +
  download into the local database) — next backend step; removes the
  need for app releases on data updates.
- Google/Apple sign-in, password reset UI, account deletion.
- Photos, comments and community features (Etapa 7).
