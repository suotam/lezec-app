-- Crux CZ — top-rated routes for discovery.
-- Apply after 00005 in the Supabase SQL editor.
--
-- Aggregates community ratings server-side so the app can show the best
-- routes without pulling every rating. The route_ratings select policy
-- is public, so this runs with caller rights (no security definer).

create or replace function public.top_rated_routes(
  min_count int default 1,
  max_results int default 20
)
returns table (route_id text, average numeric, rating_count bigint)
language sql
stable
as $$
  select route_id, avg(stars)::numeric, count(*)::bigint
  from public.route_ratings
  group by route_id
  having count(*) >= min_count
  order by avg(stars) desc, count(*) desc
  limit max_results;
$$;
