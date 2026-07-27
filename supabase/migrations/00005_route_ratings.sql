-- Crux CZ — community route ratings (star quality, 1–5).
-- Apply after 00004 in the Supabase SQL editor.
--
-- One rating per user per route. Individual rows are world-readable so
-- the app can compute an average; writing is limited to one's own row.

create table public.route_ratings (
  user_id uuid not null default auth.uid()
    references auth.users (id) on delete cascade,
  route_id text not null,
  stars smallint not null check (stars between 1 and 5),
  updated_at timestamptz not null default now(),
  primary key (user_id, route_id)
);

create index route_ratings_route_idx on public.route_ratings (route_id);

alter table public.route_ratings enable row level security;

create policy "ratings are readable"
  on public.route_ratings for select using (true);
create policy "insert own rating"
  on public.route_ratings for insert with check (auth.uid() = user_id);
create policy "update own rating"
  on public.route_ratings for update using (auth.uid() = user_id);
create policy "delete own rating"
  on public.route_ratings for delete using (auth.uid() = user_id);

create trigger route_ratings_updated_at
  before update on public.route_ratings
  for each row execute function public.set_updated_at();

-- Aggregate a route's rating in one round-trip (average + count),
-- avoiding pulling every row to the client.
create or replace function public.route_rating_summary(route text)
returns table (average numeric, rating_count bigint)
language sql
stable
as $$
  select coalesce(avg(stars), 0)::numeric, count(*)::bigint
  from public.route_ratings
  where route_id = route;
$$;
