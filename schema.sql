-- SC Delivery Board: database setup for Supabase
-- Run once in Supabase: SQL Editor > New query > paste this file > Run.
-- Safe to re-run.

-- 1. One table holds every record. "collection" is members, projects, okrs or notes;
--    "data" is the record itself as JSON.
create table if not exists public.docs (
  collection text not null check (collection in ('members','projects','okrs','notes')),
  id         text not null,
  data       jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now(),
  updated_by text default (auth.jwt() ->> 'email'),
  primary key (collection, id)
);

-- 2. Who counts as the team: signed-in Google accounts on these two domains.
--    To add a domain, extend the pattern, e.g. '@(aaico|appliedai|example)\.com$'.
create or replace function public.is_team_member()
returns boolean
language sql
stable
as $$
  select coalesce((auth.jwt() ->> 'email') ~* '@(aaico|appliedai)\.com$', false);
$$;

-- 3. Row level security: nobody outside those domains can read or write anything,
--    even with the public anon key that ships in the page.
alter table public.docs enable row level security;

drop policy if exists "team can read"   on public.docs;
drop policy if exists "team can insert" on public.docs;
drop policy if exists "team can update" on public.docs;
drop policy if exists "team can delete" on public.docs;

create policy "team can read"   on public.docs for select to authenticated using (public.is_team_member());
create policy "team can insert" on public.docs for insert to authenticated with check (public.is_team_member());
create policy "team can update" on public.docs for update to authenticated using (public.is_team_member()) with check (public.is_team_member());
create policy "team can delete" on public.docs for delete to authenticated using (public.is_team_member());

revoke all on public.docs from anon;

-- 4. Field-level updates. Merges a partial change into a record on the server, so two
--    people editing different fields of the same project at the same time don't
--    overwrite each other. Nested objects (the five health ratings) merge too.
create or replace function public.jsonb_deep_merge(a jsonb, b jsonb)
returns jsonb
language sql
immutable
as $$
  select coalesce(a, '{}'::jsonb) || coalesce((
    select jsonb_object_agg(
      k,
      case when jsonb_typeof(a -> k) = 'object' and jsonb_typeof(v) = 'object'
           then public.jsonb_deep_merge(a -> k, v)
           else v end)
    from jsonb_each(coalesce(b, '{}'::jsonb)) as t(k, v)
  ), '{}'::jsonb);
$$;

create or replace function public.merge_doc(p_collection text, p_id text, p_patch jsonb)
returns void
language plpgsql
security invoker          -- runs as the signed-in user, so the policies above still apply
as $$
begin
  update public.docs
     set data = public.jsonb_deep_merge(data, p_patch),
         updated_at = now(),
         updated_by = auth.jwt() ->> 'email'
   where collection = p_collection and id = p_id;
  if not found then
    raise exception 'Record %/% not found or not allowed', p_collection, p_id;
  end if;
end;
$$;

grant execute on function public.merge_doc(text, text, jsonb) to authenticated;
revoke execute on function public.merge_doc(text, text, jsonb) from anon;

-- 5. Live updates: teammates see each other's changes without refreshing.
alter table public.docs replica identity full;
do $$
begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'docs'
  ) then
    alter publication supabase_realtime add table public.docs;
  end if;
end $$;
