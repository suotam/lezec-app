-- Crux CZ — community (Etapa 7) and roles/issue reporting (Etapa 8).
-- Apply after 00001 in the Supabase SQL editor.
--
-- Also create a **private** Storage bucket named `photos` (dashboard →
-- Storage → New bucket, public OFF); its access policies are below.

-- ---------------------------------------------------------------------
-- Roles. A role is data on the profile, not a separate account type.
-- Users cannot change their own role; promotion happens in the SQL
-- editor: update profiles set role = 'admin' where id = '<user-id>';

alter table public.profiles
  add column role text not null default 'user'
  check (role in ('user', 'admin'));

create or replace function public.is_admin()
returns boolean
language sql
security definer set search_path = public
stable
as $$
  select exists (
    select 1 from profiles where id = auth.uid() and role = 'admin'
  );
$$;

create or replace function public.prevent_role_self_change()
returns trigger
language plpgsql
as $$
begin
  if new.role is distinct from old.role and not public.is_admin() then
    raise exception 'role can only be changed by an admin';
  end if;
  return new;
end;
$$;

create trigger profiles_protect_role
  before update on public.profiles
  for each row execute function public.prevent_role_self_change();

-- Display names become public through comments; allow reading the few
-- public profile fields.
create policy "profiles are readable"
  on public.profiles for select using (true);

-- ---------------------------------------------------------------------
-- Area managers (správci oblastí). Assigned by admins.

create table public.area_managers (
  user_id uuid not null references auth.users (id) on delete cascade,
  area_id text not null,
  created_at timestamptz not null default now(),
  primary key (user_id, area_id)
);

alter table public.area_managers enable row level security;

create policy "managers are readable"
  on public.area_managers for select using (true);
create policy "admins assign managers"
  on public.area_managers for insert with check (public.is_admin());
create policy "admins remove managers"
  on public.area_managers for delete using (public.is_admin());

create or replace function public.manages_area(area text)
returns boolean
language sql
security definer set search_path = public
stable
as $$
  select exists (
    select 1 from area_managers
    where user_id = auth.uid() and area_id = area
  );
$$;

-- ---------------------------------------------------------------------
-- Route comments (Etapa 7). Readable by everyone (the app works without
-- an account); writing needs one. Soft delete keeps moderation simple.

create table public.route_comments (
  id uuid primary key default gen_random_uuid(),
  route_id text not null,
  user_id uuid not null default auth.uid()
    references auth.users (id) on delete cascade,
  author_name text not null default '',
  body text not null check (char_length(body) between 1 and 2000),
  created_at timestamptz not null default now(),
  deleted_at timestamptz
);

create index route_comments_route_idx
  on public.route_comments (route_id, created_at desc);

alter table public.route_comments enable row level security;

create policy "comments are readable"
  on public.route_comments for select using (deleted_at is null);
create policy "write own comments"
  on public.route_comments for insert with check (auth.uid() = user_id);
create policy "moderate comments"
  on public.route_comments for update
  using (auth.uid() = user_id or public.is_admin());

-- ---------------------------------------------------------------------
-- Issue reports (Etapa 8, závady). Anyone signed-in files them; the
-- reporter, admins and the area's managers see and resolve them.

create table public.issue_reports (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid()
    references auth.users (id) on delete cascade,
  area_id text not null,
  area_name text not null default '',
  route_id text,
  route_name text,
  description text not null check (char_length(description) between 1 and 2000),
  status text not null default 'open'
    check (status in ('open', 'resolved', 'dismissed')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index issue_reports_area_idx
  on public.issue_reports (area_id, created_at desc);

alter table public.issue_reports enable row level security;

create policy "see own or managed reports"
  on public.issue_reports for select
  using (
    auth.uid() = user_id
    or public.is_admin()
    or public.manages_area(area_id)
  );
create policy "file own reports"
  on public.issue_reports for insert with check (auth.uid() = user_id);
create policy "resolve managed reports"
  on public.issue_reports for update
  using (public.is_admin() or public.manages_area(area_id));

create trigger issue_reports_updated_at
  before update on public.issue_reports
  for each row execute function public.set_updated_at();

-- ---------------------------------------------------------------------
-- Ascent photos (Etapa 7). Files live in the private `photos` bucket
-- under <user-id>/...; this table links them to diary entries.

create table public.ascent_photos (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid()
    references auth.users (id) on delete cascade,
  ascent_id text not null,
  storage_path text not null,
  created_at timestamptz not null default now()
);

create index ascent_photos_ascent_idx
  on public.ascent_photos (user_id, ascent_id);

alter table public.ascent_photos enable row level security;

create policy "own photos readable"
  on public.ascent_photos for select using (auth.uid() = user_id);
create policy "add own photos"
  on public.ascent_photos for insert with check (auth.uid() = user_id);
create policy "remove own photos"
  on public.ascent_photos for delete using (auth.uid() = user_id);

-- Storage policies for the private `photos` bucket: every user works
-- only inside their own <user-id>/ folder.
create policy "photos upload own folder"
  on storage.objects for insert
  with check (
    bucket_id = 'photos'
    and (storage.foldername(name))[1] = auth.uid()::text
  );
create policy "photos read own folder"
  on storage.objects for select
  using (
    bucket_id = 'photos'
    and (storage.foldername(name))[1] = auth.uid()::text
  );
create policy "photos delete own folder"
  on storage.objects for delete
  using (
    bucket_id = 'photos'
    and (storage.foldername(name))[1] = auth.uid()::text
  );
