-- Applied to project habitizer on 18 Nov 2026 (record only; already live).
-- Lets Riad's Digitary brief push #foufi-tagged calendar events into events.
alter table public.events add column if not exists source text, add column if not exists source_ref text;
alter table public.events
  add constraint events_source_check check (source is null or source in ('digitary-brief','digitary-app')),
  add constraint events_source_pair check ((source is null) = (source_ref is null));
create unique index if not exists events_source_ref_key on public.events (source, source_ref) where source is not null;
-- public.sync_source_events(p_source text, p_from date, p_to date, p_items jsonb) returns jsonb
--   security definer; validates source, window <= 62 days, <= 200 items, each item in window;
--   upserts on (source, source_ref) as who='riad'; deletes this source's events in the window not sent.
--   execute: service_role only (revoked from public, anon, authenticated).
