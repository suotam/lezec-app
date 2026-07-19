-- Crux CZ — initial backend schema (Supabase / PostgreSQL).
-- Apply once in the Supabase SQL editor (or `supabase db push`).
--
-- Design notes:
-- * The mobile app is offline-first: the local Drift database stays the
--   source of truth and syncs here. Row ids are client-generated, so
--   primary keys include user_id.
-- * `updated_at` + soft deletes (`deleted_at`) let offline clients
--   converge with last-write-wins.
-- * Row-Level Security everywhere: a user can only touch their own rows.
--   The anon key is therefore safe to ship inside the app.

-- ---------------------------------------------------------------------
-- updated_at maintenance

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

-- ---------------------------------------------------------------------
-- profiles (Etapa 6) — one row per auth user, created automatically.

create table public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  display_name text not null default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.profiles enable row level security;

create policy "read own profile"
  on public.profiles for select using (auth.uid() = id);
create policy "update own profile"
  on public.profiles for update using (auth.uid() = id);

create trigger profiles_updated_at
  before update on public.profiles
  for each row execute function public.set_updated_at();

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id) values (new.id);
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ---------------------------------------------------------------------
-- ascents — the climbing diary (mirror of the app's Ascents table;
-- route/area display fields are denormalized on purpose, matching the
-- local schema).

create table public.ascents (
  user_id uuid not null default auth.uid()
    references auth.users (id) on delete cascade,
  id text not null,                     -- client-generated
  route_id text not null,
  route_name text not null,
  grade_value text not null,
  grade_system text not null,
  area_id text not null,
  area_name text not null,
  sector_name text not null,
  style text not null,
  climbed_on date not null,
  note text,
  created_at timestamptz not null,
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  primary key (user_id, id)
);

create index ascents_sync_idx on public.ascents (user_id, updated_at);

alter table public.ascents enable row level security;

create policy "read own ascents"
  on public.ascents for select using (auth.uid() = user_id);
create policy "insert own ascents"
  on public.ascents for insert with check (auth.uid() = user_id);
create policy "update own ascents"
  on public.ascents for update using (auth.uid() = user_id);
create policy "delete own ascents"
  on public.ascents for delete using (auth.uid() = user_id);

create trigger ascents_updated_at
  before update on public.ascents
  for each row execute function public.set_updated_at();

-- ---------------------------------------------------------------------
-- user_route_flags — favorites and projects per route.

create table public.user_route_flags (
  user_id uuid not null default auth.uid()
    references auth.users (id) on delete cascade,
  route_id text not null,
  is_favorite boolean not null default false,
  is_project boolean not null default false,
  updated_at timestamptz not null default now(),
  primary key (user_id, route_id)
);

alter table public.user_route_flags enable row level security;

create policy "read own flags"
  on public.user_route_flags for select using (auth.uid() = user_id);
create policy "insert own flags"
  on public.user_route_flags for insert with check (auth.uid() = user_id);
create policy "update own flags"
  on public.user_route_flags for update using (auth.uid() = user_id);
create policy "delete own flags"
  on public.user_route_flags for delete using (auth.uid() = user_id);

create trigger user_route_flags_updated_at
  before update on public.user_route_flags
  for each row execute function public.set_updated_at();

-- ---------------------------------------------------------------------
-- recent_area_views — cross-device "recently viewed" history.

create table public.recent_area_views (
  user_id uuid not null default auth.uid()
    references auth.users (id) on delete cascade,
  area_id text not null,
  viewed_at timestamptz not null,
  primary key (user_id, area_id)
);

alter table public.recent_area_views enable row level security;

create policy "read own views"
  on public.recent_area_views for select using (auth.uid() = user_id);
create policy "insert own views"
  on public.recent_area_views for insert with check (auth.uid() = user_id);
create policy "update own views"
  on public.recent_area_views for update using (auth.uid() = user_id);
create policy "delete own views"
  on public.recent_area_views for delete using (auth.uid() = user_id);
