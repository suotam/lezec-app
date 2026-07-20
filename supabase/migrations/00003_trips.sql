-- Crux CZ — trip logs (hromadný zápis výjezdu) with photos.
-- Apply after 00002 in the Supabase SQL editor. The `photos` bucket and
-- its policies from 00002 are reused for trip photos.
--
-- A trip is a diary entry for one day at one area: note + photos + the
-- routes climbed. The routes themselves stay ordinary `ascents` rows
-- (created in bulk by the app) linked via `trip_id`.

create table public.trips (
  user_id uuid not null default auth.uid()
    references auth.users (id) on delete cascade,
  id text not null,                     -- client-generated
  area_id text not null,
  area_name text not null default '',
  trip_date date not null,
  note text,
  created_at timestamptz not null,
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  primary key (user_id, id)
);

create index trips_sync_idx on public.trips (user_id, updated_at);

alter table public.trips enable row level security;

create policy "read own trips"
  on public.trips for select using (auth.uid() = user_id);
create policy "insert own trips"
  on public.trips for insert with check (auth.uid() = user_id);
create policy "update own trips"
  on public.trips for update using (auth.uid() = user_id);
create policy "delete own trips"
  on public.trips for delete using (auth.uid() = user_id);

create trigger trips_updated_at
  before update on public.trips
  for each row execute function public.set_updated_at();

-- Link bulk-logged ascents to their trip.
alter table public.ascents add column trip_id text;

-- Photos belong to a trip; files live in the private `photos` bucket
-- under <user-id>/ (policies from migration 00002 already cover that).
create table public.trip_photos (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid()
    references auth.users (id) on delete cascade,
  trip_id text not null,
  storage_path text not null,
  created_at timestamptz not null default now()
);

create index trip_photos_trip_idx on public.trip_photos (user_id, trip_id);

alter table public.trip_photos enable row level security;

create policy "own trip photos readable"
  on public.trip_photos for select using (auth.uid() = user_id);
create policy "add own trip photos"
  on public.trip_photos for insert with check (auth.uid() = user_id);
create policy "remove own trip photos"
  on public.trip_photos for delete using (auth.uid() = user_id);
