-- Crux CZ — sector topo photos (uploaded by area managers, visible to
-- everyone) and self-service account deletion.
-- Apply after 00003 in the Supabase SQL editor. No dashboard steps: the
-- public `topos` bucket is created here.

-- ---------------------------------------------------------------------
-- Public bucket for sector topos. Objects live under
-- <area_id>/<sector_id>/<uuid>.jpg; public read via the bucket flag.

insert into storage.buckets (id, name, public)
values ('topos', 'topos', true)
on conflict (id) do nothing;

create policy "topos upload by managers"
  on storage.objects for insert
  with check (
    bucket_id = 'topos'
    and (
      public.is_admin()
      or public.manages_area((storage.foldername(name))[1])
    )
  );

create policy "topos delete by managers"
  on storage.objects for delete
  using (
    bucket_id = 'topos'
    and (
      public.is_admin()
      or public.manages_area((storage.foldername(name))[1])
    )
  );

-- ---------------------------------------------------------------------
-- Sector photo records. Readable by everyone (the app shows topos to
-- signed-out users too); writing is manager/admin only.

create table public.sector_photos (
  id uuid primary key default gen_random_uuid(),
  area_id text not null,
  sector_id text not null,
  storage_path text not null,
  uploaded_by uuid not null default auth.uid()
    references auth.users (id) on delete cascade,
  created_at timestamptz not null default now()
);

create index sector_photos_sector_idx on public.sector_photos (sector_id);

alter table public.sector_photos enable row level security;

create policy "sector photos are readable"
  on public.sector_photos for select using (true);
create policy "managers add sector photos"
  on public.sector_photos for insert
  with check (public.is_admin() or public.manages_area(area_id));
create policy "managers remove sector photos"
  on public.sector_photos for delete
  using (public.is_admin() or public.manages_area(area_id));

-- ---------------------------------------------------------------------
-- Self-service account deletion (required by Google Play for apps with
-- accounts). Removes the user's storage objects and the auth user; all
-- user tables cascade via their foreign keys.

create or replace function public.delete_own_account()
returns void
language plpgsql
security definer set search_path = public
as $$
begin
  if auth.uid() is null then
    raise exception 'not signed in';
  end if;
  delete from storage.objects
    where bucket_id = 'photos'
      and (storage.foldername(name))[1] = auth.uid()::text;
  delete from auth.users where id = auth.uid();
end;
$$;

revoke all on function public.delete_own_account() from public;
grant execute on function public.delete_own_account() to authenticated;
