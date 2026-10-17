-- Run this in Supabase: SQL Editor -> New query -> Run
create table if not exists public.love_letter_acknowledgements (
  letter_id text primary key,
  acknowledged boolean not null default false,
  acknowledged_at timestamptz
);

alter table public.love_letter_acknowledgements enable row level security;

-- Simple setup for this personal, low-sensitivity acknowledgement page.
-- Anyone with the public page can read/write the acknowledgement row.
-- This is convenient but NOT tamper-proof; use a server-side function for stronger security.
drop policy if exists "Public can read love letter acknowledgement" on public.love_letter_acknowledgements;
create policy "Public can read love letter acknowledgement"
on public.love_letter_acknowledgements for select to anon using (true);

drop policy if exists "Public can insert love letter acknowledgement" on public.love_letter_acknowledgements;
create policy "Public can insert love letter acknowledgement"
on public.love_letter_acknowledgements for insert to anon with check (true);

drop policy if exists "Public can update love letter acknowledgement" on public.love_letter_acknowledgements;
create policy "Public can update love letter acknowledgement"
on public.love_letter_acknowledgements for update to anon using (true) with check (true);

insert into public.love_letter_acknowledgements (letter_id, acknowledged, acknowledged_at)
values ('bv-23ae3fffc1dad170', false, null)
on conflict (letter_id) do nothing;

-- One row is recorded each time the letter is opened. Coordinates are only
-- stored after the visitor grants the browser's location permission.
create table if not exists public.love_letter_open_events (
  id uuid primary key default gen_random_uuid(),
  letter_id text not null check (letter_id = 'bv-23ae3fffc1dad170'),
  opened_at timestamptz not null default now(),
  location_status text not null default 'pending'
    check (location_status in ('pending','granted','denied','timeout','unavailable','not_supported')),
  latitude double precision,
  longitude double precision,
  location_accuracy_m double precision,
  whatsapp_opened_at timestamptz,
  created_at timestamptz not null default now(),
  check (
    (latitude is null and longitude is null) or
    (latitude between -90 and 90 and longitude between -180 and 180)
  )
);

alter table public.love_letter_open_events enable row level security;
revoke all on public.love_letter_open_events from anon, authenticated;
grant insert on public.love_letter_open_events to anon;
drop policy if exists "Public can log a letter open" on public.love_letter_open_events;
create policy "Public can log a letter open"
on public.love_letter_open_events for insert to anon
with check (letter_id = 'bv-23ae3fffc1dad170');

-- The public browser can update only the location/status fields on a row when
-- it holds that visit's random UUID. It receives no table read permission.
create or replace function public.update_love_letter_open_location(
  p_event_id uuid,
  p_latitude double precision,
  p_longitude double precision,
  p_accuracy_m double precision,
  p_status text
) returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if p_status not in ('granted','denied','timeout','unavailable') then
    raise exception 'Invalid location status';
  end if;
  if p_status = 'granted' and (
    p_latitude is null or p_longitude is null or
    p_latitude < -90 or p_latitude > 90 or
    p_longitude < -180 or p_longitude > 180
  ) then
    raise exception 'Invalid coordinates';
  end if;
  update public.love_letter_open_events
  set location_status = p_status,
      latitude = case when p_status = 'granted' then p_latitude else null end,
      longitude = case when p_status = 'granted' then p_longitude else null end,
      location_accuracy_m = case when p_status = 'granted' then p_accuracy_m else null end
  where id = p_event_id
    and letter_id = 'bv-23ae3fffc1dad170'
    and location_status = 'pending';
end;
$$;
revoke all on function public.update_love_letter_open_location(uuid,double precision,double precision,double precision,text) from public;
grant execute on function public.update_love_letter_open_location(uuid,double precision,double precision,double precision,text) to anon;

create or replace function public.mark_love_letter_whatsapp_opened(p_event_id uuid)
returns void
language sql
security definer
set search_path = public
as $$
  update public.love_letter_open_events
  set whatsapp_opened_at = now()
  where id = p_event_id
    and letter_id = 'bv-23ae3fffc1dad170'
    and whatsapp_opened_at is null;
$$;
revoke all on function public.mark_love_letter_whatsapp_opened(uuid) from public;
grant execute on function public.mark_love_letter_whatsapp_opened(uuid) to anon;

comment on column public.love_letter_open_events.opened_at is
  'Client-captured letter-open instant, stored as timestamptz; display with AT TIME ZONE Asia/Kolkata for IST.';
comment on column public.love_letter_open_events.whatsapp_opened_at is
  'Records that the click-to-WhatsApp link was opened. It cannot prove the visitor sent the message.';
