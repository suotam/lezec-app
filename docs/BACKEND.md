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

## Catalog updates over the air (implemented)

The app checks the public `catalog` bucket once per session (and on the
Profile tab's "Zkontrolovat aktualizace dat" button) and imports a newer
catalog into its local database. Publishing a new catalog:

1. Build it: `dart run chs_importer build … --out out/catalog-vN.json
   --version N --drop-empty-areas`, review the report.
2. `gzip -9 -c out/catalog-vN.json > out/climbing_catalog-vN.json.gz`
3. Upload to Storage bucket `catalog` (dashboard drag & drop):
   - `climbing_catalog-vN.json.gz`
   - `latest.json` with `{"version": N, "object":
     "climbing_catalog-vN.json.gz"}` (overwrite the old one)

Version checks run both before download and inside the import, so a
mis-published older file can never overwrite newer local data. Ship the
same catalog as the bundled asset in the next app release so fresh
installs start current.

## Password reset (implemented — needs one template edit)

The in-app flow emails a one-time code and verifies it without deep
links ("Zapomenuté heslo?" on the Profile tab). **One-time setup:** the
default Supabase "Reset password" email contains only a link. In
Dashboard → *Authentication* → *Emails* → **Reset password**, add the
code to the template, e.g.:

```html
<p>Kód pro obnovu hesla: {{ .Token }}</p>
```

## Not yet implemented

- Google/Apple sign-in, account deletion.
- Photos, comments and community features (Etapa 7); issue reporting
  and roles (Etapa 8).
